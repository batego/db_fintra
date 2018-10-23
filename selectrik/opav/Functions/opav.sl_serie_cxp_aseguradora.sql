-- Function: opav.sl_serie_cxp_aseguradora()

-- DROP FUNCTION opav.sl_serie_cxp_aseguradora();

CREATE OR REPLACE FUNCTION opav.sl_serie_cxp_aseguradora()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'FAS'
	and reg_status='';

	secuencia := retcod.prefix||'S'||lpad(retcod.last_number, 7, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'FAS' and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_serie_cxp_aseguradora()
  OWNER TO postgres;
