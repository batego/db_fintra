-- Function: dv_cosechasdetallado(numeric, numeric, character varying)

-- DROP FUNCTION dv_cosechasdetallado(numeric, numeric, character varying);

CREATE OR REPLACE FUNCTION dv_cosechasdetallado(periodocolocacionini numeric, periodocolocacionfin numeric, unidadnegocio character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

    CarteraGeneral record;
    RecNegocios record;
    RecLiquidador record;
    RecLiqCta record;
    RecSolicitud record;
    sinCity record;
    sinEstado record;
    Infoto record;
    FchLastPay record;
    PeriodTramoAnt record;
    misDias record;

    _TotalCuotasEnMora numeric;
    _TramoAnterior numeric;
    PeriodoTramo numeric;
    SaldoPorVenc numeric;
    --misDias numeric := 0;

    Unegocio varchar;

    periodo_corte varchar;
    FechaCortePeriodo varchar;
    FechaCortePeriodoAnt varchar;
    UserAnalisis varchar;

    fecha_hoy date;

    indice integer:=0;
    GranTotal numeric;

BEGIN

    PeriodoTramo = replace(substring(now()::date,1,7),'-','')::numeric;
    if ( substring(PeriodoTramo,5) = '01' ) then
        _TramoAnterior = substring(PeriodoTramo,1,4)::numeric-1||'12';
    else
        _TramoAnterior = PeriodoTramo::numeric - 1;
    end if;

    select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
    select into FechaCortePeriodoAnt to_char(to_timestamp(substring(_TramoAnterior,1,4)::numeric || '-' || to_char(substring(_TramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');


   /*Vamos a olvidarnos de las linas 71..79 */
    FechaCortePeriodo:=sp_fecha_corte_foto(substring(PeriodoTramo,1,4),substring(PeriodoTramo,5)::integer);
    FechaCortePeriodoAnt:=sp_fecha_corte_foto(substring(_TramoAnterior,1,4),substring(_TramoAnterior,5)::integer);

    raise notice 'fecha corte: % PeriodoTramo: %',FechaCortePeriodo,PeriodoTramo;
    raise notice 'PeriodoColocacionIni: % PeriodoColocacionFin: %',PeriodoColocacionIni,PeriodoColocacionFin;

    fecha_hoy = now()::date;

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

    FOR CarteraGeneral IN

        SELECT  vencimiento_mayor::varchar,
		sum(colocacion)::numeric as colocacion,
		count(1)::numeric as cantidades,
		sum(pagos)::numeric as pagos,
		sum(saldo)::numeric as saldo,
		sum(perc_item)::numeric as perc_item

	FROM ( select
        ''::varchar as cedula,
        ''::varchar as nombre,
        ''::varchar as unidad_negocio,
        negocio::varchar,
        ''::varchar as afiliado,
        ''::varchar as fecha_aprobacion,
        ''::varchar as fecha_desembolso,
        ''::varchar as periodo_desembolso,
        ''::varchar as total_desembolsado,
        ''::varchar as plazo,
        ''::varchar as cuota, --Será la cuota en la que está actualmente. Si el crédito terminó, será la ultima cuota del credito.
        ''::varchar as cuotas_vencidas,
        ''::varchar as analista,
        ''::varchar as asesor_comercial,
        ''::varchar as cobrador_telefonico,
        ''::varchar as cobrador_campo,
        ''::varchar as fecha_ultimo_pago,
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
                 WHEN maxdia is null  THEN '1- CORRIENTE'
                ELSE '0' END AS rango
        FROM (
             SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
             FROM con.foto_cartera fra
             WHERE fra.dstrct = 'FINV'
                  AND periodo_lote=PeriodoTramo
                  AND fra.valor_saldo > 0
                  AND fra.reg_status = ''
                  AND fra.negasoc = c.negocio
                  AND fra.tipo_documento in ('FAC','NDC')
                  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
        ) tabla2
        )::varchar as vencimiento_mayor,

        ''::varchar as vencimiento_mayor_maximo,
        ''::varchar as tramo_anterior,
        ''::varchar as fecha_vencimiento,
        ''::varchar as direccion,
        ''::varchar as telefono,
        ''::varchar as celular,
        ''::varchar as email,
        ''::varchar as estrato,
        ''::varchar as ocupacion,
        ''::varchar as departamento,
        ''::varchar as municipio,
        ''::varchar as barrio,
        ''::varchar as nombre_empresa,
        ''::varchar as cargo,
        (SELECT sum(round(valor)) FROM documentos_neg_aceptado  where cod_neg =c.negocio and reg_status='')::numeric as colocacion,
        --(select sum(valor_factura) from con.factura where negasoc = c.negocio and tipo_documento in ('FAC','NDC') and reg_status = '' and substring(documento,1,2) in ('FC','FG','FI','MC','MI','CA'))::numeric as colocacion,
        sum(c.pagos)::numeric as pagos,
        0.0::numeric as perc_item,
        ----
        (SELECT
        sum(valor_saldo)::numeric as saldo
        FROM (
            select
                SUM(valor_saldo)::numeric as valor_saldo,
                replace(substring(fecha_vencimiento,1,7),'-','')::numeric as periodo_vcto
            from con.foto_cartera ff, negocios nn
            where ff.negasoc = nn.cod_neg
                and periodo_lote=PeriodoTramo
                and nn.tneg = '03'
                and ff.reg_status = ''
                --and ff.valor_saldo > 0
                and ff.dstrct = 'FINV'
                and nn.dist = 'FINV'
                and ff.tipo_documento in ('FAC','NDC')
                and substring(ff.documento,1,2) not in ('CP','FF','DF')
                and nn.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
                and nn.periodo between PeriodoColocacionIni and PeriodoColocacionFin
                and nn.cod_neg = c.negocio
            group by negasoc, num_doc_fen,  fecha_vencimiento, periodo_vcto
            order by negasoc
        ) l )::numeric as saldo,
        ----

        0::numeric as saldo_porvencer
        from (

            select
                negasoc::varchar as negocio,
                (select SP_PagoNegocios(negasoc,num_doc_fen))::numeric as pagos
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
                and n.periodo between PeriodoColocacionIni and PeriodoColocacionFin
                --and n.cod_neg = 'FA12830'
                and n.concepto_neg_rel != 'CCART'
                and n.cod_neg not in (
                            select n.cod_neg
                            from negocios n
                            inner join con.foto_cartera as f on (f.negasoc = n.cod_neg and f.dstrct = 'FINV' and f.tipo_documento in ('FAC','NDC') and substring(f.documento,1,2) not in ('CP','FF','DF'))
                            where n.dist = 'FINV'
                            and periodo_lote=PeriodoTramo
                            and n.tneg = '03'
                            and n.periodo between PeriodoColocacionIni and PeriodoColocacionFin
                            and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
                            group by n.cod_neg
                            having sum(f.valor_factura) = sum(f.valor_abono)
                            union all
                            (SELECT negocio_reestructuracion FROM rel_negocios_reestructuracion )
                        )
            group by negasoc, num_doc_fen
            order by negasoc
        ) c
        group by negocio

        union all

        ------------------------------------------------------------------------------
        select
        ''::varchar as cedula,
        ''::varchar as nombre,
        ''::varchar as unidad_negocio,
        negocio::varchar,
        ''::varchar as afiliado,
        ''::varchar as fecha_aprobacion,
        ''::varchar as fecha_desembolso,
        ''::varchar as periodo_desembolso,
        ''::varchar as total_desembolsado,
        ''::varchar as plazo,
        ''::varchar as cuota,
        ''::varchar as cuotas_vencidas,
        ''::varchar as analista,
        ''::varchar as asesor_comercial,
        ''::varchar as cobrador_telefonico,
        ''::varchar as cobrador_campo,
        ''::varchar as fecha_ultimo_pago, --
        vencimiento_mayor::varchar,
        ''::varchar as vencimiento_mayor_maximo,
        ''::varchar as tramo_anterior,
        ''::varchar as fecha_vencimiento, --
        ''::varchar as direccion,
        ''::varchar as telefono,
        ''::varchar as celular,
        ''::varchar as email,
        ''::varchar as estrato,
        ''::varchar as ocupacion,
        ''::varchar as departamento,
        ''::varchar as municipio,
        ''::varchar as barrio,
        ''::varchar as nombre_empresa,
        ''::varchar as cargo,
        colocacion::numeric,
        pagos::numeric,
        0.0::numeric as perc_item,
        0::numeric as saldo,
        0::numeric as saldo_porvencer
        from (
            select
            n.cod_neg::varchar as negocio,
            'CANCELACION TOTAL'::varchar as vencimiento_mayor,
            (SELECT sum(round(valor)) FROM documentos_neg_aceptado  where cod_neg =n.cod_neg  and reg_status='')::numeric as colocacion,
            --sum(f.valor_factura) as colocacion,
            sum(f.valor_abono) as pagos
            from negocios n
            inner join con.foto_cartera  as f on (f.negasoc = n.cod_neg and f.dstrct = 'FINV' and f.tipo_documento in ('FAC','NDC') and substring(f.documento,1,2) not in ('CP','FF','DF') )
            where n.dist = 'FINV'
            and periodo_lote=PeriodoTramo
            and n.tneg = '03'
            and n.periodo between PeriodoColocacionIni and PeriodoColocacionFin
            and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
            and n.cod_neg not in (SELECT negocio_reestructuracion FROM rel_negocios_reestructuracion )
            group by negocio, vencimiento_mayor
            having sum(f.valor_factura) = sum(f.valor_abono)
        ) c

        ------------------------------------------------------------------------------

        union all

        select
        ''::varchar as cedula,
        ''::varchar as nombre,
        ''::varchar as unidad_negocio,
        negocio::varchar,
        ''::varchar as afiliado,
        ''::varchar as fecha_aprobacion,
        ''::varchar as fecha_desembolso,
        ''::varchar as periodo_desembolso,
        ''::varchar as total_desembolsado,
        ''::varchar as plazo,
        ''::varchar as cuota,
        ''::varchar as cuotas_vencidas,
        ''::varchar as analista,
        ''::varchar as asesor_comercial,
        ''::varchar as cobrador_telefonico,
        ''::varchar as cobrador_campo,
        ''::varchar as fecha_ultimo_pago, --
        vencimiento_mayor::varchar,
        ''::varchar as vencimiento_mayor_maximo,
        ''::varchar as tramo_anterior,
        ''::varchar as fecha_vencimiento, --
        ''::varchar as direccion,
        ''::varchar as telefono,
        ''::varchar as celular,
        ''::varchar as email,
        ''::varchar as estrato,
        ''::varchar as ocupacion,
        ''::varchar as departamento,
        ''::varchar as municipio,
        ''::varchar as barrio,
        ''::varchar as nombre_empresa,
        ''::varchar as cargo,
        colocacion::numeric,
        pagos::numeric,
        0.0::numeric as perc_item,
        0::numeric as saldo,
        0::numeric as saldo_porvencer
        from (
            select
            n.cod_neg::varchar as negocio,
            'CASTIGO CARTERA VENDIDA'::varchar as vencimiento_mayor,
            (SELECT sum(round(valor)) FROM documentos_neg_aceptado  where cod_neg =n.cod_neg  and reg_status='')::numeric as colocacion,
            --sum(f.valor_factura) as colocacion,
            sum(f.valor_abono) as pagos
            from negocios n
            inner join con.foto_cartera  as f on (f.negasoc = n.cod_neg and f.dstrct = 'FINV' and f.tipo_documento in ('FAC','NDC') and substring(f.documento,1,2) not in ('CP','FF','DF') )
            where n.dist = 'FINV'
            and periodo_lote=PeriodoTramo
            and n.tneg = '03'
            and n.periodo between PeriodoColocacionIni and PeriodoColocacionFin
            and n.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio = UnidadNegocio)
            and n.concepto_neg_rel = 'CCART'
            group by negocio, vencimiento_mayor
        ) c
        )t2
				group by vencimiento_mayor
				order by vencimiento_mayor
    LOOP

  	indice:= indice+1;
	raise notice 'XXXXXXXXXXXXXXXXXXXXXXXXX % CarteraGeneral : %',indice,CarteraGeneral;

	--IF ( CarteraGeneral.vencimiento_mayor in ( 'CANCELACION TOTAL','CARTERA VENDIDA') ) then
		--	CarteraGeneral.perc_item = (CarteraGeneral.colocacion/GranTotal)*100;
		---ELSE

			if (CarteraGeneral.saldo = 0) then
				CarteraGeneral.perc_item = 0;

			else
				CarteraGeneral.perc_item = (CarteraGeneral.saldo/GranTotal)*100;
			end if;

		raise notice 'vencimiento_mayor : %',CarteraGeneral.vencimiento_mayor;
		raise notice 'Saldo : %',CarteraGeneral.saldo;
		raise notice 'colocacion : %',CarteraGeneral.colocacion;
		raise notice 'pagos : %',CarteraGeneral.pagos;
		raise notice 'perc_item : %',CarteraGeneral.perc_item;


		--END IF;

        RETURN NEXT CarteraGeneral;

    END LOOP;
    --

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_cosechasdetallado(numeric, numeric, character varying)
  OWNER TO postgres;
