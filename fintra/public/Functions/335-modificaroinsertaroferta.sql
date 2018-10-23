-- Function: modificaroinsertaroferta(text, text, text)

-- DROP FUNCTION modificaroinsertaroferta(text, text, text);

CREATE OR REPLACE FUNCTION modificaroinsertaroferta(text, text, text)
  RETURNS text AS
$BODY$DECLARE  
  sqlinsert ALIAS FOR $1;  
  id_ordenx ALIAS FOR $2;
  sqlupdate ALIAS FOR $3;
  respuesta TEXT;
BEGIN  
  --si no existe el id_orden se inserta
  IF (NOT EXISTS (SELECT id_orden FROM ws.ms_ofertas_ftv WHERE id_orden=id_ordenx)) THEN
	EXECUTE(sqlinsert);
	SELECT INTO respuesta ' no existia.'	;  
  ELSE
	--si existe el id_orden y no ha llegado a open y no se tiene una prefactura se modifica
	IF (EXISTS (SELECT id_orden FROM ws.ms_ofertas_ftv WHERE id_orden=id_ordenx AND (id_estado_negocio<9 OR id_estado_negocio IN ('20','77','88','90','91','92','94','95','96'))
		AND id_orden NOT IN (SELECT id_orden FROM app_accord WHERE prefactura !=''))) THEN
		EXECUTE(sqlupdate);	
		SELECT INTO respuesta ' ya existia.'	;  
	ELSE
		SELECT INTO respuesta ' estaba en por ingresar en open o arriba de dicho estado.'	;  
	END IF;  
  END IF;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION modificaroinsertaroferta(text, text, text)
  OWNER TO postgres;

