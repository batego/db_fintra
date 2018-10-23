-- Function: get_actividad(text)

-- DROP FUNCTION get_actividad(text);

CREATE OR REPLACE FUNCTION get_actividad(text)
  RETURNS text AS
$BODY$Declare
  v ALIAS FOR $1;
  retcod TEXT;
begin
	if
          v = 'SOL' then retcod := 'LIQUIDACION';
    elsif v = 'LIQ' then retcod := 'RADICACION';
    elsif v = 'RAD' then retcod := 'REFERECIACION';
    elsif v = 'REF' then retcod := 'ANALISIS';
    elsif v = 'ANA' then retcod := 'DECISION';
    elsif v = 'DEC' then retcod := 'FORMALIZACION';
    elsif v = 'FOR' then retcod := 'DESEMBOLSO';
	end if;
return retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_actividad(text)
  OWNER TO fintravaloressa;
