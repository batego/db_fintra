-- Function: opav.sp_generar_cotizacion_detallada(character varying)

-- DROP FUNCTION opav.sp_generar_cotizacion_detallada(character varying);

CREATE OR REPLACE FUNCTION opav.sp_generar_cotizacion_detallada(id_solicitud_ character varying)
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




 BEGIN

--select sum(w.total ) from (select * from opav.sp_generar_cotizacion_detallada('924776') as (id_area int, nombre_area character varying,id_capitulo int,nombre_capitulo character varying, id_apu int,nombre_apu text, unidad_medida_apu character varying,cantidad_apu numeric,id_insumo int,tipo_insumo character varying,descripcion_insumo text,unidad_medidad_insumo int,nombre_unidad_insumo character varying,cantidad_insumo numeric,rendimiento_insumo numeric,valor_unitario numeric, total numeric)) as w;

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
			num_solicitud = id_solicitud_ AND reg_status = '';


		--SE INGRESAN EN EL RECORD RS_1 LOS CAMPOS SUBTOTAL,VALOR_COTIZACION,PERC_ADMINISTRACION,PERC_IMPREVISTO,PERC_UTILIDAD,SUBTOTAL/VALOR_COTIZACION AS TOTALCOMISION QUE SE ENCUENTRAN GUARDADOS EN LA COTIZACION.

		SELECT INTO rs_1
			id ,subtotal,valor_cotizacion,perc_administracion,perc_imprevisto,perc_utilidad,subtotal/valor_cotizacion as totalcomision
		FROM
			opav.sl_cotizacion
		WHERE
			id_accion = _id_accion;


		--OBTENEMOS LA DISTRIBUCION ASOCIADA A LA SOLICITUD
		SELECT INTO _nombre_distribucion trim(distribucion_rentabilidad_esquema) FROM opav.sl_cotizacion where id_accion = _id_accion;

			RAISE NOTICE '_nombre_distribucion:% ',_nombre_distribucion;

		--OBTENEMOS EL _IVACOMPENSAR
		SELECT INTO _perc_iva_compensar round((((0.1588*a.porc_eca/100)+0.0044)+1),4)
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



	--MODALIDAD ES 0 IVA 1 AIU
	if((select modalidad_comercial from opav.sl_cotizacion where id_accion = _id_accion)='0' )
	THEN
		_perc_iva_compensar:=1;
		_cotos_indirectos:=coalesce((_cotos_indirectos/(rs_1.subtotal))+1,1);

	ELSE
		_ivaCompensar := coalesce((rs_1.subtotal+_cotos_indirectos+_iva_material)*(_perc_iva_compensar-1),0);
		_perc_iva_compensar:=coalesce((_ivaCompensar/(rs_1.subtotal+_iva_material))+1,1);
		_cotos_indirectos:=coalesce((_cotos_indirectos/(rs_1.subtotal+_iva_material+_ivaCompensar))+1,1);

	END IF;





	FOR cotizacion IN
				select
					b.id as id_area,
					b.nombre_area,
					d.id as id_capitulo ,
					d.descripcion as nombre_capitulo ,
					aa.id as id_apu,
					aa.nombre as nombre_apu ,
					un.nombre_unidad as unidad_medida_apu,
					i.cantidad_apu,
					i.id_insumo,
					tp.nombre_insumo as tipo_insumo ,
					insu.descripcion as descripcion_insumo,
					i.id_unidad_medida as unidad_medida_insumo,
					un2.nombre_unidad as nombre_unidad_insumo,
					i.cantidad_insumo,
					i.rendimiento_insumo,
					((i.valor_esquema/i.cantidad_insumo/i.rendimiento_insumo/i.cantidad_apu)* (
									CASE WHEN cot.modalidad_comercial = 1
									then (
										(CASE WHEN ab.id_tipo_insumo = 1
											THEN 1.19
										ELSE 1
										END)
										*_perc_iva_compensar
										)
									ELSE 1
									END )
									*_cotos_indirectos)::numeric(19,3) as valor_unitario,
					(i.valor_esquema/i.cantidad_apu* (
									CASE WHEN cot.modalidad_comercial = 1
										then ((CASE WHEN ab.id_tipo_insumo = 1
											THEN 1.19
											ELSE 1 END)
										*_perc_iva_compensar
										)
										ELSE 1 END )
									*_cotos_indirectos)::numeric(19,3) as total

				from opav.sl_relacion_cotizacion_detalle_apu as i
				inner join opav.sl_rel_actividades_apu as f on (i.id_rel_actividades_apu = f.id)
				inner join opav.sl_apu as aa on (f.id_apu = aa.id)
				inner join opav.sl_apu_det as ab on (aa.id = ab.id_apu and ab.id_insumo = i.id_insumo and ab.id_unidad_medida = i.id_unidad_medida)
				inner join opav.sl_actividades_capitulos as e on (f.id_actividad_capitulo = e.id)
				inner join opav.sl_capitulos_disciplinas d on(e.id_capitulo = d.id)
				inner join opav.sl_disciplinas_areas c on(d.id_disciplina_area = c.id)
				inner join opav.sl_areas_proyecto b on(c.id_area_proyecto = b.id)
				inner join unidad_medida_general un ON (aa.id_unidad_medida = un.id)
				inner join opav.sl_cotizacion cot ON (i.id_cotizacion = cot.id)
				inner join opav.sl_insumo insu ON (i.id_insumo = insu.id)
				inner join opav.sl_rel_cat_sub catsub ON (catsub.id_subcategoria = insu.id_subcategoria)
				inner join opav.sl_categoria cat ON (cat.id =catsub.id_categoria)
				inner join opav.sl_tipo_insumo tp on (cat.id_tipo_insumo = tp.id)
				inner join unidad_medida_general un2 on (i.id_unidad_medida = un2.id)
				WHERE
					i.reg_status=''
					AND b.id_solicitud = id_solicitud_
					AND (i.valor_esquema* (
									CASE WHEN cot.modalidad_comercial = 1
										then ((CASE WHEN ab.id_tipo_insumo = 1
											THEN 1.19
											ELSE 1 END)
										*_perc_iva_compensar
										)
										ELSE 1 END )
									*_cotos_indirectos)::numeric(19,3) >1

				GROUP BY
					b.id,
					b.nombre_area,
					c.id,
					d.id,
					e.id,
					d.descripcion,
					aa.id,
					aa.nombre,
					un.nombre_unidad,
					i.cantidad_apu,
					i.id_insumo,
					tp.nombre_insumo,
					insu.descripcion,
					i.id_unidad_medida,
					un2.nombre_unidad,
					cot.modalidad_comercial,
					ab.id_tipo_insumo,
					i.valor_esquema,
					i.cantidad_insumo,
					i.rendimiento_insumo,
					valor_unitario,
					total

				ORDER BY
					b.id,
					c.id,
					d.id,
					e.id,
					aa.nombre,
					insu.descripcion

	LOOP
		update opav.sl_relacion_cotizacion_detalle_apu set valor_venta = cotizacion.valor_unitario where id_cotizacion  = rs_1.id  and id_insumo = cotizacion.id_insumo and id_unidad_medida = cotizacion.unidad_medida_insumo;

	RETURN NEXT cotizacion;

	END LOOP;

	raise notice '_id_accion :%', _id_accion;
	raise notice 'rs_1 :%', rs_1;
	raise notice '_cotos_indirectos :%', _cotos_indirectos;
	raise notice '_ivaCompensar :%', _ivaCompensar;
	raise notice 'perc_iva_compensar :%', _perc_iva_compensar;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_generar_cotizacion_detallada(character varying)
  OWNER TO postgres;
