-- Function: opav.sp_detalleinventario(character varying)

-- DROP FUNCTION opav.sp_detalleinventario(character varying);

CREATE OR REPLACE FUNCTION opav.sp_detalleinventario(codmovimiento character varying)
  RETURNS SETOF opav.rs_detalle_movimiento AS
$BODY$

DECLARE

	result opav.rs_detalle_movimiento;
	rS_Solicitud record;

 BEGIN

	raise notice 'COCOA';

	FOR result IN

		SELECT
			codigo_insumo,
			descripcion_insumo,
			nombre_unidad_insumo,
			referencia_externa,
			cantidad::numeric(15,0),
			costo_unitario_compra::numeric(15,0),
			costo_total_compra::numeric(15,0),
			cantidad_recibida::numeric(15,0),
			costo_recibido::numeric(15,0)
		FROM opav.sl_inventario_detalle
		WHERE id_inventario = (select id from opav.sl_inventario where cod_movimiento = CodMovimiento)

	LOOP
		--result.responsable = _usuario;
		--result.id_solicitud = _idsolicitud;
		RETURN next result;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_detalleinventario(character varying)
  OWNER TO postgres;
