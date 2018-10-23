-- Function: get_nd_ia(text)

-- DROP FUNCTION get_nd_ia(text);

CREATE OR REPLACE FUNCTION get_nd_ia(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  docrel TEXT;
BEGIN
  --
  SELECT INTO docrel f.documento
  FROM con.factura f, con.factura_detalle d
  WHERE
	d.numero_remesa = codFactura
	AND d.documento = f.documento
	AND f.tipo_documento = 'ND'
	AND d.reg_status != 'A';

  RETURN docrel;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nd_ia(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_nd_ia(text) IS 'Devuelve la nd asociada a la ia pasada por parametro';
