-- Function: get_codnit(text)

-- DROP FUNCTION get_codnit(text);

CREATE OR REPLACE FUNCTION get_codnit(text)
  RETURNS text AS
$BODY$DECLARE
  codCliente ALIAS FOR $1;
  nomCliente TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³digo.
  SELECT INTO nomCliente codcli
  FROM cliente
  WHERE nit = codCliente;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_codnit(text)
  OWNER TO postgres;
