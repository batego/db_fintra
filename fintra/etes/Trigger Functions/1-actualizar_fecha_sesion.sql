-- Function: etes.actualizar_fecha_sesion()

-- DROP FUNCTION etes.actualizar_fecha_sesion();

CREATE OR REPLACE FUNCTION etes.actualizar_fecha_sesion()
  RETURNS "trigger" AS
$BODY$DECLARE
BEGIN
	IF(NEW.token !='')THEN
	  IF (OLD.token != NEW.token) THEN
		RAISE NOTICE 'ENTRO ACTUALIZAR FECHA';
		UPDATE usuarios SET fec_ultimo_ingreso=NOW() WHERE idusuario =NEW.idusuario;
	  END IF;
	END IF;

  RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.actualizar_fecha_sesion()
  OWNER TO postgres;
