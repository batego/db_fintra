-- Function: get_bank1(text, text)

-- DROP FUNCTION get_bank1(text, text);

CREATE OR REPLACE FUNCTION get_bank1(text, text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  param  ALIAS FOR $2;
  retcod TEXT;
begin
 --Aumento y saco el ultimo indice de la tabla de series
	select into retcod (param)
	from proveedor
	where nit=varpar;

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_bank1(text, text)
  OWNER TO postgres;
