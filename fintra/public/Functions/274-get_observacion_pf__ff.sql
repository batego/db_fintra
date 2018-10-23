-- Function: get_observacion_pf__ff(text)

-- DROP FUNCTION get_observacion_pf__ff(text);

CREATE OR REPLACE FUNCTION get_observacion_pf__ff(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  docrel TEXT;
BEGIN
  --
  SELECT INTO docrel observacion
  FROM
	con.factura
  WHERE
	documento = codFactura;

  RETURN docrel;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_observacion_pf__ff(text)
  OWNER TO postgres;
