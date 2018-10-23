-- Function: etes.serie_egreso_propietario()

-- DROP FUNCTION etes.serie_egreso_propietario();

CREATE OR REPLACE FUNCTION etes.serie_egreso_propietario()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'EGRAG' and id=40
	and reg_status='';

	secuencia := retcod.prefix||retcod.last_number;

	UPDATE series set last_number = last_number+1 where document_type = 'EGRAG' and id=40 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.serie_egreso_propietario()
  OWNER TO postgres;
