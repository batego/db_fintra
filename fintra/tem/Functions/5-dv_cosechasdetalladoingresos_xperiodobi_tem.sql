-- Function: tem.dv_cosechasdetalladoingresos_xperiodobi_tem()

-- DROP FUNCTION tem.dv_cosechasdetalladoingresos_xperiodobi_tem();

CREATE OR REPLACE FUNCTION tem.dv_cosechasdetalladoingresos_xperiodobi_tem()
  RETURNS text AS
$BODY$

DECLARE

nro_registros integer:=0;
PeriodoTramo varchar;
_TramoAnterior varchar;
result text := 'Proceso terminado con exito';

BEGIN

 PeriodoTramo = replace(substring(now()::date,1,7),'-','')::numeric;
    if ( substring(PeriodoTramo,5) = '01' ) then
        _TramoAnterior = substring(PeriodoTramo,1,4)::numeric-1||'12';
    else
        _TramoAnterior = PeriodoTramo::numeric - 1;
    end if;


DELETE FROM tem.cosechas_xunidad_micro_tem where periodo_negocio between _TramoAnterior and PeriodoTramo ;


INSERT INTO tem.cosechas_xunidad_micro_tem(
            cedula, nombre, unidad_negocio, negocio, afiliado, fecha_aprobacion,
            fecha_desembolso, periodo_desembolso, total_desembolsado, plazo,
            cuota, cuotas_vencidas, analista, asesor_comercial, cobrador_telefonico,
            cobrador_campo, fecha_ultimo_pago, vencimiento_mayor, vencimiento_mayor_maximo,
            tramo_anterior, fecha_vencimiento, direccion, telefono, celular,
            email, estrato, ocupacion, departamento, municipio, barrio, nombre_empresa,
            cargo, colocacion, pagos, saldo, saldo_porvencer, ingresos,periodo_negocio)

select * from dv_cosechasdetalladoingresos_xperiodo('1') as coco
(cedula varchar,nombre varchar,unidad_negocio varchar,negocio varchar,afiliado varchar,fecha_aprobacion varchar,fecha_desembolso varchar,periodo_desembolso varchar,total_desembolsado varchar,plazo varchar,
cuota varchar,cuotas_vencidas varchar,analista varchar,asesor_comercial varchar,cobrador_telefonico varchar,cobrador_campo varchar,fecha_ultimo_pago varchar,vencimiento_mayor varchar,vencimiento_mayor_maximo varchar,
tramo_anterior varchar,fecha_vencimiento varchar,direccion varchar,telefono varchar,celular varchar,email varchar,estrato varchar,ocupacion varchar,departamento varchar,municipio varchar,barrio varchar,
nombre_empresa varchar,cargo varchar,colocacion numeric,pagos numeric,saldo numeric,saldo_porvencer numeric, ingresos numeric, periodo_negocio varchar) order by unidad_negocio,vencimiento_mayor,fecha_aprobacion;


SELECT COUNT(0) INTO nro_registros  FROM tem.cosechas_xunidad_micro_tem WHERE periodo_negocio between _TramoAnterior and PeriodoTramo ;
raise notice 'v_filas : %',nro_registros;

RETURN result;



END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.dv_cosechasdetalladoingresos_xperiodobi_tem()
  OWNER TO postgres;
