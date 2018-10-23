-- Function: get_num(text)

-- DROP FUNCTION get_num(text);

CREATE OR REPLACE FUNCTION get_num(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
  retcod1 TEXT;
  pref TEXT;
  num2 TEXT;
begin
 --Aumento y saco el ultimo indice de la tabla de series
	Select into retcod last_number
	from series
	where document_type=varpar
	and reg_status='';
---Prefijooo
	Select into pref prefix
	from series
	where document_type=varpar
	and reg_status='';
---finprefijo
	retcod1=(length(retcod));

--ACTUALIZO
	UPDATE series
	set last_number=last_number+1
	where document_type = varpar
	and reg_status='';

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_num(text)
  OWNER TO postgres;
