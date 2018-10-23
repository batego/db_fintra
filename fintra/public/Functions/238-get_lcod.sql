-- Function: get_lcod(text)

-- DROP FUNCTION get_lcod(text);

CREATE OR REPLACE FUNCTION get_lcod(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
  retcod1 TEXT;
  pref TEXT;
  num2 TEXT;
begin
 --Aumento y saco el ultimo indice de la tabla de series
	Select into retcod last_number
	from series
	where document_type=varpar
	and reg_status='';
---Prefijooo
	Select into pref prefix
	from series
	where document_type=varpar
	and reg_status='';
---finprefijo
	retcod1=(length(retcod));
	if (retcod1=1) then
		retcod:=pref||'0000'||retcod;
	else
		if (retcod1=2) then
			retcod:=pref||'000'||retcod;
		else
			if(retcod1=3) then
				retcod=pref||'00'||retcod;
			else
				if (retcod1=4) then
					retcod=pref||'0'||retcod;
				else
					retcod=pref||retcod;
				end if;
			end if;
		end if;
	end if;
--ACTUALIZO
	UPDATE series
	set last_number=last_number+1
	where document_type = varpar
	and reg_status='';

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_lcod(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_lcod(text) IS 'Consigue el ultimo numero generado para el tipo de documento que se le pase como parametro, devuelve el consecutivo para ese tipo e incrementa la serie en 1';
