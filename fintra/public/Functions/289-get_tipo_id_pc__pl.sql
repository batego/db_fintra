-- Function: get_tipo_id_pc__pl(text)

-- DROP FUNCTION get_tipo_id_pc__pl(text);

CREATE OR REPLACE FUNCTION get_tipo_id_pc__pl(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  nomCliente TEXT;

BEGIN
  --
  SELECT INTO nomCliente cliente.tipo_id
  From
	cliente,
	con.factura f
  WHERE
	f.documento = codFactura
	AND f.nit = cliente.nit;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_tipo_id_pc__pl(text)
  OWNER TO postgres;
