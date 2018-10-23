-- Function: calculo_dif_ant(text, text)

-- DROP FUNCTION calculo_dif_ant(text, text);

CREATE OR REPLACE FUNCTION calculo_dif_ant(text, text)
  RETURNS text AS
$BODY$Declare
  creation_date ALIAS FOR $1;
  fecha_transferencia ALIAS FOR $2;
  resp TEXT;
  ft text;

begin
	IF fecha_transferencia!='0099-01-01 00:00:00'
	THEN
			IF creation_date::TIME > '20:00:00'::TIME
			THEN  resp:='06:00:00'::TIME;
			ELSE
				IF
				creation_date::TIME < '06:00:00'::TIME
				THEN resp:='06:00:00'::TIME;
				ELSE  resp:= creation_date::TIME;
				END IF;

			END IF;



			IF fecha_transferencia::TIME > '20:00:00'::TIME
			THEN  ft:= '06:00:00'::TIME;
			ELSE

				IF
				fecha_transferencia::TIME < '06:00:00'::TIME
				THEN ft:='06:00:00'::TIME;
				ELSE  ft:= fecha_transferencia::TIME;
				END IF;

			END IF;



			IF ft::time <  resp::TIME
			THEN
			resp:='00:00:01'::TIME;
			ELSE
			resp:=(ft::time-resp::time)::time;
			END IF;
	ELSE
	resp:='23:59:59'::TIME;
	END IF;

	RETURN resp;

--fecha_transferencia::time-calculo(creation_date)::time


end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION calculo_dif_ant(text, text)
  OWNER TO postgres;
