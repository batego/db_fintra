-- Function: etes.serie_cxc_propietario()

-- DROP FUNCTION etes.serie_cxc_propietario();

CREATE OR REPLACE FUNCTION etes.serie_cxc_propietario()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'FATSP' and id=39
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 8, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'FATSP' and id=39 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.serie_cxc_propietario()
  OWNER TO postgres;
