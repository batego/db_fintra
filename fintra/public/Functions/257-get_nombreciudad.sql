-- Function: get_nombreciudad(text)

-- DROP FUNCTION get_nombreciudad(text);

CREATE OR REPLACE FUNCTION get_nombreciudad(text)
  RETURNS text AS
$BODY$DECLARE
  codciur ALIAS FOR $1;
  nomciur TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su codigo.
  SELECT INTO nomciur nomciu
  FROM ciudad
  WHERE codciu = codciur;

  RETURN nomciur;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombreciudad(text)
  OWNER TO postgres;
