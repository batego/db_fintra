-- Function: get_num_prestamo()

-- DROP FUNCTION get_num_prestamo();

CREATE OR REPLACE FUNCTION get_num_prestamo()
  RETURNS text AS
$BODY$Declare
  num TEXT;
  retcod TEXT;
begin
 --Saco el ultimo indice de la tabla de series para el prestamo
	select into num last_number
	FROM series
	WHERE document_type = 'PRESTAMO'
	AND reg_status != 'A';

	retcod=(length(num));
	if (retcod=1) then
		num:='000000'||num;
	else
		if (retcod=2) then
			num:='00000'||num;
		else
			if(retcod=3) then
				num='0000'||num;
			else
				if (retcod=4) then
					num='000'||num;
				else
					if (retcod=5) then
						num='00'||num;
					else
						if (retcod=6) then
						   num = '0'||num;
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;

	RETURN 'PE'||num;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_num_prestamo()
  OWNER TO postgres;
