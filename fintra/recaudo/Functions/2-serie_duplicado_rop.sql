-- Function: recaudo.serie_duplicado_rop()

-- DROP FUNCTION recaudo.serie_duplicado_rop();

CREATE OR REPLACE FUNCTION recaudo.serie_duplicado_rop()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = '004' and id=2679
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

	UPDATE series set last_number = last_number+1 where document_type = '004' and id=2679 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION recaudo.serie_duplicado_rop()
  OWNER TO postgres;
