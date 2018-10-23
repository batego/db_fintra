-- Function: get_actividad_economica(text)

-- DROP FUNCTION get_actividad_economica(text);

CREATE OR REPLACE FUNCTION get_actividad_economica(text)
  RETURNS text AS
$BODY$Declare
  _actividad ALIAS FOR $1;
  retcod TEXT;
begin
	SELECT INTO retcod dato from tablagen where referencia = _actividad;
return retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_actividad_economica(text)
  OWNER TO fintravaloressa;
