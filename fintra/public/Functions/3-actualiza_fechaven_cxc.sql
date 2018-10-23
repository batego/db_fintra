-- Function: actualiza_fechaven_cxc(text, text)

-- DROP FUNCTION actualiza_fechaven_cxc(text, text);

CREATE OR REPLACE FUNCTION actualiza_fechaven_cxc(text, text)
  RETURNS text AS
$BODY$DECLARE

  doc TEXT;

BEGIN
  doc = 'Actualizado';
 update con.factura set fecha_vencimiento = $1::date where documento=$2 and tipo_documento ='FAC';


  RETURN doc;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualiza_fechaven_cxc(text, text)
  OWNER TO postgres;
COMMENT ON FUNCTION actualiza_fechaven_cxc(text, text) IS 'actualizar fecha cxc.';
