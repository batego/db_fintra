-- Function: get_nombreagencia(text)

-- DROP FUNCTION get_nombreagencia(text);

CREATE OR REPLACE FUNCTION get_nombreagencia(text)
  RETURNS text AS
$BODY$DECLARE
  codAgencia ALIAS FOR $1;
  nomAgencia TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su cÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â³digo.
  SELECT INTO nomAgencia nombre
  FROM agencia
  WHERE id_agencia = codAgencia;

  RETURN nomAgencia;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombreagencia(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_nombreagencia(text) IS 'Obtener el nombre de la ciudad a partir de su codigo.';
