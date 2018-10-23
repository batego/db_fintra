-- Function: opav.sp_eliminaritemsocs(character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_eliminaritemsocs(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_eliminaritemsocs(_codocs character varying, _codinsumo character varying, _users character varying)
  RETURNS SETOF opav.rs_deleteocs AS
$BODY$

DECLARE

	result opav.rs_deleteocs;
	RsGeneral record;

	CodSolicitudSalida varchar := '';

 BEGIN

	--BUSCAR
	FOR RsGeneral IN

		--select * from opav.sl_orden_compra_servicio where cod_ocs = 'OC00108'
		select cod_solicitud from opav.sl_ocs_detalle where id_ocs in (select id from opav.sl_orden_compra_servicio where cod_ocs = _CodOCS) group by cod_solicitud

	LOOP

		--DEVOLVER LOS SALDOS A LA SOLICITUD DE COMPRA/SERVICIO
		UPDATE opav.sl_solicitud_ocs_detalle
		SET
			last_update = now()
			,total_comprado = total_comprado - tabla1.cantidad_solicitada
			,total_saldo = total_saldo + tabla1.cantidad_solicitada
			,estado_item = 'N'
			,item_add = 'N'
		FROM (
			select *
			    ,(select id from opav.sl_solicitud_ocs where cod_solicitud = opav.sl_ocs_detalle.cod_solicitud) as id_solicitud
			    from opav.sl_ocs_detalle
			where
			id_ocs = (select id from opav.sl_orden_compra_servicio where cod_ocs = _CodOCS)
			and cod_solicitud = RsGeneral.cod_solicitud
			and cantidad_solicitada > 0
			and codigo_insumo = _CodInsumo
		) tabla1
		WHERE opav.sl_solicitud_ocs_detalle.codigo_insumo = tabla1.codigo_insumo
		and opav.sl_solicitud_ocs_detalle.id_unidad_medida = tabla1.id_unidad_medida
		and opav.sl_solicitud_ocs_detalle.id_solicitud_ocs = tabla1.id_solicitud
		and opav.sl_solicitud_ocs_detalle.insumo_adicional = tabla1.insumo_adicional;

		if ( FOUND ) then
			raise notice 'A';
			--ACTUALIZAR LA SOLICITUD PARA AVALARLA.
			UPDATE opav.sl_solicitud_ocs SET sol_add = 'N' WHERE cod_solicitud = RsGeneral.cod_solicitud;
			result.respta := 'POSITIVO';
		else
			raise notice 'B';
			result.respta := 'NEGATIVO';
		end if;

		CodSolicitudSalida = RsGeneral.cod_solicitud;

	END LOOP;

	IF ( result.respta = 'POSITIVO' ) THEN
		raise notice 'C';
		--AUDITORIA DE ELIMINADAS.
		INSERT INTO opav.sl_auditoria_ocs_borradas(
			    reg_status, dstrct, cod_ocs, responsable, cod_proveedor,
			    tiposolicitud, bodega, direccion_entrega, descripcion, fecha_actual,
			    fecha_entrega, forma_pago, lote_ocs, cod_solicitud, codigo_insumo,
			    descripcion_insumo, referencia_externa, observacion_xinsumo,
			    id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada,
			    costo_unitario_compra, costo_total_compra, insumo_adicional,
			    creation_date, creation_user, last_update, user_update)
		SELECT
			'', 'FINV', oc.cod_ocs, oc.responsable, oc.cod_proveedor,
			oc.tiposolicitud, oc.bodega, oc.direccion_entrega, oc.descripcion, oc.fecha_actual,
			oc.fecha_entrega, oc.forma_pago, ocd.lote_ocs, ocd.cod_solicitud, ocd.codigo_insumo,
			ocd.descripcion_insumo, ocd.referencia_externa, ocd.observacion_xinsumo,
			ocd.id_unidad_medida, ocd.nombre_unidad_insumo, ocd.cantidad_solicitada,
			ocd.costo_unitario_compra, ocd.costo_total_compra, ocd.insumo_adicional,
			ocd.creation_date, _Users, ocd.last_update, _Users
		FROM opav.sl_orden_compra_servicio oc, opav.sl_ocs_detalle ocd
		WHERE oc.id = ocd.id_ocs
		AND cod_ocs = _CodOCS
		AND codigo_insumo = _CodInsumo;

		IF ( FOUND ) THEN
			raise notice 'D';
			--ELIMINAR PREOCS.
			DELETE FROM opav.sl_preocs WHERE cod_solicitud = RsGeneral.cod_solicitud AND orden_cs = _CodOCS;
			IF ( FOUND ) THEN

				--ELIMINAR DETALLE DE LA ORDEN DE COMPRA.
				DELETE FROM opav.sl_ocs_detalle WHERE id_ocs in (select id from opav.sl_orden_compra_servicio where cod_ocs = _CodOCS) AND codigo_insumo = _CodInsumo;
				IF ( FOUND ) THEN
					raise notice 'E';
					--ELIMINAR ORDEN DE COMPRA.
					--DELETE FROM opav.sl_orden_compra_servicio WHERE cod_ocs = _CodOCS;
					result.respta = 'POSITIVO';

				ELSE
					raise notice 'F';
					result.respta := 'NEGATIVO';
				END IF;

			ELSE
				raise notice 'G';
				result.respta := 'NEGATIVO';
			END IF;

		ELSE
			raise notice 'H';
			result.respta := 'NEGATIVO';
		END IF;

	ELSE
		raise notice 'I';
		result.respta := 'NEGATIVO';
	END IF;


	if ( result.respta = 'POSITIVO' ) then
		result.respta = CodSolicitudSalida;
	end if;

	RETURN NEXT result;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_eliminaritemsocs(character varying, character varying, character varying)
  OWNER TO postgres;
