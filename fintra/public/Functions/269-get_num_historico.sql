-- Function: get_num_historico()

-- DROP FUNCTION get_num_historico();

CREATE OR REPLACE FUNCTION get_num_historico()
  RETURNS text AS
$BODY$Declare
  num TEXT;
  retcod TEXT;
begin
 --Saco el ultimo indice de la tabla de series para los historicos
	select into num last_number
	FROM series
	WHERE document_type = 'HIST'
	AND reg_status != 'A';

	retcod=(length(num));
	if (retcod=1) then
		num:='00000'||num;
	else
		if (retcod=2) then
			num:='0000'||num;
		else
			if(retcod=3) then
				num='000'||num;
			else
				if (retcod=4) then
					num='00'||num;
				else
					if (retcod=5) then
						num='0'||num;
					end if;
				end if;
			end if;
		end if;
	end if;

	--ACTUALIZO
	UPDATE series
	set last_number=last_number+1
	where document_type = 'HIST'
	AND reg_status != 'A';



	RETURN 'DC'||num;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_num_historico()
  OWNER TO postgres;
