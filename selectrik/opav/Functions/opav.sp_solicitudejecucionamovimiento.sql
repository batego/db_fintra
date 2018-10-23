-- Function: opav.sp_solicitudejecucionamovimiento(character varying, character varying)

-- DROP FUNCTION opav.sp_solicitudejecucionamovimiento(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_solicitudejecucionamovimiento(id_solicitud_ejecucion character varying, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

 se record;   -- 'se'    = SOLICITUD EJECUCION
 se_e record; -- 'se_e'  = SOLICITUD EJECUCION DETALLE
 cruce record;
 _id_inventario integer:=0;


BEGIN

--CREAR MOVIMIENTO DE INVENTARIO EN LA TABLA OPAV.SL_INVENTARIO BASADO EN LA SOLICITUD
 FOR se
 IN select *
    FROM opav.sl_solicitud_ejecucion
    WHERE id = id_solicitud_ejecucion
 LOOP
            INSERT INTO opav.sl_inventario(
            id_solicitud, id_bodega, id_bodega_destino, 
            id_tipo_movimiento, cod_movimiento,
            responsable, observacion, fecha_movimiento,
            creation_date, creation_user, id_solicitud_destino)
    VALUES (se.id_solicitud, se.id_bodega_proyecto, se.id_bodega_ejecucion, 3, opav.get_serie_inventario(3::integer), se.creation_user, 
            se.observaciones, now(), now(), usuario, se.id_solicitud) RETURNING id INTO _id_inventario;
            
         
	
 END LOOP;

--CREAR DETALLE DEL MOVIMIENTO DE INVENTARIO BASADO EN EL DETALLE DE LA SOLICITUD
 FOR se_e
 IN select *
    FROM opav.sl_solicitud_ejecucion_detalle
    WHERE id_solicitud_ejecucion = id_solicitud_ejecucion
 LOOP
        if (se_e.id_solicitud_ejecucion = id_solicitud_ejecucion) then
                INSERT INTO opav.sl_inventario_detalle(id_inventario, codigo_insumo, descripcion_insumo, 
                            referencia_externa, observacion_xinsumo, id_unidad_medida, nombre_unidad_insumo, 
                            cantidad, creation_user, user_update)
                    VALUES (_id_inventario, se_e.codigo_insumo, se_e.descripcion_insumo, '', '', se_e.id_unidad_medida, 
                            se_e.nombre_unidad_insumo, se_e.cantidad_solicitada, usuario, usuario);
        end if;                    
 END LOOP; 

--ACTUALIZAR EL ESTADO DE LA SOLICITUD A '1' DESPACHADO
 update  opav.sl_solicitud_ejecucion  set id_estado_solicitud_ejecucion = 1, last_update = now() where id = id_solicitud_ejecucion;

--MOVER LA TABLA KARDEX
 FOR cruce
 IN select so_ej_de.id,so_ej.id, codigo_insumo, id_unidad_medida, cantidad_solicitada, id_bodega_ejecucion, id_bodega_proyecto, id_solicitud, descripcion_insumo
    FROM opav.sl_solicitud_ejecucion_detalle as so_ej_de
    INNER JOIN opav.sl_solicitud_ejecucion   as so_ej    on (so_ej_de.id_solicitud_ejecucion = so_ej.id)
    WHERE so_ej_de.id_solicitud_ejecucion = id_solicitud_ejecucion
 LOOP
        
        --restar cantidades de la bodega de proyecto 
        --raise notice 'Material: %', cruce.codigo_insumo;
        --raise notice 'cantidad que hay en kardex de la bodega de proyecto';
        --raise notice 'restar con cantidad que se solicita: %', cruce.cantidad_solicitada;
        update opav.sl_kardex
        set cantidad = cantidad-cruce.cantidad_solicitada,
            user_update = usuario,
            last_update = now()
        where id_bodega = cruce.id_bodega_proyecto
          and cod_material = cruce.codigo_insumo
          and unidad    = cruce.id_unidad_medida
          and id_solicitud = cruce.id_solicitud;

        --sumar o insertar cantidades en la bodega ejecucion
        perform * from opav.sl_kardex
        where cod_material = cruce.codigo_insumo
          and unidad = cruce.id_unidad_medida
          and id_bodega = cruce.id_bodega_ejecucion
          and id_solicitud = cruce.id_solicitud;
		IF FOUND THEN
                        --raise notice 'Se encontró el material en la bodega de ejecucion';
                        --raise notice 'Cantidad que hay en el kardex de la bodega de ejecucion';
                        --raise notice 'sumar con Cantidad que se solicita y que se suma %', cruce.cantidad_solicitada;
			UPDATE opav.sl_kardex
			set cantidad = (cruce.cantidad_solicitada + cantidad::numeric(10,4))::numeric(10,4),
			    user_update = usuario,
			    last_update = now()
                        where id_bodega = cruce.id_bodega_ejecucion
                          and cod_material = cruce.codigo_insumo
                          and unidad    = cruce.id_unidad_medida
                          and id_solicitud = cruce.id_solicitud;
			
		ELSE
                        --raise notice 'No se encontró el material en la bodega de ejecucion';
                        --raise notice 'Cantidad que se va a insertar en la bodega; %', cruce.cantidad_solicitada;
			INSERT INTO opav.sl_kardex(
				     id_bodega, cod_material, unidad, cantidad, creation_date, 
				    creation_user, descripcion_material, id_solicitud)
			    VALUES ( cruce.id_bodega_ejecucion , cruce.codigo_insumo, cruce.id_unidad_medida , cruce.cantidad_solicitada , 
			    now() ,usuario , cruce.descripcion_insumo, cruce.id_solicitud);		
		END IF;      
 END LOOP; 
--raise notice 'Cruce: %', cruce;
 RETURN 'ok';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_solicitudejecucionamovimiento(character varying, character varying)
  OWNER TO postgres;
