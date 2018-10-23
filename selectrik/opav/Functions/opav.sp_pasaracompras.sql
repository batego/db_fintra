-- Function: opav.sp_pasaracompras(character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_pasaracompras(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_pasaracompras(_usuario character varying, _idsolicitud character varying, codigosolicitud character varying)
  RETURNS SETOF opav.rs_pasar_solicitudes AS
$BODY$

DECLARE

	result opav.rs_pasar_solicitudes;
	rS_ocs record;

	_CdSltud varchar := '';

	EsNuevo integer := 0;

 BEGIN

	--SOLICITUD
	select into rS_ocs * from opav.sl_solicitud_ocs WHERE cod_solicitud = CodigoSolicitud;
	--select * from opav.sl_solicitud_ocs;

	select into EsNuevo count(0) from opav.sl_presolicitud_ocs where responsable = _usuario and id_solicitud = _idsolicitud and cod_solicitud_devolucion = CodigoSolicitud;
	--if ( CodigoSolicitud = null ) then _CdSltud = ''; else _CdSltud = CodigoSolicitud; end if;
	if ( EsNuevo = 0 ) then _CdSltud = ''; elsif ( EsNuevo > 0 ) then _CdSltud = CodigoSolicitud; end if;

	raise notice '_CdSltud: %', _CdSltud;

	--INSERTAR EN DETALLE
	INSERT INTO opav.sl_solicitud_ocs_detalle(
		    reg_status, dstrct, id_solicitud_ocs, responsable, id_solicitud,
		    tipo_insumo, codigo_insumo, referencia_externa, observacion_xinsumo,
		    descripcion_insumo, id_unidad_medida, nombre_unidad_insumo,
		    costo_unitario, total_pedido, total_comprado, total_saldo, insumo_adicional,
		    creation_date, creation_user, last_update, user_update)
	select
		'', 'FINV', rS_ocs.id, _usuario, _idsolicitud,
		tipo_insumo, codigo_insumo, referencia_externa, observacion_xinsumo,
		descripcion_insumo, id_unidad_medida, nombre_unidad_insumo,
		costo_personalizado, solicitado_temporal, 0, solicitado_temporal, insumo_adicional,
		now(), _usuario,now(), _usuario
	from opav.sl_presolicitud_ocs
	where responsable = _usuario
		and id_solicitud = _idsolicitud
		and cod_solicitud_devolucion = _CdSltud
		and solicitado_temporal > 0
		and id_solicitud_ocs = 0;

	if ( FOUND ) then

		--Actualizar el estado de la presolicitud
		UPDATE opav.sl_presolicitud_ocs
		SET
			insumos_solicitados = insumos_solicitados + tabla1.total_pedido
			,insumos_disponibles = insumos_total - tabla1.total_pedido
			,solicitado_temporal = 0
		FROM (

			select s_ocs_det.codigo_insumo, s_ocs_det.total_pedido, s_ocs_det.id_unidad_medida, s_ocs_det.insumo_adicional
			from opav.sl_solicitud_ocs_detalle s_ocs_det, opav.sl_solicitud_ocs s_ocs
			where s_ocs_det.id_solicitud_ocs = s_ocs.id
			and s_ocs_det.responsable = _usuario
			and s_ocs_det.id_solicitud = _idsolicitud
			and s_ocs.estado_solicitud in (0,2)

		) tabla1
		WHERE opav.sl_presolicitud_ocs.codigo_insumo = tabla1.codigo_insumo
		and opav.sl_presolicitud_ocs.id_unidad_medida = tabla1.id_unidad_medida
		and opav.sl_presolicitud_ocs.insumo_adicional = tabla1.insumo_adicional
		and id_solicitud_ocs = 0;

		if ( FOUND ) then

			--CAMBIAR ESTADO SOLICITUD
			UPDATE opav.sl_solicitud_ocs SET estado_solicitud = 1 WHERE cod_solicitud = CodigoSolicitud;
			UPDATE opav.sl_presolicitud_ocs SET id_solicitud_ocs = rS_ocs.id WHERE responsable = _usuario and id_solicitud = _idsolicitud and id_solicitud_ocs = 0 and cod_solicitud_devolucion = _CdSltud;

			result.respta = 'POSITIVO';
		end if;

	else

		result.respta = 'NEGATIVO';

	end if;

	RETURN NEXT result;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_pasaracompras(character varying, character varying, character varying)
  OWNER TO postgres;
