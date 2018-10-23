-- Function: crearcuenta(text, text)

-- DROP FUNCTION crearcuenta(text, text);

CREATE OR REPLACE FUNCTION crearcuenta(text, text)
  RETURNS text AS
$BODY$DECLARE
  sql ALIAS FOR $1;
  cuentax2 ALIAS FOR $2;
  respuesta TEXT;
BEGIN
  SELECT INTO respuesta ' Proceso ejecutado.'	;
  IF (NOT EXISTS (SELECT cuenta FROM con.cuentas WHERE dstrct='FINV' AND cuenta=cuentax2)) THEN
	EXECUTE(sql);
  ELSE
	INSERT INTO con.cuentasviejas (cuentax) VALUES (cuentax2) ;
	SELECT INTO respuesta ' ya existia.'	;
  END IF;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION crearcuenta(text, text)
  OWNER TO postgres;
