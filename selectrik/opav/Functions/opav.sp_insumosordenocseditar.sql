-- Function: opav.sp_insumosordenocseditar(character varying, character varying)

-- DROP FUNCTION opav.sp_insumosordenocseditar(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_insumosordenocseditar(_usuario character varying, ordencompra character varying)
  RETURNS SETOF opav.rs_insumos_ocs AS
$BODY$

DECLARE

	result opav.rs_insumos_ocs;
	rS_preOCS record;

	LotePreSolicitud varchar;

 BEGIN

	FOR result IN

		SELECT
			insumo_adicional,
			responsable,
			cod_solicitud,
			tipo_insumo,
			codigo_insumo,
			descripcion_insumo,
			id_unidad_medida,
			nombre_unidad_insumo,
			referencia_externa,
			cantidad_total,
			cantidad_solicitada,
			cantidad_disponible,
			cantidad_temporal,
			costo_presupuestado
		FROM opav.sl_preocs
		WHERE orden_cs = OrdenCompra
		--and responsable = _usuario

		--and estado_preocs = 0

	LOOP
		--result.costo_presupuestado = 15200;
		RETURN next result;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_insumosordenocseditar(character varying, character varying)
  OWNER TO postgres;
