-- Function: eg_serie_cxp_selectrik()

-- DROP FUNCTION eg_serie_cxp_selectrik();

CREATE OR REPLACE FUNCTION eg_serie_cxp_selectrik()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'FAP' and id=2683
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 7, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'FAP' and id=2683 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_serie_cxp_selectrik()
  OWNER TO postgres;
