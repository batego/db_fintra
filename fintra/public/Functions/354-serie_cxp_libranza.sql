-- Function: serie_cxp_libranza()

-- DROP FUNCTION serie_cxp_libranza();

CREATE OR REPLACE FUNCTION serie_cxp_libranza()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'CXP_LIBRANZA' and id=2688
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 7, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'CXP_LIBRANZA' and id=2688 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION serie_cxp_libranza()
  OWNER TO postgres;
