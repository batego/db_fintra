-- Function: valida_hora_anticipos(text)

-- DROP FUNCTION valida_hora_anticipos(text);

CREATE OR REPLACE FUNCTION valida_hora_anticipos(text)
  RETURNS text AS
$BODY$Declare
  creation_date ALIAS FOR $1;
  resp TEXT;
  /******** retorna la hora 06:00:00 si la fecha de anticipos es depsues de 8 pm*****************/

begin

	IF creation_date::TIME > '20:00:00'::TIME
	THEN  resp:='06:00:00'::TIME;
	ELSE
		IF
		creation_date::TIME < '06:00:00'::TIME
		THEN resp:='06:00:00'::TIME;
		ELSE  resp:= creation_date::TIME;
		END IF;

	END IF;

	RETURN resp;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION valida_hora_anticipos(text)
  OWNER TO postgres;
