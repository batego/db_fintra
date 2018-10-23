-- Function: reversion_ws_extracto()

-- DROP FUNCTION reversion_ws_extracto();

CREATE OR REPLACE FUNCTION reversion_ws_extracto()
  RETURNS text AS
$BODY$DECLARE
  respuesta TEXT;
BEGIN
  UPDATE fin.extracto SET fecha_envio_ws =null;
  SELECT INTO respuesta ' Marcas de envio de extracto quitadas.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION reversion_ws_extracto()
  OWNER TO postgres;
