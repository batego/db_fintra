-- Function: opav.sl_ws_migrar_ordenes_compra_will_originales()

-- DROP FUNCTION opav.sl_ws_migrar_ordenes_compra_will_originales();

CREATE OR REPLACE FUNCTION opav.sl_ws_migrar_ordenes_compra_will_originales()
  RETURNS text AS
$BODY$

DECLARE

	DSPCH varchar;
	Respuesta text;

	rsOCompra record;

	_id_despacho integer;
	_bodega character varying;
	_id_subocs integer;

BEGIN
--
-- truncate opav.sl_orden_compra_servicio_prueba;
-- truncate opav.sl_ocs_detalle_prueba;
-- truncate opav.sl_despacho_ocs_prueba;
-- truncate opav.sl_despacho_detalle_prueba;

	Respuesta = 'NEGATIVO';

	FOR rsOCompra IN

		select
			replace(substring(oc.fecha_actual::date,1,7),'-','') as periodo, oc.cod_ocs, oc.id, oc.responsable, oc.cod_proveedor, oc.descripcion,oc.bodega , rof.factura, rof.despacho ,dos.id as id_despacho
		from 		opav.sl_orden_compra_servicio_will	as oc
		inner join	opav.sl_rel_ocs_factura_migracion   	as rof	on (oc.cod_ocs = rof.sub_ocs)
		inner join 	opav.sl_despacho_ocs_will		as dos	on (dos.cod_despacho = rof.despacho   )
		where rof.reg_status = '' and  periodo ilike '2018%'
		order by 1

	LOOP

		INSERT INTO opav.sl_orden_compra_servicio(
			reg_status, dstrct, cod_ocs, responsable, id_solicitud, cod_proveedor,
			tiposolicitud, bodega, direccion_entrega, descripcion, fecha_actual,
			fecha_entrega, forma_pago, total_insumos, estado_ocs, impreso,
			enviado_proveedor, creation_date, creation_user, last_update,
			user_update, observaciones, pasar_apoteosys, estado_apoteosys,estado_inclusion)
		SELECT
			'', dstrct, cod_ocs, responsable, id_solicitud, cod_proveedor,
			tiposolicitud, bodega, direccion_entrega, COALESCE(descripcion,'Factura : '|| rsOCompra.factura ), fecha_actual,
			fecha_entrega, forma_pago, total_insumos, estado_ocs, impreso,
			enviado_proveedor, creation_date, 'WH', now(),
			user_update, COALESCE (observaciones,''), COALESCE(pasar_apoteosys,''), COALESCE(estado_apoteosys,''),
			COALESCE(estado_inclusion,'')
		FROM opav.sl_orden_compra_servicio_will
		WHERE  cod_ocs=rsOCompra.cod_ocs
		returning id into _id_subocs;

		if(FOUND) THEN
			RAISE NOTICE 'INSERTO CABECERA %' , _id_subocs;
		END IF;


		INSERT INTO opav.sl_ocs_detalle(
			reg_status, dstrct, id_ocs, responsable, lote_ocs, cod_solicitud,
			codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
			id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada,
			costo_unitario_compra, costo_total_compra, insumo_adicional,
			creation_date, creation_user, last_update, user_update)
		SELECT
			'', dstrct, _id_subocs, responsable, lote_ocs, cod_solicitud,
			codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
			id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada,
			costo_unitario_compra, costo_total_compra, insumo_adicional,
			creation_date, 'WH', last_update, user_update
		FROM opav.sl_ocs_detalle_will
		WHERE id_ocs = rsOCompra.id;

		if(FOUND) THEN
			RAISE NOTICE 'INSERTO DETALLE ';
		END IF;
		-- Preguntar a Harold?
-- 		update opav.sl_orden_compra_servicio
-- 		set
-- 			pasar_apoteosys = 'N',
-- 			estado_apoteosys = 'N',
-- 			estado_inclusion = 'N'
-- 		where cod_ocs=rsOCompra.cod_ocs;



		_BODEGA = (SELECT CASE WHEN (rsOCompra.BODEGA = 1) THEN 'BODEGA PRINCIPAL' ELSE 'BODEGA PROYECTO' END);

		DSPCH := opav.get_lote_despacho('DESPACHO_NO_17');

		--'Factura : '|| rsOCompra.factura ||rsOCompra.descripcion
		INSERT INTO opav.sl_despacho_ocs(
			reg_status, dstrct, cod_despacho, cod_ocs, cod_proveedor,
			responsable, direccion_entrega, descripcion, fecha_actual, fecha_entrega,
			estado_despacho, creation_date, creation_user, last_update, user_update)
		select
			'', dstrct, DSPCH, cod_ocs, cod_proveedor,
			responsable, direccion_entrega, 'Factura : '|| rsOCompra.factura ||' ' ||descripcion, fecha_actual, fecha_entrega,
			estado_despacho, creation_date, 'WH', last_update, user_update
		from opav.sl_despacho_ocs_will
		WHERE COD_DESPACHO = rsOCompra.DESPACHO
		returning id into _id_despacho;

		IF FOUND THEN
			RAISE NOTICE 'INSERTO CABECERA DESPACHO%',  _id_despacho;
			INSERT INTO opav.sl_despacho_detalle(
				reg_status, dstrct, id_despacho, id_ocs_detalle, responsable,
				codigo_insumo, descripcion_insumo, referencia_externa, id_unidad_medida,
				nombre_unidad_insumo, cantidad_recibida, costo_unitario_recibido, costo_total_recibido,
				creation_date, creation_user, last_update, user_update)
			SELECT
				'', dstrct, _id_despacho, id_ocs_detalle, responsable,
				codigo_insumo, coalesce(descripcion_insumo,''), referencia_externa, id_unidad_medida,
				nombre_unidad_insumo, cantidad_recibida, costo_unitario_recibido, costo_total_recibido,
				creation_date, 'WH', now(), user_update
			from opav.sl_despacho_detalle_will
			WHERE id_despacho = rsOCompra.id_despacho;

			IF FOUND THEN
				RAISE NOTICE 'INSERTO DETALLE DESPACHO';
				UPDATE opav.sl_rel_ocs_factura_migracion  SET REG_STATUS = 'w', despacho = DSPCH  WHERE factura = rsOCompra.FACTURA AND SUB_OCS = rsOCompra.cod_ocs;

			END IF;
			DSPCH='';
		END IF;



	END LOOP;

	RETURN Respuesta;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_ws_migrar_ordenes_compra_will_originales()
  OWNER TO postgres;
