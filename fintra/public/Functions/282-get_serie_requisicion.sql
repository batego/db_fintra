-- Function: get_serie_requisicion(text)

-- DROP FUNCTION get_serie_requisicion(text);

CREATE OR REPLACE FUNCTION get_serie_requisicion(text)
  RETURNS text AS
$BODY$

DECLARE

  tipo_req ALIAS FOR $1;
  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = tipo_req
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

	UPDATE series set last_number = last_number+1 where document_type = tipo_req and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_serie_requisicion(text)
  OWNER TO postgres;
