-- Function: opav.sp_obtener_costos_adicionales(character varying)

-- DROP FUNCTION opav.sp_obtener_costos_adicionales(character varying);

CREATE OR REPLACE FUNCTION opav.sp_obtener_costos_adicionales(id_solicitud_ character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE

_id_accion numeric;
_id_cotizacion numeric;
_cotos_indirectos numeric;
_ivaCompensar numeric;
_perc_iva_compensar numeric;
_iva_material numeric;
_nombre_distribucion varchar := '';
 cotizacion record;
 rs_1 record;
 rs_calculos record;

 --select * from opav.sp_obtener_costos_adicionales('924241') as (base numeric ,administracion numeric, iva_material numeric , subtotal numeric , porc_iva_compensar numeric, iva_compensar numeric , subtotal_2 numeric)

 BEGIN

		--SE OBTIENE LA ACCION PRINCIPAL RELACIONADA CON EL ID_SOLICITUD. _ID_ACCION
		SELECT
			id_accion INTO _id_accion
		from
			opav.acciones
		where
			id_solicitud = id_solicitud_
			and accion_principal = 1;


		--SE OBTIENE EL VALOR TOTAL DE LA ADMINISTRACION. _COTOS_INDIRECTOS
		SELECT
			 coalesce(sum(valor_total),0) INTO _cotos_indirectos
		from
			opav.sl_costos_admon_proyecto
		where
			num_solicitud = id_solicitud_  AND reg_status = '';



		--SE INGRESAN EN EL RECORD RS_1 LOS CAMPOS SUBTOTAL,VALOR_COTIZACION,PERC_ADMINISTRACION,PERC_IMPREVISTO,PERC_UTILIDAD,SUBTOTAL/VALOR_COTIZACION AS TOTALCOMISION QUE SE ENCUENTRAN GUARDADOS EN LA COTIZACION.
		SELECT INTO rs_1
			subtotal, valor_cotizacion, perc_administracion, perc_imprevisto, perc_utilidad,subtotal/valor_cotizacion as totalcomision
		FROM
			opav.sl_cotizacion
		WHERE
			id_accion = _id_accion;

		RAISE NOTICE 'rs_1.subtotal:% ',rs_1.subtotal;


		--OBTENEMOS LA DISTRIBUCION ASOCIADA A LA SOLICITUD
		SELECT INTO _nombre_distribucion trim(distribucion_rentabilidad_esquema) FROM opav.sl_cotizacion where id_accion = _id_accion;

		RAISE NOTICE '_nombre_distribucion:% ',_nombre_distribucion;

		--OBTENEMOS EL _IVACOMPENSAR
		SELECT INTO _perc_iva_compensar round(((0.1588*a.porc_eca/100)+0.0044),4)
		FROM opav.tipo_distribucion_eca a
		LEFT JOIN tablagen b on (a.tipo= b.dato)
		LEFT JOIN tablagen c on (b.table_code = c.table_code)
		WHERE c.table_type ilike ('%tipo_ofert%') and b.reg_status =''
		AND (b.table_code || ' (' || (a.porc_opav + a.porc_fintra + a.porc_interventoria + a.porc_provintegral)::numeric(6,3) || ' - ' || (a.porc_eca)::numeric(6,3) || ')') = 	_nombre_distribucion;

			RAISE NOTICE '_perc_iva_compensar:% ',_perc_iva_compensar;



		--SE OBTIENE EL VALOR DEL IVA_DEL MATERIAL DEL PROYECTO _IVA_MATERIAL
		select coalesce
			(
				(SELECT
				sum(i.valor_esquema *0.19)::numeric(19,2) as IVA_MATERIAL
				FROM opav.sl_relacion_cotizacion_detalle_apu AS i
				INNER JOIN opav.sl_rel_actividades_apu AS f ON (i.id_rel_actividades_apu = f.id)
				INNER JOIN opav.sl_apu AS aa ON (f.id_apu = aa.id)
				INNER JOIN opav.sl_apu_det AS ab ON (aa.id = ab.id_apu and ab.id_insumo = i.id_insumo and ab.id_unidad_medida = i.id_unidad_medida)
				INNER JOIN opav.sl_actividades_capitulos AS e ON (f.id_actividad_capitulo = e.id)
				INNER JOIN opav.sl_capitulos_disciplinas AS d ON (e.id_capitulo = d.id)
				INNER JOIN opav.sl_disciplinas_areas as c ON (d.id_disciplina_area = c.id)
				INNER JOIN opav.sl_areas_proyecto AS b ON (c.id_area_proyecto = b.id)
				INNER JOIN unidad_medida_general AS un ON (aa.id_unidad_medida = un.id)
				WHERE
					i.reg_status=''
				AND
					ab.id_tipo_insumo = 1
				AND
					b.id_solicitud = id_solicitud_),
			0) INTO _iva_material;

		RAISE NOTICE '_iva_material:% ',_iva_material;
		RAISE NOTICE '_cotos_indirectos:% ',_cotos_indirectos;

		-- Obtener el valor a compensar
		SELECT INTO _ivaCompensar ((rs_1.subtotal+_iva_material+_cotos_indirectos)*_perc_iva_compensar);

	SELECT INTO rs_calculos
			round(rs_1.subtotal,2) ,
			round(_cotos_indirectos,2) ,
			round(_iva_material,2) ,
			round(rs_1.subtotal+_iva_material+_cotos_indirectos,0),
			_perc_iva_compensar,
			round(_ivaCompensar,2),
			round(rs_1.subtotal+_iva_material+_cotos_indirectos+_ivaCompensar,2);

	RETURN NEXT rs_calculos;

	raise notice '_id_accion :%', _id_accion;
	raise notice 'rs_1 :%', rs_1;
	raise notice '_cotos_indirectos :%', _cotos_indirectos;
	raise notice '_ivaCompensar :%', _ivaCompensar;
	raise notice 'perc_iva_compensar :%', _perc_iva_compensar;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_obtener_costos_adicionales(character varying)
  OWNER TO postgres;
