-- Function: sp_serie_cxp_transfer()

-- DROP FUNCTION sp_serie_cxp_transfer();

CREATE OR REPLACE FUNCTION sp_serie_cxp_transfer()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'FAP' and id=2684
	and reg_status='';

	secuencia := retcod.prefix||'P'||lpad(retcod.last_number, 9, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'FAP' and id=2684 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_serie_cxp_transfer()
  OWNER TO postgres;
