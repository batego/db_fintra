-- Function: cambiar_contratista_accion(text, text, text)

-- DROP FUNCTION cambiar_contratista_accion(text, text, text);

CREATE OR REPLACE FUNCTION cambiar_contratista_accion(text, text, text)
  RETURNS text AS
$BODY$DECLARE
  _id_accion ALIAS FOR $1;
  _id_solicitud ALIAS FOR $2;
  _nuevo_contra ALIAS FOR $3;
  respuesta TEXT;
BEGIN
  UPDATE OPAV.acciones
  SET contratista=COALESCE((SELECT id_contratista FROM OPAV.app_contratistas WHERE descripcion=UPPER(_nuevo_contra)),contratista)
  WHERE id_accion=_id_accion AND id_solicitud=_id_solicitud AND estado NOT IN ('110');
  SELECT INTO respuesta ' ModificaciÃ³n terminada.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_contratista_accion(text, text, text)
  OWNER TO postgres;
