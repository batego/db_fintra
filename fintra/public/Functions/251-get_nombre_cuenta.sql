-- Function: get_nombre_cuenta(text)

-- DROP FUNCTION get_nombre_cuenta(text);

CREATE OR REPLACE FUNCTION get_nombre_cuenta(text)
  RETURNS text AS
$BODY$DECLARE
  codCuenta ALIAS FOR $1;
  nomCuenta TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su codigo.
  SELECT INTO nomCuenta nombre_largo
  FROM con.cuentas
  WHERE cuenta = codCuenta;

  RETURN nomCuenta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombre_cuenta(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_nombre_cuenta(text) IS 'Obtener el nombre de un cuenta a partir de su codigo.';
