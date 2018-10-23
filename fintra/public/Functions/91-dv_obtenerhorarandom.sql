-- Function: public.dv_obtenerhorarandom(fecha timestamp without time zone,_numero_solicitud  integer)

-- DROP FUNCTION  public.dv_obtenerhorarandom(fecha timestamp without time zone,_numero_solicitud  integer)

CREATE OR REPLACE FUNCTION public.dv_obtenerhorarandom(fecha timestamp without time zone,_numero_solicitud  integer)
RETURNS text AS 
$BODY$


DECLARE

_HORAS TEXT;

BEGIN
	
		SELECT INTO _HORAS TO_CHAR(FECHA, 'YYYY-MM-DD 18:00:00')::TIMESTAMP + (RANDOM() * (TO_CHAR(FECHA, 'YYYY-MM-DD 08:00:00')::TIMESTAMP - TO_CHAR(FECHA, 'YYYY-MM-DD 18:00:00')::TIMESTAMP))
		FROM SOLICITUD_AVAL WHERE NUMERO_SOLICITUD = _NUMERO_SOLICITUD;
		
	RETURN _HORAS; 
END;

$BODY$
LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION public.dv_obtenerhorarandom (fecha timestamp without time zone,_numero_solicitud  integer)
OWNER TO postgres;