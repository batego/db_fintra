-- Function: partir_ms(character, character)

-- DROP FUNCTION partir_ms(character, character);

CREATE OR REPLACE FUNCTION partir_ms(character, character)
  RETURNS text AS
$BODY$DECLARE  
  idaccion ALIAS FOR $1;  
  numerito ALIAS FOR $2;  
  respuesta character(100);
  idorden character(50);
  

BEGIN  
  
  SELECT INTO respuesta ' ModificaciÃ³n terminada.'	;    
  SELECT INTO idorden id_orden FROM ws.ms_interface_accord_ftv WHERE id_accion =idaccion;
 
IF (NOT EXISTS(SELECT id_orden FROM ws.ms_ofertas_ftv WHERE id_orden=CAST((idorden || numerito) AS numeric))) THEN 


INSERT INTO ws.ms_ofertas_ftv(
            id_orden, id_cliente, costo_oferta_applus, costo_oferta_eca, 
            importe_oferta, id_estado_negocio, cuotas_reales, valor_cuota, 
            detalle_inconsistencia, fecha_envio_ws, last_update_finv, user_update, 
            marca_ws, fecha_oferta, fecha_registro, num_os, estudio_economico, 
            simbolo_variable, tipo_dtf, esquema_comision)
     (SELECT CAST((id_orden || numerito) AS numeric), id_cliente, costo_oferta_applus, costo_oferta_eca, 
            importe_oferta, id_estado_negocio, cuotas_reales, valor_cuota, 
            detalle_inconsistencia, fecha_envio_ws, last_update_finv, user_update, 
            marca_ws, fecha_oferta, fecha_registro, num_os || '_' || numerito, estudio_economico, 
            simbolo_variable, tipo_dtf, esquema_comision
	FROM ws.ms_ofertas_ftv WHERE id_orden =idorden
	);
END IF;

UPDATE ws.ms_interface_accord_ftv SET id_orden =CAST((id_orden || numerito) AS numeric),last_update_finv=now() WHERE id_accion=idaccion;

RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION partir_ms(character, character)
  OWNER TO postgres;

