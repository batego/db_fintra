-- Function: get_bancocxpm(text)

-- DROP FUNCTION get_bancocxpm(text);

CREATE OR REPLACE FUNCTION get_bancocxpm(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
begin
 --Aumento y saco el ultimo indice de la tabla de series
	select into retcod branch_code
	from proveedor
	where nit=varpar;

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_bancocxpm(text)
  OWNER TO postgres;
