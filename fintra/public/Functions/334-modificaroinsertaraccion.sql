-- Function: modificaroinsertaraccion(text, text, text, text)

-- DROP FUNCTION modificaroinsertaraccion(text, text, text, text);

CREATE OR REPLACE FUNCTION modificaroinsertaraccion(text, text, text, text)
  RETURNS text AS
$BODY$DECLARE  
  sqlinsert ALIAS FOR $1;  
  id_accionx ALIAS FOR $2;
  sqlupdate ALIAS FOR $3;
  id_ordenx ALIAS FOR $4;
  respuesta TEXT;
BEGIN  
  --si no existe una accion que empiece asi con ese id_orden se inserta
  IF (NOT EXISTS (SELECT id_accion FROM ws.ms_interface_accord_ftv WHERE id_accion LIKE id_accionx || '%' AND id_orden=id_ordenx)) THEN
	EXECUTE(sqlinsert);
	SELECT INTO respuesta ' no existia accion.'	;  
  ELSE
	--si existe una accion que empiece asi con ese id_orden y su multiservicio no ha llegado a open y no tiene prefactura se hace update al id_accion igual
	--nunca se hace update porque si no ha llegado a open y no tiene prefactura no existe porque se hizo delete antes a menos que el archivo tenga filas repetidas y en ese caso no importa
	IF (EXISTS (SELECT ofe.id_estado_negocio FROM ws.ms_ofertas_ftv ofe ,app_accord acc 
			WHERE ofe.id_orden =acc.id_orden AND (ofe.id_estado_negocio<9 OR ofe.id_estado_negocio IN ('20','77','88','90','91','92','94','95','96')) AND id_accion=id_accionx AND acc.id_orden=id_ordenx AND prefactura='')) THEN
		EXECUTE(sqlupdate);	
		SELECT INTO respuesta ' ya existia accion.'	;  
	ELSE
		SELECT INTO respuesta ' accion estaba en por ingresar en open o arriba de dicho estado.'	;  
	END IF;  
  END IF;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION modificaroinsertaraccion(text, text, text, text)
  OWNER TO postgres;

