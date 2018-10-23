-- Function: opav.get_observaciones_seguimiento2(text)

-- DROP FUNCTION opav.get_observaciones_seguimiento2(text);

CREATE OR REPLACE FUNCTION opav.get_observaciones_seguimiento2(id_sol text)
  RETURNS text AS
$BODY$
DECLARE

 of_ejecucion record;
 obs TEXT := '';
 fech DATE := '009-01-01';

BEGIN

 FOR of_ejecucion
 IN select oe.id_accion, oe.id_actividad, ac.descripcion, fecha, avance, avance_esperado,
	   oe.observaciones
    FROM opav.oferta_ejecucion oe
    INNER JOIN opav.actividades ac on ac.id=oe.id_actividad
    WHERE oe.id_solicitud = id_sol
    AND oe.reg_status=''
    AND oe.observaciones != ''
    ORDER BY oe.fecha
 LOOP
	IF (fech != of_ejecucion.fecha )THEN
		obs = (obs || ('('||of_ejecucion.fecha||')') || E'\r\n');
		fech = of_ejecucion.fecha;
	END IF;
	obs = (obs  || (of_ejecucion.descripcion||':'||of_ejecucion.observaciones)|| E'\r\n')::text;

 END LOOP;

 RETURN obs;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.get_observaciones_seguimiento2(text)
  OWNER TO postgres;
