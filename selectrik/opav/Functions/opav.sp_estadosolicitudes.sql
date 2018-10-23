-- Function: opav.sp_estadosolicitudes(character varying, character varying)

-- DROP FUNCTION opav.sp_estadosolicitudes(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_estadosolicitudes(_usuario character varying, _idsolicitud character varying)
  RETURNS SETOF opav.rs_estado_solicitudes AS
$BODY$

DECLARE

	result opav.rs_estado_solicitudes;
	rS_solicitud record;
	rS_cotizacion record;

	verify boolean := false;

 BEGIN

	SELECT INTO rS_solicitud count(0) as solicitudes_pendientes
	FROM opav.sl_solicitud_ocs
	WHERE responsable = _usuario
	      and id_solicitud = _idsolicitud::integer
	      and estado_solicitud in (0,2);

	select into result.nombre_proyecto nombre_proyecto from opav.ofertas where id_solicitud = _idsolicitud::integer;
	--result.nombre_proyecto = 'PROYECTO DE LOS LOCOS';

	--VERIFICAMOS QUE NO TENGA REGISTROS - LOS INSERTAMOS POR PRIMERA VEZ
	if ( rS_solicitud.solicitudes_pendientes > 0 ) then

		result.estado_solicitud = 'NO-NUEVO';

	else
		result.estado_solicitud = 'NUEVO';

	end if;

	RETURN NEXT result;

	/*
	FOR result IN

		SELECT
			responsable,
			id_solicitud,
			tipo_insumo,
			codigo_insumo,
			descripcion_insumo,
			id_unidad_medida,
			nombre_unidad_insumo,
			insumos_total,
			insumos_solicitados,
			insumos_disponibles
		FROM opav.sl_presolicitud_ocs
		WHERE responsable = _usuario and id_solicitud = _idsolicitud

	LOOP
		--result.responsable = _usuario;
		--result.id_solicitud = _idsolicitud;
		RETURN next result;

	END LOOP;*/

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_estadosolicitudes(character varying, character varying)
  OWNER TO postgres;
