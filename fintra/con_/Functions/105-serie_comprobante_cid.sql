-- Function: con.serie_comprobante_cid()

-- DROP FUNCTION con.serie_comprobante_cid();

CREATE OR REPLACE FUNCTION con.serie_comprobante_cid()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = '004' and id=2680
	and reg_status='';

	secuencia := retcod.prefix||'ID'||lpad(retcod.last_number, 8, '0');

	UPDATE series set last_number = last_number+1 where document_type = '004' and id=2680 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.serie_comprobante_cid()
  OWNER TO postgres;
