-- Function: get_mensaje_traducido(text)

-- DROP FUNCTION get_mensaje_traducido(text);

CREATE OR REPLACE FUNCTION get_mensaje_traducido(text)
  RETURNS text AS
$BODY$DECLARE
  _msj ALIAS FOR $1;
  _respuesta TEXT;
  _traducciones RECORD;
  _reemplazable TEXT;
  _reemplazo TEXT;
BEGIN
  SELECT INTO _respuesta _msj;

  FOR _traducciones IN	(SELECT tg.*
		FROM tablagen tg
		WHERE tg.table_type ='TRADUCCION'
		ORDER BY tg.table_code) LOOP

	_reemplazable :=_traducciones.descripcion;
	_reemplazo :=_traducciones.dato;
	_respuesta=REPLACE(_respuesta,_reemplazable,_reemplazo);

  END LOOP; --_traducciones
RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_mensaje_traducido(text)
  OWNER TO postgres;
