-- Function: get_nombc(text)

-- DROP FUNCTION get_nombc(text);

CREATE OR REPLACE FUNCTION get_nombc(text)
  RETURNS text AS
$BODY$DECLARE
  codCliente ALIAS FOR $1;
  nomCliente TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³digo.
  SELECT INTO nomCliente nomcli
  FROM cliente
  WHERE nit = codCliente;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombc(text)
  OWNER TO postgres;
