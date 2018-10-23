-- Function: opav.sp_visualizarsolicitudes(character varying)

-- DROP FUNCTION opav.sp_visualizarsolicitudes(character varying);

CREATE OR REPLACE FUNCTION opav.sp_visualizarsolicitudes(codsolicitud character varying)
  RETURNS SETOF opav.rs_listado_insumos_visualizar AS
$BODY$

DECLARE

	result opav.rs_listado_insumos_visualizar;
	rS_Solicitud record;

 BEGIN

	SELECT INTO rS_Solicitud * FROM opav.sl_solicitud_ocs WHERE cod_solicitud = CodSolicitud;

	if ( rS_Solicitud.estado_solicitud != 0 ) then

		raise notice 'COCOA';

		FOR result IN
			/*
			SELECT
				tipo_insumo,
				codigo_insumo,
				descripcion_insumo,
				--id_unidad_medida,
				nombre_unidad_insumo,
				insumos_total,
				insumos_solicitados,
				insumos_disponibles
			FROM opav.sl_presolicitud_ocs
			WHERE id_solicitud_ocs = rS_Solicitud.id
			AND insumos_solicitados > 0*/

			SELECT
				tipo_insumo,
				codigo_insumo,
				descripcion_insumo,
				nombre_unidad_insumo,
				total_pedido as insumos_total,
				total_comprado as insumos_solicitados,
				total_saldo as insumos_disponibles
			FROM opav.sl_solicitud_ocs_detalle
			WHERE id_solicitud_ocs = rS_Solicitud.id

		LOOP
			--result.responsable = _usuario;
			--result.id_solicitud = _idsolicitud;
			RETURN next result;

		END LOOP;

	else

		raise notice 'COCOB';
		FOR result IN

			SELECT
				--responsable,
				--id_solicitud,
				tipo_insumo,
				codigo_insumo,
				descripcion_insumo,
				--id_unidad_medida,
				nombre_unidad_insumo,
				insumos_total,
				solicitado_temporal as insumos_solicitados,
				--(insumos_total - solicitado_temporal) as insumos_disponibles
				(insumos_total) as insumos_disponibles
				--solicitado_temporal
			FROM opav.sl_presolicitud_ocs
			WHERE responsable = rS_Solicitud.responsable
			AND id_solicitud = rS_Solicitud.id_solicitud
			AND solicitado_temporal > 0
			AND id_solicitud_ocs = 0

		LOOP
			--result.responsable = _usuario;
			--result.id_solicitud = _idsolicitud;
			RETURN next result;

		END LOOP;

	end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_visualizarsolicitudes(character varying)
  OWNER TO postgres;
