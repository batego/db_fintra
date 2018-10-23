-- Function: sp_rescarteraconsolidado(numeric, character varying, character varying)

-- DROP FUNCTION sp_rescarteraconsolidado(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_rescarteraconsolidado(periodoasignacion numeric, unidadnegocio character varying, agenteext character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraGeneral record;
	CarteraTotales record;

	PercValorAsignado numeric;
	PercCantAsignado numeric;
	PeriodoTramo numeric;
	PeriodoTramoAnterior numeric;
	ContaVerify numeric;
	Restador numeric;

	CadAgentes varchar;
	periodo_corte varchar;
	FechaCortePeriodo varchar;
	FechaCortePeriodoAnt varchar;

BEGIN

	if ( substring(periodoasignacion,5) = '01' ) then
		PeriodoTramo = substring(periodoasignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = periodoasignacion::numeric - 1;
	end if;

	--PeriodoTramo = PeriodoAsignacion::numeric - 1;
	PeriodoTramoAnterior = PeriodoTramo::numeric - 1;
	ContaVerify = 0;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	select into FechaCortePeriodoAnt to_char(to_timestamp(substring(PeriodoTramoAnterior,1,4)::numeric || '-' || to_char(substring(PeriodoTramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	select into CarteraTotales sum(valor_asignado)::numeric as valor_asignado, count(0)::numeric as total_asignado
	from (
		select
		sum(valor_saldo)::numeric + SP_ResCarteraConsolidadoHijos(PeriodoAsignacion,UnidadNegocio,con.foto_cartera.negasoc)::numeric as valor_asignado
		from con.foto_cartera
		where periodo_lote = PeriodoAsignacion
			and valor_saldo > 0
			and reg_status = ''
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('CP','FF','DF')
			and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_seguro = '') > 0
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_gps = '') > 0
		group by negasoc

	) a;

	FOR CarteraGeneral IN

		select
		vencimiento_mayor::varchar,
		sum(valor_asignado)::varchar as vlr_asignado,
		''::varchar as perc_valor_asignado,
		count(0)::numeric - ContaVerify AS cantidad_asignada, --count(0)::numeric AS cantidad_asignada, | 0::numeric AS cantidad_asignada,
		''::varchar as perc_cantidad_asignado
		from (
			select
			sum(valor_saldo)::numeric + SP_ResCarteraConsolidadoHijos(PeriodoAsignacion,UnidadNegocio,con.foto_cartera.negasoc)::numeric as valor_asignado,
				(
				SELECT
					CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
					     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
					     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
					     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
					     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
					     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
					     WHEN maxdia >= 1 THEN '2- 1 A 30'
					     WHEN maxdia <= 0 THEN '1- CORRIENTE'
						ELSE '0' END AS rango
				FROM (
					 SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
					 FROM con.foto_cartera fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = con.foto_cartera.negasoc
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
						  AND fra.periodo_lote = PeriodoAsignacion
					 GROUP BY negasoc

				) tabla2
				) as vencimiento_mayor

			from con.foto_cartera
			where periodo_lote = PeriodoAsignacion
			and valor_saldo > 0
			and reg_status = ''
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('CP','FF','DF')
			and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
			--and negasoc = 'FA01192'
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_seguro = '') > 0
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_gps = '') > 0
			group by negasoc

		) c
		group by vencimiento_mayor
		order by vencimiento_mayor

	LOOP

		PercValorAsignado = ((CarteraGeneral.vlr_asignado::numeric / CarteraTotales.valor_asignado)*100)::numeric(5,2);
		CarteraGeneral.perc_valor_asignado = PercValorAsignado;

		PercCantAsignado = ((CarteraGeneral.cantidad_asignada::numeric / CarteraTotales.total_asignado)*100)::numeric(5,2);
		CarteraGeneral.perc_cantidad_asignado = PercCantAsignado;
		--CarteraGeneral.cantidad_asignada = CarteraTotales.total_asignado;

		RETURN NEXT CarteraGeneral;

	END LOOP;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_rescarteraconsolidado(numeric, character varying, character varying)
  OWNER TO postgres;
