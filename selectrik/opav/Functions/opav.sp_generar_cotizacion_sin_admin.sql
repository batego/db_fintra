-- Function: opav.sp_generar_cotizacion_sin_admin(character varying)

-- DROP FUNCTION opav.sp_generar_cotizacion_sin_admin(character varying);

CREATE OR REPLACE FUNCTION opav.sp_generar_cotizacion_sin_admin(id_solicitud_ character varying)
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

 --select sum(w.total) from (select * from opav.sp_generar_cotizacion('924241') as (id_area int, nombre_area character varying,id_capitulo int, nombre_capitulo character varying, nombre_apu text, nombre_unidad character varying,cantidad_apu numeric,valor_unitario numeric, total numeric)) as w;

 BEGIN

		--SE OBTIENE LA ACCION PRINCIPAL RELACIONADA CON EL ID_SOLICITUD. _ID_ACCION
		SELECT
			id_accion INTO _id_accion
		from
			opav.acciones
		where
			id_solicitud = id_solicitud_
			and accion_principal = 1;

		/*
		--SE OBTIENE EL VALOR TOTAL DE LA ADMINISTRACION. _COTOS_INDIRECTOS
		SELECT
			 sum(valor_total) INTO _cotos_indirectos
		from
			opav.sl_costos_admon_proyecto
		where
			num_solicitud = id_solicitud_  AND reg_status = '';

		*/

		--SE INGRESAN EN EL RECORD RS_1 LOS CAMPOS SUBTOTAL,VALOR_COTIZACION,PERC_ADMINISTRACION,PERC_IMPREVISTO,PERC_UTILIDAD,SUBTOTAL/VALOR_COTIZACION AS TOTALCOMISION QUE SE ENCUENTRAN GUARDADOS EN LA COTIZACION.
		SELECT INTO rs_1
			subtotal,valor_cotizacion,perc_administracion,perc_imprevisto,perc_utilidad,subtotal/valor_cotizacion as totalcomision
		FROM
			opav.sl_cotizacion
		WHERE
			id_accion = _id_accion;

		RAISE NOTICE 'rs_1.subtotal:% ',rs_1.subtotal;


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
		_ivaCompensar := coalesce((rs_1.subtotal+_iva_material)*(_perc_iva_compensar-1),0);
		_perc_iva_compensar:=coalesce((_ivaCompensar/(rs_1.subtotal+_iva_material))+1,1);
		--_cotos_indirectos:=coalesce((_cotos_indirectos/(rs_1.subtotal+_iva_material+_ivaCompensar))+1,1);

	END IF;



	FOR cotizacion IN
				select
					b.id as id_area,b.nombre_area,d.id as id_capitulo ,d.descripcion as nombre_capitulo , aa.nombre as nombre_apu , un.nombre_unidad, i.cantidad_apu,
					(sum(i.valor_esquema * (
						CASE WHEN cot.modalidad_comercial = 1
							then ((CASE WHEN ab.id_tipo_insumo = 1
								THEN 1.19
								ELSE 1 END)
							*_perc_iva_compensar
							)
							ELSE 1 END )
						--*_cotos_indirectos
					)/i.cantidad_apu)::numeric(19,2) as valor_unitario,
					sum(i.valor_esquema * (
					CASE WHEN cot.modalidad_comercial = 1
						then (
							(CASE WHEN ab.id_tipo_insumo = 1
								THEN 1.19
								ELSE 1 END)
							*_perc_iva_compensar
							)
						ELSE
						1 END )
					--*_cotos_indirectos
					)::numeric(19,2) as total
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
				WHERE
					i.reg_status=''
					AND b.id_solicitud = id_solicitud_
				GROUP BY
					b.id,
					c.id,
					e.id,
					b.nombre_area,
					d.id,d.descripcion,
					aa.nombre,
					un.nombre_unidad,
					i.cantidad_apu
				HAVING
					sum(i.valor_esquema) !=0
				ORDER BY
					b.id,
					c.id,
					d.id,
					e.id,
					b.nombre_area,
					d.descripcion,
					aa.nombre
	LOOP

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
ALTER FUNCTION opav.sp_generar_cotizacion_sin_admin(character varying)
  OWNER TO postgres;
