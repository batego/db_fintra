-- Function: cambiar_minuto_tabla_ws(text, text)

-- DROP FUNCTION cambiar_minuto_tabla_ws(text, text);

CREATE OR REPLACE FUNCTION cambiar_minuto_tabla_ws(text, text)
  RETURNS text AS
$BODY$DECLARE
  minutox ALIAS FOR $1;
  pkx ALIAS FOR $2;
  respuesta TEXT;
BEGIN
  UPDATE ws.ejecuciones_webservice_client SET minuto=CAST (minutox AS integer), LAST_UPDATE=NOW() WHERE pk=pkx;
  SELECT INTO respuesta ' Proceso ejecutado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_minuto_tabla_ws(text, text)
  OWNER TO postgres;
