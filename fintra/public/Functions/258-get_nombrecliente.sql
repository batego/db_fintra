-- Function: get_nombrecliente(text)

-- DROP FUNCTION get_nombrecliente(text);

CREATE OR REPLACE FUNCTION get_nombrecliente(text)
  RETURNS text AS
$BODY$DECLARE
  codCliente ALIAS FOR $1;
  nomCliente TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su codigo.
  SELECT INTO nomCliente nomcli
  FROM cliente
  WHERE codcli = codCliente;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombrecliente(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_nombrecliente(text) IS 'Obtener el nombre de un cliente a partir de su codigo.';
