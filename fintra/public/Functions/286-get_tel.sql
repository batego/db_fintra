-- Function: get_tel(text)

-- DROP FUNCTION get_tel(text);

CREATE OR REPLACE FUNCTION get_tel(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
begin
 --Aumento y saco el ultimo indice de la tabla de series
	select into retcod telefono||'-'||telcontacto
	from cliente
	where codcli=varpar;

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_tel(text)
  OWNER TO postgres;
