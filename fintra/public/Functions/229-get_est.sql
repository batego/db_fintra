-- Function: get_est(text)

-- DROP FUNCTION get_est(text);

CREATE OR REPLACE FUNCTION get_est(text)
  RETURNS text AS
$BODY$Declare
  v ALIAS FOR $1;
  retcod TEXT;
begin
	if
          v = 'P' then retcod := 'ACEPTADO';
    elsif v = 'A' then retcod := 'APROBADO';
    elsif v = 'R' then retcod := 'RECHAZADOS';
    elsif v = 'T' then retcod := 'TRANSFERIDOS';
    elsif v = 'PD' then retcod := 'ACEPTADO_DOMESA';
    elsif v = 'RD' then retcod := 'RECHAZADO_DOMESA';
    elsif v = 'AD' then retcod := 'APROBADO_DOMESA';
    elsif v = 'V' then retcod := 'AVALADO';
    elsif v = 'Q' then retcod := 'PRE_ACEPTADO';
    elsif v = 'D' then retcod := 'DESISTIDO';
    elsif v = 'PR' then retcod := 'PERFECCIONADO';
    elsif v = 'L' then retcod := 'LEGALIZAR';
    elsif v = 'E' then retcod := 'POR_RELIQUIDAR';
    elsif v = 'F' then retcod := 'POR_RELIQUIDAR';
	end if;
return retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_est(text)
  OWNER TO fintravaloressa;
