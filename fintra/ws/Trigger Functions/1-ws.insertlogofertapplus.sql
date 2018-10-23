-- Function: ws.insertlogofertapplus()

-- DROP FUNCTION ws.insertlogofertapplus();

CREATE OR REPLACE FUNCTION ws.insertlogofertapplus()
  RETURNS "trigger" AS
$BODY$DECLARE
asignax TEXT;
BEGIN
--si no hay marca se genera novedad
IF (new.marca_ws IN ('S')) THEN
--IF (new.last_update_finv IS NULL ) THEN
	new.marca_ws='';
	asignax='Applus';
ELSE
	new.marca_ws='N';
	asignax='fintravalores';
END IF;
INSERT INTO ws.ms_interface_logofertas_ftv(
             id_orden, id_estado_actual_negocio, fecha_asigna_estado,
            asigna, usuario)
    VALUES ( new.id_orden, new.id_estado_negocio, NOW(),
            asignax, new.user_update);


  RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION ws.insertlogofertapplus()
  OWNER TO postgres;
