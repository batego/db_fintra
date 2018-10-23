-- Function: dv_reporteempleados()

-- DROP FUNCTION dv_reporteempleados();

CREATE OR REPLACE FUNCTION dv_reporteempleados()
  RETURNS SETOF record AS
$BODY$

DECLARE

listaEmpleados record;
miHoy date:= (substring(current_date,1,7)||'-'||extract(day from (select date_trunc('month', current_date) + interval '1 month') - interval '1 day'))::date;
_anio integer:=2017;
_endDate numeric;
contador integer:=0;
_iteraciones integer:=0;
_periodo varchar:='';
_recordQuery record;


BEGIN


raise notice 'iteraciones: %',(miHoy::DATE-'2017-01-01'::DATE)/30 ;
_endDate:=(miHoy::DATE-'2017-01-01'::DATE)/30 ;


FOR _recordQuery IN  (select  ''::VARCHAR as periodo,
		        identificacion::varchar,
			nombre_completo,
			replace(fecha_nacimiento::date,'0099-01-01','0101-01-01')::date as fecha_nacimiento,
			es.department_name as dpto_nacimiento,
			cn.nomciu as ciudad_nacimiento,
			case when sexo = 'f' then 'femenino' else 'masculino' end as genero,
			ec.descripcion as estado_civil,
			p.descripcion as profesion,
			pm.descripcion as macroproceso,
			pr.descripcion as proceso,
			ne.descripcion as nivel_estudio,
			ca.descripcion as cargo,
			nj.descripcion as nivel_jerarquico,
			replace(fecha_ingreso::date,'0099-01-01','0101-01-01')::date as fecha_ingreso,
			rc.codigo as riesgo,
			eps.descripcion as eps,
			afp.descripcion as afp,
			arl.descripcion as arl,
			ce.descripcion as cesantias,
			ccf.descripcion as ccf,
			case when (e.reg_status)=''then'Activo' else 'Inactivo' end as estado
		from administrativo.empleados e
			inner join administrativo.cargos ca on ca.id=e.id_cargo
			inner join administrativo.riesgo_cargos rc on rc.id=e.id_riesgo_cargo
			inner join administrativo.entidades_salud eps on eps.id=e.id_entidad_salud
			inner join administrativo.fondo_pensiones afp on afp.id=e.id_fondo_pensiones
			inner join administrativo.riesgos_laborales arl on arl.id= e.id_riesgos_laboral
			inner join administrativo.caja_compensacion ccf on ccf.id= e.id_caja_compensacion
			inner join ciudad cn on cn.codciu=e.ciudad_nacimiento
			inner join estado_civil ec on ec.id=e.id_estado_civil
			left join nivel_estudio ne on ne.id=e.id_nivel_estudio
			inner join administrativo.fondo_pensiones ce on ce.id=e.id_cesantias
			left join estado es on es.department_code=e.dpto_nacimiento
			inner join administrativo.niveles_jerarquicos nj on nj.id=e.id_nivel_jerarquico
			inner join administrativo.profesiones p on p.id=e.id_profesion
			left join proceso_meta pm on pm.id=e.id_proceso_meta
			left join proceso_interno pr on pr.id=e.id_proceso_interno
			--where identificacion='1045740570'
		order by e.reg_status, nombre_completo)

LOOP

		_periodo:='';
	        contador:=0;
		_anio:=2017;
		FOR _iteraciones IN 1 .._endDate LOOP

			contador:=contador+1;
			_periodo:=_anio||(case when contador between 1 and 9 then '0' else '' end )||contador;
			raise info 'mes : % _anio: % _periodo: _periodo: %',contador,_anio,_periodo;

			_recordQuery.periodo:=_periodo;

			if( mod(_iteraciones,12)=0)then
				_anio=_anio+1;
				contador:=0;
			end if;

			RETURN NEXT _recordQuery;

		END LOOP;

END LOOP;




END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_reporteempleados()
  OWNER TO postgres;
