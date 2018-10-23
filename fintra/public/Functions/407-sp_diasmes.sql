-- Function: sp_diasmes(date)

-- DROP FUNCTION sp_diasmes(date);

CREATE OR REPLACE FUNCTION sp_diasmes(fechaanalizar date)
  RETURNS text AS
$BODY$DECLARE

	_respuesta TEXT;
	MaxdayOnSelect date;
	maxday numeric;

BEGIN
	_respuesta:= '';

	select into MaxdayOnSelect ((date_trunc('month', FechaAnalizar) + interval '1 month') - interval '1 day')::date;
	maxday = substring(MaxdayOnSelect,9)::numeric;

	_respuesta = maxday;

 RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_diasmes(date)
  OWNER TO postgres;
