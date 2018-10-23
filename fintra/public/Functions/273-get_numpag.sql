-- Function: get_numpag(text)

-- DROP FUNCTION get_numpag(text);

CREATE OR REPLACE FUNCTION get_numpag(text)
  RETURNS text AS
$BODY$Declare
  nite ALIAS FOR $1;
  retcod TEXT;
  retcod1 TEXT;
  num TEXT;

begin
	--primer select
	select into num conspag
	from consecutivos
	where nit=nite
	and reg_status='';
	--finprimer select

	retcod1=(length(num));
	if (retcod1=1) then
		retcod:='00000'||num;
	else
		if (retcod1=2) then
			retcod:='0000'||num;
		else
			if(retcod1=3) then
				retcod='000'||num;
			else
				if (retcod1=4) then
					retcod='00'||num;
				else

					if (retcod1=5) then
						retcod='00'||num;
					end if;
				end if;
			end if;
		end if;
	end if;
--ACTUALIZO
	UPDATE consecutivos
	set conspag=conspag+1
	where nit = nite
	and reg_status='';

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_numpag(text)
  OWNER TO postgres;
