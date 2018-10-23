-- Function: get_conlet(text)

-- DROP FUNCTION get_conlet(text);

CREATE OR REPLACE FUNCTION get_conlet(text)
  RETURNS text AS
$BODY$Declare
  nite ALIAS FOR $1;
  retcod TEXT;
  retcod1 TEXT;
begin
	select into retcod cast(subst as numeric)+conslet
	from consecutivos
	where nit=nite
	and reg_status='';
--ACTUALIZO
	UPDATE consecutivos
	set conslet=conslet+1
	where nit = nite
	and reg_status='';

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_conlet(text)
  OWNER TO postgres;
