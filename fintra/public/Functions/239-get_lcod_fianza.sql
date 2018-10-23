-- Function: get_lcod_fianza(text)

-- DROP FUNCTION get_lcod_fianza(text);

CREATE OR REPLACE FUNCTION get_lcod_fianza(text)
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
	Select into pref prefix||CASE WHEN (document_type='CXP_FIANZA_TEMP') THEN 'T' ELSE 'D' END
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
ALTER FUNCTION get_lcod_fianza(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_lcod_fianza(text) IS 'Genera consecutivo para la cxp de fianza, devuelve el consecutivo para ese tipo e incrementa la serie en 1';
