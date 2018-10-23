-- Function: etes.serie_num_venta()

-- DROP FUNCTION etes.serie_num_venta();

CREATE OR REPLACE FUNCTION etes.serie_num_venta()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = '004' and id=2655
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

	UPDATE series set last_number = last_number+1 where document_type = '004' and id=2655 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.serie_num_venta()
  OWNER TO postgres;
