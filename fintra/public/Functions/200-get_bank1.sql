-- Function: get_bank1(text)

-- DROP FUNCTION get_bank1(text);

CREATE OR REPLACE FUNCTION get_bank1(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
begin
 --Aumento y saco el ultimo indice de la tabla de series
	select into retcod suc_transfer
	from proveedor
	where nit=varpar;

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_bank1(text)
  OWNER TO postgres;
