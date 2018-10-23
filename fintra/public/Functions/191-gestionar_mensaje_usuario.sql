-- Function: gestionar_mensaje_usuario(text, text, text, timestamp without time zone)

-- DROP FUNCTION gestionar_mensaje_usuario(text, text, text, timestamp without time zone);

CREATE OR REPLACE FUNCTION gestionar_mensaje_usuario(text, text, text, timestamp without time zone)
  RETURNS text AS
$BODY$DECLARE
  _loginx ALIAS FOR $1;
  _estado_mensaje ALIAS FOR $2;
  _fec_sistema_java ALIAS FOR $3;
  _fecha_final_mensaje ALIAS FOR $4;
  _fecha_sistema_java TIMESTAMP;
  _respuesta TEXT;
BEGIN
  _fecha_sistema_java:= _fec_sistema_java::TIMESTAMP;
  SELECT INTO _respuesta 'executed.';

  IF (_estado_mensaje LIKE '%2%') THEN
	UPDATE usuarios SET estado_mensaje=REPLACE(estado_mensaje,'2','') WHERE Idusuario =_loginx;
  END IF;
  IF (_estado_mensaje LIKE '%1%' AND _fecha_sistema_java>_fecha_final_mensaje) THEN
	UPDATE usuarios SET estado_mensaje=REPLACE(estado_mensaje,'1','') WHERE Idusuario =_loginx;
  END IF;
  RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION gestionar_mensaje_usuario(text, text, text, timestamp without time zone)
  OWNER TO postgres;
