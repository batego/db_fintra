-- Function: get_nombre_pf__ff(text)

-- DROP FUNCTION get_nombre_pf__ff(text);

CREATE OR REPLACE FUNCTION get_nombre_pf__ff(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  nomCliente TEXT;
  docrel TEXT;
BEGIN
  --
  SELECT INTO docrel observacion
  FROM
	con.factura
  WHERE
	documento = codFactura;

  SELECT INTO nomCliente cliente.nomcli
  FROM
	cliente,
	con.factura f
  WHERE
	f.documento = docrel
	AND f.nit = cliente.nit;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombre_pf__ff(text)
  OWNER TO postgres;
