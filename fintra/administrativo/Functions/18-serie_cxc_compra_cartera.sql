-- Function: administrativo.serie_cxc_compra_cartera()

-- DROP FUNCTION administrativo.serie_cxc_compra_cartera();

CREATE OR REPLACE FUNCTION administrativo.serie_cxc_compra_cartera()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'CXC_COMPCARTERA' and id=2678
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 8, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'CXC_COMPCARTERA' and id=2678 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.serie_cxc_compra_cartera()
  OWNER TO postgres;
