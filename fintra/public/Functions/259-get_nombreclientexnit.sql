-- Function: get_nombreclientexnit(text)

-- DROP FUNCTION get_nombreclientexnit(text);

CREATE OR REPLACE FUNCTION get_nombreclientexnit(text)
  RETURNS text AS
$BODY$DECLARE
  nitCliente ALIAS FOR $1;
  nomCliente TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su codigo.
  SELECT INTO nomCliente nomcli
  FROM cliente
  WHERE nit = nitCliente
  limit 1;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombreclientexnit(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_nombreclientexnit(text) IS 'Obtener el nombre de un cliente a partir de su nit.';
