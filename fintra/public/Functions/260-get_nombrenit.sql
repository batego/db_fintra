-- Function: get_nombrenit(text)

-- DROP FUNCTION get_nombrenit(text);

CREATE OR REPLACE FUNCTION get_nombrenit(text)
  RETURNS text AS
$BODY$DECLARE
  codNit ALIAS FOR $1;
  nomNit TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su cÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â³digo.
  SELECT INTO nomNit nombre
  FROM nit
  WHERE cedula = codNit;

  RETURN nomNit;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombrenit(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_nombrenit(text) IS 'Obtener el nombre de un tercero a partir de su nit o cedula.';
