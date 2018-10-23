-- Function: get_destablagen(text, text)

-- DROP FUNCTION get_destablagen(text, text);

CREATE OR REPLACE FUNCTION get_destablagen(text, text)
  RETURNS text AS
$BODY$DECLARE
  codigo ALIAS FOR $1;
  tabla ALIAS FOR $2;
  description TEXT;

BEGIN
  -- Encontrar una descripcion de tablagen con el codigo y la tabla.
  SELECT INTO description descripcion
  FROM tablagen
  WHERE table_code = codigo AND table_type = tabla ;

  RETURN description;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_destablagen(text, text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_destablagen(text, text) IS 'Encontrar una descripcion de tablagen con el codigo y la tabla.';
