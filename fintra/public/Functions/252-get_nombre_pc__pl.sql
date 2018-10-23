-- Function: get_nombre_pc__pl(text)

-- DROP FUNCTION get_nombre_pc__pl(text);

CREATE OR REPLACE FUNCTION get_nombre_pc__pl(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  nomCliente TEXT;

BEGIN
  --
  SELECT INTO nomCliente cliente.nomcli
  FROM
	cliente,
	con.factura f
  WHERE
	f.documento = codFactura
	AND f.nit = cliente.nit;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombre_pc__pl(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_nombre_pc__pl(text) IS 'dado un documento del tipo PC,PL o PG devuelve el nombre del cliente asociado a dicho documento';
