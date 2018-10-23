-- Function: apicredit.eg_activar_cuenta_usuario(text)

-- DROP FUNCTION apicredit.eg_activar_cuenta_usuario(text);

CREATE OR REPLACE FUNCTION apicredit.eg_activar_cuenta_usuario(_codeactivate text)
  RETURNS text AS
$BODY$
DECLARE
  result text := 'OK';
 BEGIN

      PERFORM * FROM apicredit.usuarios_portal  WHERE codigo_activacion =_codeActivate and reg_status='I';
      IF(FOUND)then

		UPDATE apicredit.usuarios_portal set reg_status='' where codigo_activacion =_codeActivate;
      else
		PERFORM * FROM apicredit.usuarios_portal  WHERE codigo_activacion =_codeActivate and reg_status='';
		  IF(FOUND)then
			result:='El codigo de activacion ya fue utilizado, lo sentimos.';
		  else
		        result:='Lo sentimos no se pudo activar la cuenta.';
		  end if;
      end if;

RETURN result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_activar_cuenta_usuario(text)
  OWNER TO postgres;
