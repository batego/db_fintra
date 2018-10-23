-- Function: get_sel(text)

-- DROP FUNCTION get_sel(text);

CREATE OR REPLACE FUNCTION get_sel(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
begin
 --Aumento y saco el ultimo indice de la tabla de series
	Select into retcod  prefix || last_number
	from series
	where document_type=varpar
	and reg_status='';
	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_sel(text)
  OWNER TO postgres;
