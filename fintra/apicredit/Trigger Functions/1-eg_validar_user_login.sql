-- Function: apicredit.eg_validar_user_login()

-- DROP FUNCTION apicredit.eg_validar_user_login();

CREATE OR REPLACE FUNCTION apicredit.eg_validar_user_login()
  RETURNS "trigger" AS
$BODY$
DECLARE

  result boolean := true;

BEGIN
		PERFORM * FROM apicredit.usuarios_portal  WHERE UPPER(idusuario) =UPPER(NEW.idusuario);
		if(found)then
		 result:=false;
		 RAISE EXCEPTION 'El id usuario ingresaso ya se encuentra registrado : %', NEW.idusuario ;
		 EXIT;
		END IF;

		PERFORM * FROM apicredit.usuarios_portal  WHERE UPPER(email) =UPPER(NEW.email);
		if(found)then
		 result:=false;
		 RAISE EXCEPTION 'Ya existe un id usuario para el email ingresado:  %', NEW.email ;
		  EXIT;
		end if;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_validar_user_login()
  OWNER TO postgres;
