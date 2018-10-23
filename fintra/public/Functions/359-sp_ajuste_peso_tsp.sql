-- Function: sp_ajuste_peso_tsp(character varying)

-- DROP FUNCTION sp_ajuste_peso_tsp(character varying);

CREATE OR REPLACE FUNCTION sp_ajuste_peso_tsp(anticipo character varying)
  RETURNS text AS
$BODY$DECLARE
	_respuesta TEXT;
BEGIN
	_respuesta:= ' Proceso Exitoso';

 RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_ajuste_peso_tsp(character varying)
  OWNER TO postgres;
