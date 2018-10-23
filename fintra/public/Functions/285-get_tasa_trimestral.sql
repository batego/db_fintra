-- Function: get_tasa_trimestral(text)

-- DROP FUNCTION get_tasa_trimestral(text);

CREATE OR REPLACE FUNCTION get_tasa_trimestral(text)
  RETURNS text AS
$BODY$DECLARE
  dateTasa ALIAS FOR $1;
  tasa TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³digo.
	select into tasa referencia
	from
		tablagen
	where
		table_type = 'T_TRI_ECA' and
		table_code = dateTasa;
  RETURN tasa;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_tasa_trimestral(text)
  OWNER TO postgres;
