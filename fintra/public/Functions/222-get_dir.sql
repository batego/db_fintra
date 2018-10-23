-- Function: get_dir(text)

-- DROP FUNCTION get_dir(text);

CREATE OR REPLACE FUNCTION get_dir(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
begin
 --consigue la direccion del un determinado cliente
	select into retcod direccion
	from cliente
	where codcli=varpar;

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_dir(text)
  OWNER TO postgres;
