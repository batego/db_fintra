-- Function: opav.sp_deletepreocs(character varying)

-- DROP FUNCTION opav.sp_deletepreocs(character varying);

CREATE OR REPLACE FUNCTION opav.sp_deletepreocs(_usuario character varying)
  RETURNS SETOF opav.rs_delete_preocs AS
$BODY$

DECLARE

	result opav.rs_delete_preocs;

 BEGIN

	UPDATE opav.sl_solicitud_ocs
	SET sol_add = 'N'
	FROM (
		SELECT cod_solicitud
		FROM opav.sl_preocs
		WHERE responsable = _usuario and estado_preocs = 0 group by cod_solicitud
	) tabla1
	WHERE opav.sl_solicitud_ocs.cod_solicitud = tabla1.cod_solicitud;

	UPDATE opav.sl_solicitud_ocs_detalle
	SET item_add = 'N'
	FROM (
		SELECT *
		,(select id from opav.sl_solicitud_ocs where cod_solicitud = opav.sl_preocs.cod_solicitud) as id_solicitud
		FROM opav.sl_preocs
		WHERE responsable = _usuario and estado_preocs = 0
	) tabla1
	WHERE opav.sl_solicitud_ocs_detalle.codigo_insumo = tabla1.codigo_insumo
	      and opav.sl_solicitud_ocs_detalle.id_unidad_medida = tabla1.id_unidad_medida
	      and opav.sl_solicitud_ocs_detalle.id_solicitud_ocs = tabla1.id_solicitud;

	DELETE FROM opav.sl_preocs where responsable = _usuario and estado_preocs = 0;

	if ( FOUND ) then
		result.respta = 'POSITIVO';
	else
		result.respta = 'NEGATIVO';
	end if;

	RETURN NEXT result;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_deletepreocs(character varying)
  OWNER TO postgres;
