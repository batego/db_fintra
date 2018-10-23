-- Function: cambiar_disparador_alarma(text)

-- DROP FUNCTION cambiar_disparador_alarma(text);

CREATE OR REPLACE FUNCTION cambiar_disparador_alarma(text)
  RETURNS text AS
$BODY$DECLARE
  min ALIAS FOR $1;
  respuesta TEXT;
  cont integer;
  cad TEXT;
BEGIN
  cont=min;
  cad='';
  WHILE cont > 0  LOOP
    cont=cont-1;
    cad=cad || 'S';
  END LOOP;
  IF (cad='') THEN
	cad='S';
  END IF;
  UPDATE ws.ws_datos_tablas SET condicion=cad WHERE nombre_campo = 'DISPARADOR_ALARMA';
  SELECT INTO respuesta ' Proceso ejecutado.' 	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_disparador_alarma(text)
  OWNER TO postgres;
