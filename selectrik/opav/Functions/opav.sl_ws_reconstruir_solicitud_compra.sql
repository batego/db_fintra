-- Function: opav.sl_ws_reconstruir_solicitud_compra(character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sl_ws_reconstruir_solicitud_compra(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sl_ws_reconstruir_solicitud_compra(_numocs character varying, _numsc character varying, _foms character varying, _id_solicitud character varying)
  RETURNS text AS
$BODY$

DECLARE

	Respuesta text;

	rS_ocs record;
	RsDatosFacturas record;
	RsMigacion record;

	_CdSltud varchar := '';
	CodSol varchar;

	EsNuevo integer := 0;
	Sec integer := 0;
	ID_SC integer;
	ContarFacturas integer;
	ExisteSolicitud integer := 0;
	_id_solicitud2 varchar;

 BEGIN

	--select opav.sl_ws_reconstruir_solicitud_compra('OC02043','SC01684','FOMS13532','');
	if(_id_solicitud = ''::character varying) then
		select
			id_solicitud into _id_solicitud2
		from opav.ofertas
		where num_os ilike ('%'||_foms||'%');
	else
		_id_solicitud2 :=  _id_solicitud;
	end if;

	Respuesta = 'POSITIVO';

	FOR RsMigacion IN

		select * from opav.sl_orden_compra_servicio where cod_ocs = _NumOCS

	LOOP

		SELECT INTO ExisteSolicitud count(0) FROM opav.sl_solicitud_ocs WHERE cod_solicitud = _NumSC;

		IF ( ExisteSolicitud = 0 ) THEN

			--CREAMOS POR PRIMERA VEZ
			INSERT INTO opav.sl_solicitud_ocs(
				reg_status, dstrct, cod_solicitud, responsable, id_solicitud,
				tiposolicitud, bodega, descripcion, fecha_actual, fecha_entrega,
				total_insumos, estado_presolicitud, estado_solicitud, creation_date,
				creation_user, last_update, user_update, cot_tercerizada) --, proveedor_migracion
			VALUES ('', 'FINV', _NumSC, RsMigacion.responsable, _id_solicitud2,
				1, RsMigacion.bodega, 'SOLICITUD PARCIAL DE LA ORDEN No:'||RsMigacion.cod_ocs, now(), RsMigacion.fecha_actual,
				0, 0, 1, now(),
				RsMigacion.responsable, now(), 'WH', RsMigacion.cod_ocs) --, RsMigacion.cod_proveedor
			RETURNING id INTO ID_SC;
		ELSE

			SELECT INTO ID_SC id FROM opav.sl_solicitud_ocs WHERE cod_solicitud = _NumSC;
		END IF;

		INSERT INTO opav.sl_solicitud_ocs_detalle(
			    reg_status, dstrct, id_solicitud_ocs, responsable, id_solicitud,
			    tipo_insumo, codigo_insumo, referencia_externa, observacion_xinsumo,
			    descripcion_insumo, id_unidad_medida, nombre_unidad_insumo,
			    costo_unitario, total_pedido, total_comprado, total_saldo, insumo_adicional,
			    creation_date, creation_user, last_update, user_update)
		select
			soldet.reg_status, soldet.dstrct, ID_SC, soldet.responsable, _id_solicitud2,
			'MATERIAL', soldet.codigo_insumo, soldet.referencia_externa, soldet.observacion_xinsumo,
			soldet.descripcion_insumo, soldet.id_unidad_medida, soldet.nombre_unidad_insumo,
			soldet.costo_unitario_compra, soldet.cantidad_solicitada, soldet.costo_total_compra, 0, soldet.insumo_adicional,
			now(), soldet.creation_user, now(), soldet.user_update
		from opav.sl_ocs_detalle soldet
		where id_ocs = RsMigacion.id and cantidad_solicitada > 0;

	END LOOP;

	RETURN Respuesta;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_ws_reconstruir_solicitud_compra(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
