-- Function: opav.sp_creardespachomigracion2017()

-- DROP FUNCTION opav.sp_creardespachomigracion2017();

CREATE OR REPLACE FUNCTION opav.sp_creardespachomigracion2017()
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

	Respuesta = 'NEGATIVO';

	FOR rsOCompra IN

		SELECT replace(substring(fecha_actual::date,1,7),'-','') as periodo, oc.cod_ocs, oc.id, oc.responsable, oc.cod_proveedor, oc.descripcion,oc.bodega
		FROM opav.sl_orden_compra_servicio oc
		inner join  opav.sl_ocs_detalle as ocd  on (oc.id = ocd.id_ocs)
		WHERE replace(substring(fecha_actual::date,1,7),'-','') between '201701' and '201712'
		and ocd.cantidad_solicitada > 0 and substring(oc.cod_ocs,1,2) = 'OC'
		and cod_ocs not ilike '%-%'
		group by 1,2,3,4,5,6,7
		order by 1

	LOOP

		perform * from  opav.sl_despacho_ocs where cod_ocs ilike rsOCompra.cod_ocs||'-%';

		IF FOUND THEN

			RAISE NOTICE 'Ya tiene Despacho esta la OC%' , rsOCompra.cod_ocs;
		ELSE

			INSERT INTO opav.sl_orden_compra_servicio(
				reg_status, dstrct, cod_ocs, responsable, id_solicitud, cod_proveedor,
				tiposolicitud, bodega, direccion_entrega, descripcion, fecha_actual,
				fecha_entrega, forma_pago, total_insumos, estado_ocs, impreso,
				enviado_proveedor, creation_date, creation_user, last_update,
				user_update, observaciones, pasar_apoteosys, estado_apoteosys,estado_inclusion)
			SELECT
				reg_status, dstrct, cod_ocs||'-1', responsable, id_solicitud, cod_proveedor,
				tiposolicitud, bodega, direccion_entrega, descripcion, fecha_actual,
				fecha_entrega, forma_pago, total_insumos, estado_ocs, impreso,
				enviado_proveedor, creation_date, creation_user, now(),
				user_update||'-', observaciones, pasar_apoteosys, estado_apoteosys,
				estado_inclusion
			FROM opav.sl_orden_compra_servicio
			WHERE  cod_ocs=rsOCompra.cod_ocs
			returning id into _id_subocs;

			raise notice '_id_subocs: %',_id_subocs;

			INSERT INTO opav.sl_ocs_detalle(
				reg_status, dstrct, id_ocs, responsable, lote_ocs, cod_solicitud,
				codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
				id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada,
				costo_unitario_compra, costo_total_compra, insumo_adicional,
				creation_date, creation_user, last_update, user_update)
			SELECT
				reg_status, dstrct, _id_subocs, responsable, lote_ocs, cod_solicitud,
				codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
				id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada,
				costo_unitario_compra, costo_total_compra, insumo_adicional,
				creation_date, creation_user, last_update, user_update||'-'
			FROM opav.sl_ocs_detalle
			WHERE id_ocs = rsOCompra.id;

			update opav.sl_orden_compra_servicio
			set
				pasar_apoteosys = 'N',
				estado_apoteosys = 'N',
				estado_inclusion = 'N'
			where cod_ocs=rsOCompra.cod_ocs;

			DSPCH := opav.get_lote_despacho('DESPACHO_NO_17'); --Tienes que modificarlo para que arranque en el 20xx; Crear uno para la migracion!

			_BODEGA = (SELECT CASE WHEN (rsOCompra.BODEGA = 1) THEN 'BODEGA PRINCIPAL' ELSE 'BODEGA PROYECTO' END);

			INSERT INTO opav.sl_despacho_ocs(
			reg_status, dstrct, cod_despacho, cod_ocs, cod_proveedor,
			responsable, direccion_entrega, descripcion, fecha_actual, fecha_entrega,
			estado_despacho, creation_date, creation_user, last_update, user_update)
			VALUES ('', 'FINV', DSPCH, rsOCompra.cod_ocs||'-1', rsOCompra.cod_proveedor, --SUBOC-1
			rsOCompra.responsable, _bodega, rsOCompra.descripcion , now(), now(),
			0, now(), rsOCompra.responsable, now(), rsOCompra.responsable||'-')
			returning id into _id_despacho;

			IF FOUND THEN

				INSERT INTO opav.sl_despacho_detalle(
					reg_status, dstrct, id_despacho, id_ocs_detalle, responsable,
					codigo_insumo, descripcion_insumo, referencia_externa, id_unidad_medida,
					nombre_unidad_insumo, cantidad_recibida, costo_unitario_recibido, costo_total_recibido,
					creation_date, creation_user, last_update, user_update)
				SELECT '' , 'FINV' , _id_despacho , ocd.id , ocd.responsable ,
					ocd.codigo_insumo , ocd.descripcion_insumo , ocd.referencia_externa , ocd.id_unidad_medida ,
					ocd.nombre_unidad_insumo , ocd.cantidad_solicitada , ocd.costo_unitario_compra , (ocd.cantidad_solicitada* ocd.costo_unitario_compra)::numeric(15,4) ,
					now(), ocd.responsable  , now() , ocd.responsable||'-'
				FROM opav.sl_ocs_detalle as ocd
				WHERE id_ocs = _id_subocs;

			END IF;

		END IF;

	END LOOP;

	RETURN Respuesta;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_creardespachomigracion2017()
  OWNER TO postgres;
