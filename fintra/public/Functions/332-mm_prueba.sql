-- Function: mm_prueba()

-- DROP FUNCTION mm_prueba();

CREATE OR REPLACE FUNCTION mm_prueba()
  RETURNS text AS
$BODY$

DECLARE

  secuencia TEXT;
  retcod record;
  
BEGIN

	Select into retcod * 
	from series 
	where document_type = '004' and id=2662
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

	raise notice 'ASFASDFSADF: %', secuencia;

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mm_prueba()
  OWNER TO postgres;

