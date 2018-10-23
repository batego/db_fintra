-- Function: get_fecha_ultimo_pago_pf__ff(text)

-- DROP FUNCTION get_fecha_ultimo_pago_pf__ff(text);

CREATE OR REPLACE FUNCTION get_fecha_ultimo_pago_pf__ff(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  fecha TEXT;
BEGIN
  --
  SELECT INTO fecha fecha_ultimo_pago
  FROM
	con.factura
  WHERE
	documento = codFactura;

  RETURN fecha;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_fecha_ultimo_pago_pf__ff(text)
  OWNER TO postgres;
