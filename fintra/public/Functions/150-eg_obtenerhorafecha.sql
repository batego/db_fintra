-- Function: eg_obtenerhorafecha(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION eg_obtenerhorafecha(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION eg_obtenerhorafecha(fechainicial timestamp without time zone, fechafinal timestamp without time zone)
  RETURNS text AS
$BODY$

DECLARE

_Horas text;

BEGIN
	select into _Horas to_char((FechaInicial - FechaFinal) + (to_char(age(FechaInicial , FechaFinal)*24 ,'DD')||' hour')::interval,'HH24:MI:ss');

	IF ('0101-01-01 00:00:00' IN (fechainicial,fechafinal)) THEN
	   _Horas:='00:00:00';
	END IF;
	RETURN _Horas;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_obtenerhorafecha(timestamp without time zone, timestamp without time zone)
  OWNER TO postgres;
