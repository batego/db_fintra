-- Function: con.serie_comprobante_cen()

-- DROP FUNCTION con.serie_comprobante_cen();

CREATE OR REPLACE FUNCTION con.serie_comprobante_cen()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'CIDIAR_ENDOSO' and id=2686
	and reg_status='';

	secuencia := retcod.prefix||'N'||lpad(retcod.last_number, 8, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'CIDIAR_ENDOSO' and id=2686 and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.serie_comprobante_cen()
  OWNER TO postgres;
