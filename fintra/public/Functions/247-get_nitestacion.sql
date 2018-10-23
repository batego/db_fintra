-- Function: get_nitestacion(text)

-- DROP FUNCTION get_nitestacion(text);

CREATE OR REPLACE FUNCTION get_nitestacion(text)
  RETURNS text AS
$BODY$DECLARE
  loginestacion ALIAS FOR $1;
  nitestacion TEXT;

BEGIN

  SELECT INTO nitestacion nit
  from estacion_gasolina
  where login=loginestacion;

  RETURN nitestacion;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nitestacion(text)
  OWNER TO postgres;
