-- Function: get_num_egreso_libranza()

-- DROP FUNCTION get_num_egreso_libranza();

CREATE OR REPLACE FUNCTION get_num_egreso_libranza()
  RETURNS text AS
$BODY$

DECLARE

	num TEXT;
	retcod TEXT;

BEGIN

	--Saco el ultimo indice de la tabla de series para el egreso
	SELECT INTO num last_number
	FROM series
	WHERE document_type = 'EGRESO'
	AND reg_status != 'A';

	retcod=(length(num));

	if ( retcod=1 ) then
		num:='0000'||num;
	else
		if ( retcod=2 ) then
			num:='000'||num;
		else
			if( retcod=3 ) then
				num='00'||num;
			else
				if ( retcod=4 ) then
					num='0'||num;
				end if;
			end if;
		end if;
	end if;

	UPDATE series SET last_number = last_number+1 WHERE document_type = 'EGRESO' AND reg_status = '';

	RETURN 'EG'||num;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_num_egreso_libranza()
  OWNER TO postgres;
