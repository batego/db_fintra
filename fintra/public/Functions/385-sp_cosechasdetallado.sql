-- Function: sp_cosechasdetallado(numeric, numeric, character varying)

-- DROP FUNCTION sp_cosechasdetallado(numeric, numeric, character varying);

CREATE OR REPLACE FUNCTION sp_cosechasdetallado(periodocolocacionini numeric, periodocolocacionfin numeric, unidadnegocio character varying)
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

    FOR CarteraGeneral IN

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
    LOOP

        --VALIDAMOS LA CARTERA VENDIDA
        CarteraGeneral.vencimiento_mayor:=COALESCE((SELECT descripcion FROM tem.cartera_vendida WHERE cod_neg=CarteraGeneral.negocio),CarteraGeneral.vencimiento_mayor);

        --TRAMO ANTERIOR
        SELECT INTO PeriodTramoAnt
            CASE WHEN maxdia >= 361 THEN '8- MAYOR A 1 AÑO'
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
             SELECT max(FechaCortePeriodoAnt::date-fecha_vencimiento) as maxdia
             FROM con.foto_cartera fra
             WHERE fra.dstrct = 'FINV'
                  AND fra.valor_saldo > 0
                  AND fra.reg_status = ''
                  AND fra.negasoc = CarteraGeneral.negocio
                  AND fra.tipo_documento in ('FAC','NDC')
                  AND fra.periodo_lote = _TramoAnterior
        ) tabla3;

        CarteraGeneral.tramo_anterior = PeriodTramoAnt.rango;

        --LIQUIDADOR
        SELECT INTO RecLiquidador max(valor) as cta_mensual, count(0) as total_cuotas FROM documentos_neg_aceptado WHERE cod_neg = CarteraGeneral.negocio;

        CarteraGeneral.plazo = RecLiquidador.total_cuotas;

        --NEGOCIO
        SELECT INTO RecNegocios cod_neg, cod_cli, id_convenio, fecha_ap::date, f_desem::date,vr_negocio, vr_desembolso, update_user
        ,(select nomcli from cliente where nit = negocios.cod_cli limit 1) as nombre
        --,(select nomcli from cliente where nit = negocios.nit_tercero limit 1) as nombre_afiliado
        ,coalesce((select nombre from nit where cedula = negocios.nit_tercero limit 1),(SELECT payment_name FROM proveedor  where nit= negocios.nit_tercero) ) as nombre_afiliado
        FROM negocios
        WHERE cod_neg = CarteraGeneral.negocio;

        CarteraGeneral.fecha_vencimiento = (RecNegocios.fecha_ap + ( ('' || RecLiquidador.total_cuotas || 'month')::interval))::date;

        CarteraGeneral.cedula = RecNegocios.cod_cli;
        CarteraGeneral.fecha_aprobacion = RecNegocios.fecha_ap;
        CarteraGeneral.fecha_desembolso = RecNegocios.f_desem;
        CarteraGeneral.periodo_desembolso = replace(substring(RecNegocios.f_desem,1,7),'-','');
        CarteraGeneral.total_desembolsado = RecNegocios.vr_negocio;--cambio de vr_desembolso a vr_negocio
        CarteraGeneral.nombre = RecNegocios.nombre;
        CarteraGeneral.afiliado = RecNegocios.nombre_afiliado;

        SELECT INTO UserAnalisis usuario FROM negocios_trazabilidad WHERE cod_neg = CarteraGeneral.negocio AND actividad = 'ANA' LIMIT 1;
        CarteraGeneral.analista = UserAnalisis;

        --UNIDAD DE NEGOCIO
        SELECT INTO Unegocio u.descripcion
        FROM rel_unidadnegocio_convenios ru
        INNER JOIN unidad_negocio u ON ( u.id = ru.id_unid_negocio AND u.id IN (1,2,3,4,5,6,7,8,9,11,10) )
        WHERE id_convenio = RecNegocios.id_convenio;

        CarteraGeneral.unidad_negocio = Unegocio;

        --CUOTAS VENCIDAS
        SELECT INTO _TotalCuotasEnMora count(0) as CtasEnMora from con.factura where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = CarteraGeneral.negocio and valor_saldo > 0 and fecha_vencimiento <= fecha_hoy and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');
        CarteraGeneral.cuotas_vencidas = _TotalCuotasEnMora;


        --CUOTA ACTUAL

        SELECT   INTO RecLiqCta *
             FROM documentos_neg_aceptado
             WHERE cod_neg = CarteraGeneral.negocio
             and replace(substring(fecha,1,7),'-','')::numeric = replace(substring(now()::date,1,7),'-','')::numeric;
        IF (NOT FOUND)THEN
            CarteraGeneral.cuota = RecLiquidador.total_cuotas;
        END IF;

        /*IF ( CarteraGeneral.fecha_vencimiento < fecha_hoy ) THEN

            CarteraGeneral.cuota = RecLiquidador.total_cuotas;
        ELSE
            SELECT INTO RecLiqCta * FROM documentos_neg_aceptado WHERE cod_neg = CarteraGeneral.negocio and replace(substring(fecha,1,7),'-','')::numeric = replace(substring(now()::date,1,7),'-','')::numeric;
            CarteraGeneral.cuota = RecLiqCta.item;
        END IF;*/

        --INFORMACION DE FOTO
        SELECT INTO Infoto *
        FROM con.foto_cartera
        WHERE periodo_lote = PeriodoTramo
            AND negasoc = CarteraGeneral.negocio
            AND reg_status = ''
            AND dstrct = 'FINV'
            AND tipo_documento in ('FAC','NDC')
            AND substring(documento,1,2) not in ('CP','FF','DF')
            AND agente != '' limit 1;

        CarteraGeneral.cobrador_telefonico = Infoto.agente;
        CarteraGeneral.cobrador_campo = Infoto.agente_campo;

        --ULTIMO PAGO
        SELECT into FchLastPay max(i.fecha_consignacion) as fecha_consignacion
        FROM con.ingreso_detalle id
        INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli=id.nitcli )
        WHERE id.dstrct = 'FINV'
            and id.tipo_documento in ('ING','ICA')
            and i.reg_status = ''
            and i.nitcli= RecNegocios.cod_cli
            and id.reg_status = ''
            and i.fecha_consignacion <= fecha_hoy
            and id.num_ingreso in (
                        select distinct num_ingreso
                        from con.ingreso_detalle id, con.factura f
                        where id.factura = f.documento
                        and f.negasoc = CarteraGeneral.negocio
                        and f.tipo_documento in ('FAC','NDC')
                        and f.reg_status = ''
                        and id.documento != ''
                         );
        IF FOUND THEN
            CarteraGeneral.fecha_ultimo_pago = FchLastPay.fecha_consignacion::date;
        END IF;

        --VENCIMIENTO MAYOR MAXIMO EN EL CREDITO
        SELECT INTO misDias
            CASE WHEN maxdia >= 361 THEN '8- MAYOR A 1 AÑO'
                 WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
                 WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
                 WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
                 WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
                 WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
                 WHEN maxdia >= 1 THEN '2- 1 A 30'
                 WHEN maxdia <= 0 THEN '1- CORRIENTE'
                 WHEN maxdia is null  THEN '1- CORRIENTE'
                ELSE '0' END AS rango
        FROM (SELECT eg_altura_mora_periodo(CarteraGeneral.negocio,201412,2,0)::NUMERIC as maxdia) tabla3;
        CarteraGeneral.vencimiento_mayor_maximo = misDias.rango;


        --SALDO POR VENCER
        SELECT INTO SaldoPorVenc coalesce(sum(valor_saldo),0)
        FROM con.foto_cartera ff
        WHERE ff.reg_status = ''
            AND periodo_lote=PeriodoTramo
            AND ff.valor_saldo > 0
            AND ff.dstrct = 'FINV'
            AND ff.tipo_documento in ('FAC','NDC')
            AND substring(ff.documento,1,2) not in ('CP','FF','DF')
            AND ff.negasoc = CarteraGeneral.negocio
            AND ff.fecha_vencimiento::date > now()::date;
        CarteraGeneral.saldo_porvencer = SaldoPorVenc;


        --INFORMACION SOCIODEMOGRAFICA
        FOR RecSolicitud IN

            SELECT DISTINCT ON (sp.numero_solicitud, sp.identificacion)
                sp.identificacion,
                sp.nombre,
                sp.tipo_id,
                sp.ciudad,
                sp.departamento,
                sp.direccion,
                sp.barrio,
                sp.telefono,
                sp.direccion as direccion_correspondencia,
                sp.email,
                sp.celular,
                sp.tipo,
                sp.estrato,
                sl.ciudad as ciudad_laboral,
                sl.departamento as departamento_laboral,
                sl.direccion as direccion_laboral,
                sl.telefono as telefono_laboral,
                sl.nombre_empresa,
                (select dato from tablagen where table_type = 'OCUPAC' and table_code = sl.ocupacion) as ocupacion,
                sl.cargo,
                sa.asesor
            FROM solicitud_persona as sp
            INNER JOIN solicitud_aval sa on (sa.numero_solicitud=sp.numero_solicitud)
            LEFT JOIN solicitud_laboral as sl on (sp.dstrct=sl.dstrct and sp.numero_solicitud=sl.numero_solicitud and sp.tipo=sl.tipo)
            WHERE sp.numero_solicitud = (select numero_solicitud from solicitud_aval where cod_neg = CarteraGeneral.negocio)
            AND sp.tipo = 'S'
        LOOP

            CarteraGeneral.direccion = RecSolicitud.direccion;
            CarteraGeneral.telefono = RecSolicitud.telefono;
            CarteraGeneral.celular = RecSolicitud.celular;
            CarteraGeneral.email = RecSolicitud.email;
            CarteraGeneral.estrato = RecSolicitud.estrato;
            CarteraGeneral.ocupacion = RecSolicitud.ocupacion;
            CarteraGeneral.barrio = RecSolicitud.barrio;
            CarteraGeneral.nombre_empresa = RecSolicitud.nombre_empresa;
            CarteraGeneral.cargo = RecSolicitud.cargo;
            CarteraGeneral.asesor_comercial = RecSolicitud.asesor ;

            select into sinCity nomciu from ciudad where codciu = RecSolicitud.ciudad;
            select into sinEstado department_name from estado where department_code = RecSolicitud.departamento;

            CarteraGeneral.departamento = sinEstado.department_name;
            CarteraGeneral.municipio = sinCity.nomciu;

        END LOOP;

	indice:= indice+1;
	raise notice 'XXXXXXXXXXXXXXXXXXXXXXXXX % CarteraGeneral : %',indice,CarteraGeneral;

        RETURN NEXT CarteraGeneral;

    END LOOP;
    --

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cosechasdetallado(numeric, numeric, character varying)
  OWNER TO postgres;
