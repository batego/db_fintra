-- Function: etes.validar_transferencia(text)

-- DROP FUNCTION etes.validar_transferencia(text);

CREATE OR REPLACE FUNCTION etes.validar_transferencia(usuario text)
  RETURNS boolean AS
$BODY$
DECLARE

retorno boolean:=true;

BEGIN

     --VALIDAR SI EXISTE ANTICIPOS SIN TRANSFERIR POR OTROS USUARIOS---
     PERFORM  * FROM etes.transferencia_anticipos_temp
     WHERE transferido='N'
     AND usuario_sesion != usuario ;
	IF(FOUND)THEN

		DELETE FROM etes.transferencia_anticipos_temp
		WHERE transferido='N'
		AND usuario_sesion != usuario
		AND extract('minute' from now()-creation_date) > 15 ;

	END IF;

	IF((SELECT COUNT(0) FROM etes.transferencia_anticipos_temp
	    WHERE transferido='N' AND usuario_sesion != usuario)> 0)THEN
		retorno:=false;
	END IF;


RETURN retorno;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.validar_transferencia(text)
  OWNER TO postgres;
