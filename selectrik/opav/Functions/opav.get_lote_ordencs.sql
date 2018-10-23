-- Function: opav.get_lote_ordencs(character varying)

-- DROP FUNCTION opav.get_lote_ordencs(character varying);

CREATE OR REPLACE FUNCTION opav.get_lote_ordencs(character varying)
  RETURNS text AS
$BODY$

DECLARE

  _tipoSolicitud ALIAS FOR $1;
  secuencia TEXT;
  retcod record;

BEGIN

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
ALTER FUNCTION opav.get_lote_ordencs(character varying)
  OWNER TO postgres;
