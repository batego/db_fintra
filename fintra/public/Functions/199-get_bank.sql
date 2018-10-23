-- Function: get_bank(text)

-- DROP FUNCTION get_bank(text);

CREATE OR REPLACE FUNCTION get_bank(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
begin
 --Aumento y saco el ultimo indice de la tabla de series
	select into retcod banco_transfer
	from proveedor
	where nit=varpar;

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_bank(text)
  OWNER TO postgres;
