-- Function: opav.sp_insumosdespacho(character varying, character varying)

-- DROP FUNCTION opav.sp_insumosdespacho(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_insumosdespacho(_codocs character varying, _usuario character varying)
  RETURNS SETOF opav.rs_insumos_despacho AS
$BODY$

DECLARE

	result opav.rs_insumos_despacho;
	rS_preOCS record;

	LotePreSolicitud varchar;
	_OrdenCS varchar := '';
	_id_ocs numeric;

 BEGIN

	_OrdenCS = _CodOcs||'-';
	select id into _id_ocs from opav.sl_orden_compra_servicio where cod_ocs = _CodOcs;

	FOR result IN

		SELECT
			reg_status,
			id,
			id_ocs,
			responsable,
			ocdp.codigo_insumo,
			descripcion_insumo,
			id_unidad_medida,
			nombre_unidad_insumo,
			referencia_externa,
			case when hijas.cant_sol is null then cantidad_solicitada else round(cantidad_solicitada-(hijas.cant_sol*(cantidad_solicitada /cantidad_total_solicitada))) end as cantidad_solicitada,
			costo_unitario_compra,
			((case when hijas.cant_sol is null then cantidad_solicitada else round(cantidad_solicitada-(hijas.cant_sol*(cantidad_solicitada /cantidad_total_solicitada))) end ) * costo_unitario_compra ) as costo_total_compra
		FROM opav.sl_ocs_detalle ocdp
			left join (
			      select ocdh.codigo_insumo, sum(ocdh.cantidad_solicitada) as cant_sol
			      from opav.sl_ocs_detalle ocdh
			      where id_ocs in (select id from opav.sl_orden_compra_servicio where cod_ocs ilike _OrdenCS||'%' and reg_status = '') --and estado_inclusion = 'S'
			      group by ocdh.codigo_insumo
			      ) hijas ON (ocdp.codigo_insumo = hijas.codigo_insumo)
		      inner join (
			SELECT a.codigo_insumo, sum(a.cantidad_solicitada) as cantidad_total_solicitada
			FROM opav.sl_ocs_detalle as a
			WHERE a.id_ocs = _id_ocs
			group by 1
	) as ct on(ocdp.codigo_insumo = ct.codigo_insumo)
		WHERE id_ocs = _id_ocs  and cantidad_solicitada > 0

	LOOP

		RETURN next result;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_insumosdespacho(character varying, character varying)
  OWNER TO postgres;
