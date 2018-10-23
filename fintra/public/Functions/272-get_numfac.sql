-- Function: get_numfac(text)

-- DROP FUNCTION get_numfac(text);

CREATE OR REPLACE FUNCTION get_numfac(text)
  RETURNS text AS
$BODY$DECLARE
  codfact ALIAS FOR $1;
  nomCliente TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³digo.
  SELECT INTO nomCliente nomcli
	FROM view_fact
	WHERE documento=codfact	;

RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_numfac(text)
  OWNER TO postgres;
