-- Function: opav.sp_insumosordenocs(character varying)

-- DROP FUNCTION opav.sp_insumosordenocs(character varying);

CREATE OR REPLACE FUNCTION opav.sp_insumosordenocs(_usuario character varying)
  RETURNS SETOF opav.rs_insumos_ocs AS
$BODY$

DECLARE

	result opav.rs_insumos_ocs;
	rS_preOCS record;

	LotePreSolicitud varchar;

 BEGIN

	select into rS_preOCS
		responsable, lote_ocs, /*cod_solicitud*/ estado_preocs
	from opav.sl_preocs
	where responsable = _usuario and estado_preocs = 0
	group by responsable, lote_ocs, /*cod_solicitud,*/ estado_preocs;

	--VERIFICAMOS QUE NO TENGA REGISTROS - LOS INSERTAMOS POR PRIMERA VEZ
	if ( rS_preOCS.estado_preocs = 0 ) then

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
			--WHERE responsable = _usuario and cod_solicitud = rS_preOCS.cod_solicitud and estado_preocs = 0
			WHERE responsable = _usuario and lote_ocs = rS_preOCS.lote_ocs /*and cod_solicitud = rS_preOCS.cod_solicitud*/ and estado_preocs = 0

		LOOP
			--result.costo_presupuestado = 15200;
			RETURN next result;

		END LOOP;

	end if;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_insumosordenocs(character varying)
  OWNER TO postgres;
