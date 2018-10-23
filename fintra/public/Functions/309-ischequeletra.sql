-- Function: ischequeletra(text)

-- DROP FUNCTION ischequeletra(text);

CREATE OR REPLACE FUNCTION ischequeletra(text)
  RETURNS text AS
$BODY$DECLARE
  document ALIAS FOR $1;
  tipo TEXT;
BEGIN
  
  SELECT INTO tipo concepto
  FROM con.factura
  WHERE documento = document;

  RETURN tipo;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION ischequeletra(text)
  OWNER TO postgres;

