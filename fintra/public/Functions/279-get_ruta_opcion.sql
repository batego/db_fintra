-- Function: get_ruta_opcion(numeric)

-- DROP FUNCTION get_ruta_opcion(numeric);

CREATE OR REPLACE FUNCTION get_ruta_opcion(numeric)
  RETURNS text AS
$BODY$DECLARE
  _opcion ALIAS FOR $1;
  _ruta TEXT:='';
  _id_padre NUMERIC(8):=0;
  _nombre_padre CHARACTER(60):='';
  _sw INTEGER = 1;
  _buscable NUMERIC(8):=0;
BEGIN
  _buscable:=_opcion;
  WHILE (_sw != 0) LOOP
	SELECT INTO _id_padre, _nombre_padre
		     id_padre, (SELECT md2.nombre FROM menu_dinamico md2 WHERE md2.id_opcion=md.id_padre) AS namefather
	FROM menu_dinamico md
	WHERE md.id_opcion=_buscable;
	_ruta := _nombre_padre || ' --- ' || _ruta ;
	IF (_id_padre=0) THEN
		_sw:=0;
	END IF;
	_buscable:=_id_padre;
  END LOOP;
  _ruta:=REPLACE( _ruta,'SLT --- ','');
  RETURN _ruta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_ruta_opcion(numeric)
  OWNER TO postgres;
