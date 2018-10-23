-- Function: sp_cosechas(numeric, numeric, character varying)

-- DROP FUNCTION sp_cosechas(numeric, numeric, character varying);

CREATE OR REPLACE FUNCTION sp_cosechas(periodocolocacionini numeric, periodocolocacionfin numeric, unidadnegocio character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraTotales record;
	CarteraGeneral record;
	CarteraWtramoAnterior record;
	BankPay record;

	PercValorAsignado numeric;
	PercCantAsignado numeric;
	_TramoAnterior numeric;
	PeriodoTramo numeric;
	PeriodoTramoAnterior numeric;
	PeriodoTramoPosterior numeric;
	_SumDebidoCobrar numeric;
	Ingresoxcuota_fiducia numeric;
	Ingresoxcuota_fenalco numeric;
	IngresoxCuota numeric;
	GranTotal numeric;

	CadAgentes varchar;
	periodo_corte varchar;
	FechaCortePeriodo varchar;
	FechaCortePeriodoAnt varchar;

BEGIN

	PeriodoTramo = replace(substring(now()::date,1,7),'-','')::numeric;
	if ( substring(PeriodoTramo,5) = '01' ) then
		_TramoAnterior = substring(PeriodoTramo,1,4)::numeric-1||'12';
	else
		_TramoAnterior = PeriodoTramo::numeric - 1;
	end if;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	select into FechaCortePeriodoAnt to_char(to_timestamp(substring(_TramoAnterior,1,4)::numeric || '-' || to_char(substring(_TramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	raise notice 'fecha corte %',FechaCortePeriodo;


	select into GranTotal sum(VlrSaldoCartera) from (

		/***************************************************************
		NEGOCIOS COLOCADOS CANCELADOS EN SU TOTALIDAD
		***************************************************************/

		SELECT
		 t.negocio,
		(SELECT sum(round(valor)) FROM documentos_neg_aceptado  where cod_neg =t.negocio and reg_status='')::numeric as VlrSaldoCartera
		 FROM (
			select
				negasoc::varchar as negocio,
				(select SP_PagoNegocios(negasoc,num_doc_fen))::numeric as pagos,
				sum(f.valor_saldo) as valor_saldo
			from con.foto_cartera f, negocios n
			where f.negasoc = n.cod_neg
				and periodo_lote=PeriodoTramo
				and n.tneg = '03'
				and f.reg_status = ''
				and f.dstrct = 'FINV'
				and n.dist = 'FINV'
				and f.tipo_documento in ('FAC','NDC')
				and substring(f.documento,1,2) not in ('CP','FF','DF')
				and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
				and n.periodo between  PeriodoColocacionIni and PeriodoColocacionFin
				and n.cod_neg not in (
						select n.cod_neg
						from negocios n
						inner join  con.foto_cartera  as f on (f.negasoc = n.cod_neg and f.dstrct = 'FINV' and f.tipo_documento in ('FAC','NDC') and substring(f.documento,1,2) not in ('CP','FF','DF'))
						where n.dist = 'FINV'
						and periodo_lote=PeriodoTramo
						and n.tneg = '03'
						and n.periodo between  PeriodoColocacionIni and PeriodoColocacionFin
						and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
						group by n.cod_neg
						having sum(f.valor_factura) = sum(f.valor_abono)
						union all
						(SELECT negocio_reestructuracion FROM rel_negocios_reestructuracion )
						)
			group by negasoc, num_doc_fen
			order by negasoc
		)t GROUP BY t.negocio

		union all

		select
			n.cod_neg::varchar as negocio,
			(SELECT sum(round(valor)) FROM documentos_neg_aceptado  where cod_neg =n.cod_neg  and reg_status='')::numeric as VlrSaldoCartera
		from negocios n
		inner join con.foto_cartera as f on (f.negasoc = n.cod_neg and f.dstrct = 'FINV' and f.tipo_documento in ('FAC','NDC') and substring(f.documento,1,2) not in ('CP','FF','DF') )
		where n.dist = 'FINV'
		and periodo_lote=PeriodoTramo
		and n.tneg = '03'
		and n.periodo between  PeriodoColocacionIni and PeriodoColocacionFin
		and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
		and n.cod_neg not in (SELECT negocio_reestructuracion FROM rel_negocios_reestructuracion )
		group by negocio
		having sum(f.valor_factura) = sum(f.valor_abono)

	) k;
	--

	raise notice 'GranTotal: %',GranTotal;

	FOR CarteraGeneral IN

				SELECT  vencimiento_mayor::varchar,
					sum(colocacion)::numeric as colocacion,
					count(1)::numeric as cantidades,
					sum(pagos)::numeric as pagos,
					sum(saldo)::numeric as saldo,
					sum(perc_item)::numeric as perc_item
				FROM (

					SELECT
						t.negocio,
						sum(t.pagos) as pagos,
						(SELECT sum(round(valor)) FROM documentos_neg_aceptado  where cod_neg =t.negocio and reg_status='')::numeric as colocacion,
						(SELECT
							CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
							     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
							     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
							     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
							     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
							     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
							     WHEN maxdia >= 1 THEN '2- 1 A 30'
							     WHEN maxdia <= 0 THEN '1- CORRIENTE'
							     WHEN maxdia is null  THEN '1- CORRIENTE'
								ELSE '0' END AS rango
						FROM (
							 SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
							 FROM con.foto_cartera fra
							 WHERE fra.dstrct = 'FINV'
								  AND periodo_lote=PeriodoTramo
								  AND fra.valor_saldo > 0
								  AND fra.reg_status = ''
								  AND fra.negasoc = t.negocio
								  AND fra.tipo_documento in ('FAC','NDC')
								  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
						) tabla2
						)::varchar as vencimiento_mayor,
						sum(valor_saldo) as saldo,
						0.0::numeric as perc_item
					 FROM (
						select
							negasoc::varchar as negocio,
							(select SP_PagoNegocios(negasoc,num_doc_fen))::numeric as pagos,
							sum(f.valor_saldo) as valor_saldo
						from con.foto_cartera f, negocios n
						where f.negasoc = n.cod_neg
							and n.tneg = '03'
							and periodo_lote=PeriodoTramo
							and f.reg_status = ''
							and f.dstrct = 'FINV'
							and n.dist = 'FINV'
							and f.tipo_documento in ('FAC','NDC')
							and substring(f.documento,1,2) not in ('CP','FF','DF')
							and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
							and n.periodo between  PeriodoColocacionIni and PeriodoColocacionFin
							and n.cod_neg not in (
										select n.cod_neg
										from negocios n
										inner join con.foto_cartera  as f on (f.negasoc = n.cod_neg and f.dstrct = 'FINV' and f.tipo_documento in ('FAC','NDC') and substring(f.documento,1,2) not in ('CP','FF','DF'))
										where n.dist = 'FINV'
										and periodo_lote=PeriodoTramo
										and n.tneg = '03'
										and n.periodo between  PeriodoColocacionIni and PeriodoColocacionFin
										and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
										group by n.cod_neg
										having sum(f.valor_factura) = sum(f.valor_abono)
										union all
										(SELECT negocio_reestructuracion FROM rel_negocios_reestructuracion )
										union all
										(SELECT cod_neg FROM tem.cartera_vendida)
										)
						group by negasoc, num_doc_fen
						order by negasoc
					)t GROUP BY t.negocio

					union all
					select
						n.cod_neg::varchar as negocio,
						sum(f.valor_abono) as pago,
						(SELECT sum(round(valor)) FROM documentos_neg_aceptado  where cod_neg =n.cod_neg  and reg_status='')::numeric as colocacion,
						'CANCELACION TOTAL'::varchar as vencimiento_mayor,
						0.0::numeric as saldo,
						0.0::numeric as perc_item
					from negocios n
					inner join con.foto_cartera as f on (f.negasoc = n.cod_neg and f.dstrct = 'FINV' and f.tipo_documento in ('FAC','NDC') and substring(f.documento,1,2) not in ('CP','FF','DF') )
					where n.dist = 'FINV'
					and periodo_lote=PeriodoTramo
					and n.tneg = '03'
					and n.periodo between  PeriodoColocacionIni and PeriodoColocacionFin
					and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
					and n.cod_neg not in (SELECT negocio_reestructuracion FROM rel_negocios_reestructuracion union SELECT cod_neg FROM tem.cartera_vendida )
					group by negocio, vencimiento_mayor
					having sum(f.valor_factura) = sum(f.valor_abono)

					union all
					select
						n.cod_neg::varchar as negocio,
						sum(f.valor_abono) as pago,
						(SELECT sum(round(valor)) FROM documentos_neg_aceptado  where cod_neg =n.cod_neg  and reg_status='')::numeric as colocacion,
						'CARTERA VENDIDA'::varchar as vencimiento_mayor,
						0.0::numeric as saldo,
						0.0::numeric as perc_item
					from negocios n
					inner join con.foto_cartera as f on (f.negasoc = n.cod_neg and f.dstrct = 'FINV' and f.tipo_documento in ('FAC','NDC') and substring(f.documento,1,2) not in ('CP','FF','DF') )
					where n.dist = 'FINV'
					and periodo_lote=PeriodoTramo
					and n.tneg = '03'
					and n.periodo between  PeriodoColocacionIni and PeriodoColocacionFin
					and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
					and n.cod_neg in (SELECT cod_neg FROM tem.cartera_vendida )
					group by negocio, vencimiento_mayor
				)t2
				group by vencimiento_mayor
				order by vencimiento_mayor

	LOOP
		raise notice 'GranTotal: %',GranTotal;

		 --VALIDAMOS LA CARTERA VENDIDA
             --   CarteraGeneral.vencimiento_mayor:=COALESCE((SELECT * FROM tem.cartera_vendida WHERE cod_neg=CarteraGeneral.negocio),CarteraGeneral.vencimiento_mayor);



		IF ( CarteraGeneral.vencimiento_mayor in ( 'CANCELACION TOTAL','CARTERA VENDIDA') ) then
			CarteraGeneral.perc_item = (CarteraGeneral.colocacion/GranTotal)*100;
		ELSE
			CarteraGeneral.perc_item = (CarteraGeneral.saldo/GranTotal)*100;

		END IF;

		RETURN NEXT CarteraGeneral;

	END LOOP;
	--

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cosechas(numeric, numeric, character varying)
  OWNER TO postgres;
