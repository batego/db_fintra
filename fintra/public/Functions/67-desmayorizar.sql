-- Function: desmayorizar()

-- DROP FUNCTION desmayorizar();

CREATE OR REPLACE FUNCTION desmayorizar()
  RETURNS text AS
$BODY$DECLARE
  algo TEXT;
BEGIN
 UPDATE con.comprobante SET fecha_aplicacion='0099-01-01 00:00:00',usuario_aplicacion='' WHERE fecha_aplicacion!='0099-01-01 00:00:00';
 DELETE FROM con.mayor;
 DELETE FROM con.mayor_subledger;
 SELECT INTO algo ' Desmayorizacion terminada.'	;
RETURN algo;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION desmayorizar()
  OWNER TO postgres;
