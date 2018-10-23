-- Function: get_lote_endoso(text)

-- DROP FUNCTION get_lote_endoso(text);

CREATE OR REPLACE FUNCTION get_lote_endoso(text)
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

	secuencia := retcod.last_number;
	UPDATE series set last_number = last_number+1 where document_type = tipo_req and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_lote_endoso(text)
  OWNER TO postgres;
