-- Function: etes.serie_cxp_eds()

-- DROP FUNCTION etes.serie_cxp_eds();

CREATE OR REPLACE FUNCTION etes.serie_cxp_eds()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = '004' and id=2668
	and reg_status='';

	secuencia := retcod.prefix||'S'||lpad(retcod.last_number, 7, '0');

	UPDATE series set last_number = last_number+1 where document_type = '004' and id=2668 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.serie_cxp_eds()
  OWNER TO postgres;
