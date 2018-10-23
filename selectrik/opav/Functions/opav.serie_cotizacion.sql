-- Function: opav.serie_cotizacion()

-- DROP FUNCTION opav.serie_cotizacion();

CREATE OR REPLACE FUNCTION opav.serie_cotizacion()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;

BEGIN

	Select into retcod *
	from series
	where document_type = 'COTIZACION' and id=2696
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 6, '0');

	UPDATE series set last_number = last_number+1 where document_type = 'COTIZACION' and id=2696 and reg_status = '';

	return secuencia;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.serie_cotizacion()
  OWNER TO postgres;
