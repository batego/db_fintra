-- Function: opav.get_serie_solicitud_ocs(integer)

-- DROP FUNCTION opav.get_serie_solicitud_ocs(integer);

CREATE OR REPLACE FUNCTION opav.get_serie_solicitud_ocs(integer)
  RETURNS text AS
$BODY$

DECLARE

  tipo_solicitud ALIAS FOR $1;
  _tipoSolicitud varchar;
  secuencia TEXT;
  retcod record;

BEGIN

	if ( tipo_solicitud = 1 ) then _tipoSolicitud = 'PREFIX_SOLC'; else  _tipoSolicitud = 'PREFIX_SOLS'; end if;

	Select into retcod *
	from series
	where document_type = _tipoSolicitud
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

	UPDATE series set last_number = last_number+1 where document_type = _tipoSolicitud and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.get_serie_solicitud_ocs(integer)
  OWNER TO postgres;
