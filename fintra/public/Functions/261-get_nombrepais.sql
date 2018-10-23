-- Function: get_nombrepais(text)

-- DROP FUNCTION get_nombrepais(text);

CREATE OR REPLACE FUNCTION get_nombrepais(text)
  RETURNS text AS
$BODY$DECLARE
  codpaisr ALIAS FOR $1;
  nompaisr TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su codigo.
  SELECT INTO nompaisr country_name
  FROM pais
  WHERE country_code = codpaisr;

  RETURN nompaisr;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombrepais(text)
  OWNER TO postgres;
