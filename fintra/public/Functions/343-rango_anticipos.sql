-- Function: rango_anticipos(text)

-- DROP FUNCTION rango_anticipos(text);

CREATE OR REPLACE FUNCTION rango_anticipos(text)
  RETURNS text AS
$BODY$Declare

  diferencia  ALIAS FOR $1;
  resp TEXT;

begin

	IF diferencia::TIME  >= '00:00:00'::TIME  AND diferencia::TIME   <='00:30:00'
	THEN  resp:='ENTRE 0 Y 30 MIN';
	END IF;

	IF diferencia::TIME  > '00:30:00'::TIME  AND diferencia::TIME   <='00:45:00'
	THEN  resp:='ENTRE 31 MIN Y 45 MIN';
	END IF;

	IF diferencia::TIME  > '00:45:00'::TIME  AND diferencia::TIME   <='00:59:00'
	THEN  resp:='ENTRE 46 MIN Y 60 MIN';
	END IF;

	IF diferencia::TIME  > '01:00:00'::TIME  AND diferencia::TIME   <='02:00:00'
	THEN  resp:='ENTRE 1 Y 2 HORAS';
	END IF;

	IF diferencia::TIME  > '02:00:00'::TIME
	THEN  resp:=' > 2 HORAS';
	END IF;

	IF diferencia::TIME  = '23:59:59'::TIME
	THEN  resp:='NO APLICA (NT)';
	END IF;

	RETURN resp;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION rango_anticipos(text)
  OWNER TO postgres;
