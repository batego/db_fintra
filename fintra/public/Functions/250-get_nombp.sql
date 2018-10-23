-- Function: get_nombp(text)

-- DROP FUNCTION get_nombp(text);

CREATE OR REPLACE FUNCTION get_nombp(text)
  RETURNS text AS
$BODY$DECLARE
  codCliente ALIAS FOR $1;
  nomCliente TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³digo.
  SELECT INTO nomCliente payment_name
  FROM proveedor
  WHERE nit = codCliente;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombp(text)
  OWNER TO postgres;
