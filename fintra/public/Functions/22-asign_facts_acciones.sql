-- Function: asign_facts_acciones(text, text, text, text)

-- DROP FUNCTION asign_facts_acciones(text, text, text, text);

CREATE OR REPLACE FUNCTION asign_facts_acciones(text, text, text, text)
  RETURNS text AS
$BODY$DECLARE
  _fact ALIAS FOR $1;
  _accion ALIAS FOR $2;
  _usuarioact ALIAS FOR $3;
  _fecfactconf ALIAS FOR $4;
  _contratista CHARACTER VARYING (5);
  _respuesta TEXT;
BEGIN
  UPDATE opav.acciones
  SET factura_contratista=_fact, usuario_factura_contratista = _usuarioact
  WHERE id_accion=_accion AND fecha_factura_contratista_final='0099-01-01 00:00:00';

  SELECT INTO _contratista contratista FROM opav.acciones WHERE id_accion=_accion;

  UPDATE opav.acciones
  SET fecha_factura_contratista=_fecfactconf::TIMESTAMP,
	last_update=NOW(),
	user_update=_usuarioact
	,creation_fecha_factura_contratista=NOW()--20100825
  WHERE contratista=_contratista
		AND factura_contratista=_fact
		AND fecha_factura_contratista_final='0099-01-01 00:00:00';

  SELECT INTO _respuesta 'Done';
RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION asign_facts_acciones(text, text, text, text)
  OWNER TO postgres;
