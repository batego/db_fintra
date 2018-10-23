-- Function: get_lcod_ing(text, text)

-- DROP FUNCTION get_lcod_ing(text, text);

CREATE OR REPLACE FUNCTION get_lcod_ing(text, text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  num ALIAS FOR $2;
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
	num2=(length(num));


			retcod=pref||retcod;


	if (num2=1)then
		retcod=retcod||0||num;
	else
		retcod=retcod||num;
	end if;

	--LA ACTUALIZACION
	/*UPDATE series
	set last_number=last_number+1
	where document_type = varpar
	and reg_status='';*/
	---finalll
	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_lcod_ing(text, text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_lcod_ing(text, text) IS 'genera un consecutivo para los IF ej: IF0000452';
