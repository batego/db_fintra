-- Function: cambiar_correo_contratista(text, text)

-- DROP FUNCTION cambiar_correo_contratista(text, text);

CREATE OR REPLACE FUNCTION cambiar_correo_contratista(text, text)
  RETURNS text AS
$BODY$DECLARE
  nuevo_correo ALIAS FOR $1;
  contratista ALIAS FOR $2;
  respuesta TEXT;
BEGIN
  UPDATE app_contratistas
	SET email =nuevo_correo
	WHERE (id_contratista)=(contratista);
  SELECT INTO respuesta ' ModificaciÃ³n terminada.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_correo_contratista(text, text)
  OWNER TO postgres;
