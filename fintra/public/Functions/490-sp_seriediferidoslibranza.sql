-- Function: sp_seriediferidoslibranza()

-- DROP FUNCTION sp_seriediferidoslibranza();

CREATE OR REPLACE FUNCTION sp_seriediferidoslibranza()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'LI'
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 9, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'LI' and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_seriediferidoslibranza()
  OWNER TO postgres;
