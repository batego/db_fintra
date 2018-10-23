-- Function: fin.generar_iddocumento_cxp(text, text)

-- DROP FUNCTION fin.generar_iddocumento_cxp(text, text);

CREATE OR REPLACE FUNCTION fin.generar_iddocumento_cxp(text, text)
  RETURNS text AS
$BODY$
DECLARE
  prefijo ALIAS FOR $1;
  sufijo  ALIAS FOR $2;
  serie TEXT;
BEGIN
  IF ( prefijo = 'nextval' ) THEN
    RETURN (select nextval('fin.serie_iddocumento_cxp'))::TEXT;
  END IF;
  serie := ( SELECT last_value::TEXT
	     FROM fin.serie_iddocumento_cxp );

  RETURN (prefijo || lpad(serie, 8, '0') || sufijo);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fin.generar_iddocumento_cxp(text, text)
  OWNER TO postgres;
