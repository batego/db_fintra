-- Function: solicitar_cambiar_clave(text)

-- DROP FUNCTION solicitar_cambiar_clave(text);

CREATE OR REPLACE FUNCTION solicitar_cambiar_clave(text)
  RETURNS text AS
$BODY$DECLARE
  usuari ALIAS FOR $1;
  respuesta TEXT;
BEGIN
  UPDATE usuarios SET cambioclavelogin =TRUE WHERE UPPER(idusuario) = UPPER(usuari);
  SELECT INTO respuesta ' Proceso ejecutado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION solicitar_cambiar_clave(text)
  OWNER TO postgres;
