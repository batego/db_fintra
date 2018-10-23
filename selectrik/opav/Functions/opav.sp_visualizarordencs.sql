-- Function: opav.sp_visualizarordencs(character varying)

-- DROP FUNCTION opav.sp_visualizarordencs(character varying);

CREATE OR REPLACE FUNCTION opav.sp_visualizarordencs(codocs character varying)
  RETURNS SETOF opav.rs_listado_ocs_puntual AS
$BODY$

DECLARE

	result opav.rs_listado_ocs_puntual;
	rS_Solicitud record;

 BEGIN

	FOR result IN

		SELECT
			codigo_insumo,
			descripcion_insumo,
			id_unidad_medida,
			nombre_unidad_insumo,
			referencia_externa,
			cantidad_solicitada,
			costo_unitario_compra,
			costo_total_compra
		FROM opav.sl_ocs_detalle
		WHERE id_ocs = (select id from opav.sl_orden_compra_servicio where cod_ocs = CodOCS)
		AND cantidad_solicitada > 0

	LOOP
		--result.responsable = _usuario;
		--result.id_solicitud = _idsolicitud;
		RETURN next result;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_visualizarordencs(character varying)
  OWNER TO postgres;
