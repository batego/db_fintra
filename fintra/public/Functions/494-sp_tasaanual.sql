-- Function: sp_tasaanual(numeric)

-- DROP FUNCTION sp_tasaanual(numeric);

CREATE OR REPLACE FUNCTION sp_tasaanual(_tasamensual numeric)
  RETURNS numeric AS
$BODY$

DECLARE

	_respuesta numeric := 0;

BEGIN
	--CONSULTA NEGOCIO.
	_respuesta = ((POW(1 + (_TasaMensual / 100), 12) - 1)*100)::NUMERIC(11,3);
	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_tasaanual(numeric)
  OWNER TO postgres;
