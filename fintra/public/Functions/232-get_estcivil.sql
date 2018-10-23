-- Function: get_estcivil(text)

-- DROP FUNCTION get_estcivil(text);

CREATE OR REPLACE FUNCTION get_estcivil(text)
  RETURNS text AS
$BODY$Declare
  v ALIAS FOR $1;
  retcod TEXT;
begin
	if
          v = 'C' then retcod := 'CASADO';
    elsif v = 'U' then retcod := 'UNION LIBRE';
    elsif v = 'S' then retcod := 'SOLTERO';
    elsif v = 'V' then retcod := 'VIUDO';
    elsif v = 'E' then retcod := 'SEPARADO';


	end if;
return retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_estcivil(text)
  OWNER TO fintravaloressa;
