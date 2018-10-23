-- Function: administrativo.serie_lote_fasecolda()

-- DROP FUNCTION administrativo.serie_lote_fasecolda();

CREATE OR REPLACE FUNCTION administrativo.serie_lote_fasecolda()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = '004' and id=2675
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 7, '0');

	UPDATE series set last_number = last_number+1 where document_type = '004' and id=2675 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.serie_lote_fasecolda()
  OWNER TO postgres;
