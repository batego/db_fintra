-- Function: administrativo.dv_actualizar_pasivo_vacacional()

-- DROP FUNCTION administrativo.dv_actualizar_pasivo_vacacional();

CREATE OR REPLACE FUNCTION administrativo.dv_actualizar_pasivo_vacacional()
  RETURNS text AS
$BODY$
DECLARE

retorno text:='OK';
recordPeriodo record;




BEGIN

		--BUSCAMOS LOS PERIODOS QUE YA CUMPLIERON 365 DIAS

	for recordPeriodo in

	SELECT  f2.id, (now()::date- periodo_ini) as dias,  cc_empleado, periodo_ini, periodo_fin, (saldo_inicial+(((now()::date-periodo_ini::date)::float/365)*15)-dias_disfrutados-dias_compensados)::numeric as saldo_final
		FROM administrativo.pasivo_vacacional f2
		INNER JOIN administrativo.empleados e on e.identificacion = f2.cc_empleado
		WHERE 	f2.id = (select id from administrativo.pasivo_vacacional f1 where f1.cc_empleado = f2.cc_empleado order by f1.periodo_ini desc limit 1)
		and (now()::date- periodo_ini::date) >=365 and e.reg_status = '' and e.fecha_retiro != '0099-01-01 00:00:00'
		--and (now()::date- periodo_ini::date) >=364 and e.reg_status = ''  --Algunas veces funciona con 364 y otras con 365


	LOOP
		update administrativo.pasivo_vacacional
		set periodo_fin = periodo_ini::date + 364 --now()
		where id = recordPeriodo.id; --and (now()::date- periodo_ini::date) <=364; --= (select id from administrativo.pasivo_vacacional where cc_empleado = recordPeriodo.cc_empleado order by periodo_ini desc limit 1);
		raise notice 'cc_empleado %',recordPeriodo.cc_empleado;

		--INSERTAMOS EL NUEVO PERIODO SI NO EXISTE
		INSERT INTO administrativo.pasivo_vacacional(reg_status, dstrct, cc_empleado,periodo_ini, last_update, user_update, creation_date, creation_user)
                VALUES ('', 'FINV', recordPeriodo.cc_empleado,recordPeriodo.periodo_fin::date+ 1, now(), 'ADMIN', now(), 'ADMIN');

	END LOOP ;


RETURN retorno;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.dv_actualizar_pasivo_vacacional()
  OWNER TO postgres;
