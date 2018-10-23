-- Function: get_valor_factura_pf__ff(text)

-- DROP FUNCTION get_valor_factura_pf__ff(text);

CREATE OR REPLACE FUNCTION get_valor_factura_pf__ff(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  valor TEXT;
BEGIN
  --
  SELECT INTO valor valor_factura
  FROM
	con.factura
  WHERE
	documento = codFactura;

  RETURN valor;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_valor_factura_pf__ff(text)
  OWNER TO postgres;
