-- Function: get_saldo_pf__ff(text)

-- DROP FUNCTION get_saldo_pf__ff(text);

CREATE OR REPLACE FUNCTION get_saldo_pf__ff(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  saldo TEXT;
BEGIN
  --
  SELECT INTO saldo valor_saldo
  FROM
	con.factura
  WHERE
	documento = codFactura;

  RETURN saldo;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_saldo_pf__ff(text)
  OWNER TO postgres;
