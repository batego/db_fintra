-- Function: cambiar_contratista_usuario(text, text)

-- DROP FUNCTION cambiar_contratista_usuario(text, text);

CREATE OR REPLACE FUNCTION cambiar_contratista_usuario(text, text)
  RETURNS text AS
$BODY$DECLARE
  nuevo_contratista ALIAS FOR $1;
  usuario ALIAS FOR $2;
  respuesta TEXT;
BEGIN
  UPDATE usuarios
	SET nits_propietario =nuevo_contratista
	WHERE (idusuario)=(usuario);
  SELECT INTO respuesta ' ModificaciÃ³n terminada.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_contratista_usuario(text, text)
  OWNER TO postgres;
