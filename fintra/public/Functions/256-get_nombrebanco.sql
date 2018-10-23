-- Function: get_nombrebanco(text)

-- DROP FUNCTION get_nombrebanco(text);

CREATE OR REPLACE FUNCTION get_nombrebanco(text)
  RETURNS text AS
$BODY$DECLARE
  codBanco ALIAS FOR $1;
  nomBanco TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su codigo.
SELECT INTO nomBanco table_code
FROM tablagen
WHERE table_type='THBANKFID' AND reg_status='' AND referencia=codBanco;

RETURN nomBanco;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombrebanco(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_nombrebanco(text) IS 'Obtener el nombre de un banco a partir de su codigo.';
