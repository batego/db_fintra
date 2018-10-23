-- Function: cambiar_limite_ws(text, text)

-- DROP FUNCTION cambiar_limite_ws(text, text);

CREATE OR REPLACE FUNCTION cambiar_limite_ws(text, text)
  RETURNS text AS
$BODY$DECLARE
  tabla ALIAS FOR $1;
  limite ALIAS FOR $2;
  respuesta TEXT;
BEGIN
  UPDATE ws.ws_datos_tablas SET condicion =limite WHERE nombre_tabla = 'LIMITE_' || UPPER(tabla);
  SELECT INTO respuesta ' Proceso ejecutado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_limite_ws(text, text)
  OWNER TO postgres;
