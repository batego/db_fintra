-- Function: getbanco(text)

-- DROP FUNCTION getbanco(text);

CREATE OR REPLACE FUNCTION getbanco(text)
  RETURNS text AS
$BODY$Declare
  var ALIAS FOR $1;
  retcod TEXT;
begin
 --Buscamos el banco
	select into retcod formato
	from banco 
	where branch_code=var
	and formato='S';
	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION getbanco(text)
  OWNER TO postgres;

