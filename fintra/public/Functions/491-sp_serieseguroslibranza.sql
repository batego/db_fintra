-- Function: sp_serieseguroslibranza()

-- DROP FUNCTION sp_serieseguroslibranza();

CREATE OR REPLACE FUNCTION sp_serieseguroslibranza()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'CXP_SEG_LIBRA'
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 9, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'CXP_SEG_LIBRA' and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_serieseguroslibranza()
  OWNER TO postgres;
