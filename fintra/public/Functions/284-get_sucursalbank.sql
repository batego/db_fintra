-- Function: get_sucursalbank(text)

-- DROP FUNCTION get_sucursalbank(text);

CREATE OR REPLACE FUNCTION get_sucursalbank(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
begin
 --Aumento y saco el ultimo indice de la tabla de series
	select into retcod bank_account_no
	from proveedor
	where nit=varpar;

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_sucursalbank(text)
  OWNER TO postgres;
