-- Function: opav.sp_listarinsumos_solicitudocs_ricardo3(character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_listarinsumos_solicitudocs_ricardo3(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_listarinsumos_solicitudocs_ricardo3(idsolicitud character varying, _usuario character varying, _accion character varying, _codsol character varying)
  RETURNS SETOF opav.rs_listado_insumos_2 AS
$BODY$

DECLARE

	result opav.rs_listado_insumos_2;
	rS_presolicitud record;
	rS_cotizacion record;

	LotePreSolicitud varchar;
	_CdSltud varchar := '';

	EsNuevo integer := 0;
	_idsolicitud integer := idsolicitud;

	verify boolean := false;

 BEGIN

	--if ( _usuario in ('HCUELLO','RPATERNINA','MDUQUE') AND (_Accion = 'NUEVO' OR _Accion = 'EDIT') ) then

	select into EsNuevo count(0) from opav.sl_presolicitud_ocs where responsable = _usuario and id_solicitud = _idsolicitud and cod_solicitud_devolucion = _codSol;
	if ( EsNuevo = 0 ) then _CdSltud = ''; elsif ( EsNuevo > 0 ) then _CdSltud = _codSol; end if;

	if ( _Accion = 'NUEVO' ) then

		raise notice 'Accion: %', _Accion;

		SELECT INTO rS_presolicitud
			coalesce(count(0),0) as cantidad_insumos,
			coalesce(sum(insumos_total),0) as total_insumos
		FROM opav.sl_presolicitud_ocs
		WHERE responsable = _usuario
		and id_solicitud = _idsolicitud
		and id_solicitud_ocs = 0;

		--VERIFICAMOS QUE NO TENGA REGISTROS - LOS INSERTAMOS POR PRIMERA VEZ
		if ( rS_presolicitud.cantidad_insumos = 0 ) then

			--INSERTAR
			raise notice 'A';

			if ( _Accion = 'NUEVO' ) then LotePreSolicitud := opav.get_lote_presolicitud('PREFIX_LOTE'); end if;

			INSERT INTO opav.sl_presolicitud_ocs(
				reg_status, dstrct, lote_presol, responsable, id_solicitud,
				tipo_insumo,
				codigo_insumo,
				descripcion_insumo,
				id_unidad_medida,
				nombre_unidad_insumo,
				costo_personalizado,
				insumos_total,
				insumos_disponibles,
				creation_date, creation_user, last_update, user_update)
			SELECT
				'','FINV', LotePreSolicitud, _usuario, _idsolicitud,
				tp.nombre_insumo as tipo_insumo,
				insu.codigo_material as codigo_insumo,
				insu.descripcion as descripcion_insumo,
				i.id_unidad_medida,
				un2.nombre_unidad as nombre_unidad_insumo,
				i.costo_personalizado,
				sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) as total_insumos,
				sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) as disponible,
				now(), _usuario, now(), _usuario
			FROM opav.sl_relacion_cotizacion_detalle_apu as i
				INNER JOIN opav.sl_rel_actividades_apu as f ON (i.id_rel_actividades_apu = f.id)
				INNER JOIN opav.sl_apu as aa ON (f.id_apu = aa.id)
				INNER JOIN opav.sl_apu_det as ab ON (aa.id = ab.id_apu and ab.id_insumo = i.id_insumo and ab.id_unidad_medida = i.id_unidad_medida)
				INNER JOIN opav.sl_actividades_capitulos as e ON (f.id_actividad_capitulo = e.id)
				INNER JOIN opav.sl_actividades as ea ON (e.id_actividad = ea.id)
				INNER JOIN opav.sl_capitulos_disciplinas d ON (e.id_capitulo = d.id)
				INNER JOIN opav.sl_disciplinas_areas c ON (d.id_disciplina_area = c.id)
				INNER JOIN opav.sl_disciplinas ca ON (c.id_disciplina = ca.id)
				INNER JOIN opav.sl_areas_proyecto b on (c.id_area_proyecto = b.id)
				INNER JOIN unidad_medida_general un ON (aa.id_unidad_medida = un.id)
				INNER JOIN opav.sl_cotizacion cot ON (i.id_cotizacion = cot.id)
				INNER JOIN opav.sl_insumo insu ON (i.id_insumo = insu.id)
				INNER JOIN opav.sl_rel_cat_sub catsub ON (catsub.id_subcategoria = insu.id_subcategoria)
				INNER JOIN opav.sl_categoria cat ON (cat.id =catsub.id_categoria)
				INNER JOIN opav.sl_tipo_insumo tp ON (cat.id_tipo_insumo = tp.id)
				INNER JOIN unidad_medida_general un2 ON (i.id_unidad_medida = un2.id)
				INNER JOIN opav.ofertas as  ofe ON (b.id_solicitud  = ofe.id_solicitud)
			WHERE i.reg_status=''
			AND b.id_solicitud = _idsolicitud
			GROUP BY i.id_insumo,tp.nombre_insumo, i.costo_personalizado, insu.codigo_material, insu.descripcion ,i.id_unidad_medida, un2.nombre_unidad
			HAVING sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) > 0
			ORDER BY tp.nombre_insumo;

			verify = true;

		--TIENE	REGISTROS
		else

			SELECT INTO rS_cotizacion
				count(0) as cantidad_insumos,
				sum(c.total_insumos) as total_insumos
			FROM (
				select
					--tp.nombre_insumo,
					--insu.codigo_material
					count(0) as cantidad_insumos
					,sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) as total_insumos
				from opav.sl_relacion_cotizacion_detalle_apu as i
					INNER JOIN opav.sl_rel_actividades_apu as f ON (i.id_rel_actividades_apu = f.id)
					INNER JOIN opav.sl_apu as aa ON (f.id_apu = aa.id)
					INNER JOIN opav.sl_apu_det as ab ON (aa.id = ab.id_apu and ab.id_insumo = i.id_insumo and ab.id_unidad_medida = i.id_unidad_medida)
					INNER JOIN opav.sl_actividades_capitulos as e ON (f.id_actividad_capitulo = e.id)
					INNER JOIN opav.sl_actividades as ea ON (e.id_actividad = ea.id)
					INNER JOIN opav.sl_capitulos_disciplinas d ON (e.id_capitulo = d.id)
					INNER JOIN opav.sl_disciplinas_areas c ON (d.id_disciplina_area = c.id)
					INNER JOIN opav.sl_disciplinas ca ON (c.id_disciplina = ca.id)
					INNER JOIN opav.sl_areas_proyecto b on (c.id_area_proyecto = b.id)
					INNER JOIN unidad_medida_general un ON (aa.id_unidad_medida = un.id)
					INNER JOIN opav.sl_cotizacion cot ON (i.id_cotizacion = cot.id)
					INNER JOIN opav.sl_insumo insu ON (i.id_insumo = insu.id)
					INNER JOIN opav.sl_rel_cat_sub catsub ON (catsub.id_subcategoria = insu.id_subcategoria)
					INNER JOIN opav.sl_categoria cat ON (cat.id =catsub.id_categoria)
					INNER JOIN opav.sl_tipo_insumo tp ON (cat.id_tipo_insumo = tp.id)
					INNER JOIN unidad_medida_general un2 ON (i.id_unidad_medida = un2.id)
					INNER JOIN opav.ofertas as  ofe ON (b.id_solicitud  = ofe.id_solicitud)
				where i.reg_status=''
				and b.id_solicitud = _idsolicitud
				group by i.id_insumo,tp.nombre_insumo, insu.codigo_material, insu.descripcion ,i.id_unidad_medida, un2.nombre_unidad
				having sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) > 0
				order by insu.codigo_material
			)c;

			raise notice 'cantidad_insumos-pre: %, cantidad_insumos-cotiz: %, total_insumos-pre: %, total_insumos-cotiz: %', rS_presolicitud.cantidad_insumos, rS_cotizacion.cantidad_insumos, rS_presolicitud.total_insumos, rS_cotizacion.total_insumos;

			--VERIVICAMOS QUE EL NUMERO DE INSUMOS Y LAS CANTIDADES DE INSUMOS SEAN IGUALES
			if ( rS_presolicitud.cantidad_insumos::numeric = rS_cotizacion.cantidad_insumos::numeric and rS_presolicitud.total_insumos::numeric = rS_cotizacion.total_insumos::numeric ) then

				raise notice 'B';
				verify = true;

			else

				raise notice 'C';

				/*
				DELETE
				FROM opav.sl_presolicitud_ocs
				WHERE responsable = _usuario and id_solicitud = _idsolicitud
				and id_solicitud_ocs = 0;

				select into LotePreSolicitud opav.get_lote_presolicitud('PREFIX_LOTE');

				INSERT INTO opav.sl_presolicitud_ocs(
					    reg_status, dstrct, lote_presol, responsable, id_solicitud,
					    tipo_insumo,
					    codigo_insumo,
					    descripcion_insumo,
					    id_unidad_medida,
					    nombre_unidad_insumo,
					    costo_personalizado,
					    insumos_total,
					    insumos_disponibles,
					    creation_date, creation_user, last_update, user_update)
				SELECT
					'','FINV', LotePreSolicitud, _usuario, _idsolicitud,
					tp.nombre_insumo as tipo_insumo,
					insu.codigo_material as codigo_insumo,
					insu.descripcion as descripcion_insumo,
					i.id_unidad_medida,
					un2.nombre_unidad as nombre_unidad_insumo,
					i.costo_personalizado,
					sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) as total_insumos,
					sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) as disponible,
					now(), _usuario, now(), _usuario
				FROM opav.sl_relacion_cotizacion_detalle_apu as i
					INNER JOIN opav.sl_rel_actividades_apu as f ON (i.id_rel_actividades_apu = f.id)
					INNER JOIN opav.sl_apu as aa ON (f.id_apu = aa.id)
					INNER JOIN opav.sl_apu_det as ab ON (aa.id = ab.id_apu and ab.id_insumo = i.id_insumo and ab.id_unidad_medida = i.id_unidad_medida)
					INNER JOIN opav.sl_actividades_capitulos as e ON (f.id_actividad_capitulo = e.id)
					INNER JOIN opav.sl_actividades as ea ON (e.id_actividad = ea.id)
					INNER JOIN opav.sl_capitulos_disciplinas d ON (e.id_capitulo = d.id)
					INNER JOIN opav.sl_disciplinas_areas c ON (d.id_disciplina_area = c.id)
					INNER JOIN opav.sl_disciplinas ca ON (c.id_disciplina = ca.id)
					INNER JOIN opav.sl_areas_proyecto b on (c.id_area_proyecto = b.id)
					INNER JOIN unidad_medida_general un ON (aa.id_unidad_medida = un.id)
					INNER JOIN opav.sl_cotizacion cot ON (i.id_cotizacion = cot.id)
					INNER JOIN opav.sl_insumo insu ON (i.id_insumo = insu.id)
					INNER JOIN opav.sl_rel_cat_sub catsub ON (catsub.id_subcategoria = insu.id_subcategoria)
					INNER JOIN opav.sl_categoria cat ON (cat.id =catsub.id_categoria)
					INNER JOIN opav.sl_tipo_insumo tp ON (cat.id_tipo_insumo = tp.id)
					INNER JOIN unidad_medida_general un2 ON (i.id_unidad_medida = un2.id)
					INNER JOIN opav.ofertas as  ofe ON (b.id_solicitud  = ofe.id_solicitud)
				WHERE i.reg_status=''
				AND b.id_solicitud = _idsolicitud
				GROUP BY i.id_insumo,tp.nombre_insumo, i.costo_personalizado, insu.codigo_material, insu.descripcion ,i.id_unidad_medida, un2.nombre_unidad
				HAVING sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) > 0
				ORDER BY tp.nombre_insumo;
				*/
				verify = true;

			end if;

		end if;
		--

		raise notice 'verify: %', verify;

		if ( verify = true ) then

			FOR result IN

				SELECT
					A.insumo_adicional,
					A.responsable,
					A.id_solicitud,
					A.tipo_insumo,
					A.codigo_insumo,
					A.descripcion_insumo,
					A.id_unidad_medida,
					A.nombre_unidad_insumo,
					A.insumos_total,
					sum(c.cantidad_solicitada) 			as insumos_solicitados,
					(a.insumos_total - sum(c.cantidad_solicitada)) 	as insumos_disponibles,
					A.solicitado_temporal,
					coalesce(a.referencia_externa,'') 		as referencia_externa,
					coalesce(a.observacion_xinsumo,'') 		as observacion_xinsumo

				FROM opav.sl_presolicitud_ocs 			as A
				left join	opav.sl_solicitud_ocs		as B on (b.id_solicitud=a.id_solicitud)
				left join	opav.sl_ocs_detalle 		as C on (c.cod_solicitud = b.cod_solicitud and a.codigo_insumo = c.codigo_insumo)
				left join	opav.sl_orden_compra_servicio 	AS D ON (C.id_ocs = D.id)
				WHERE A.responsable = _usuario
					and A.id_solicitud = _idsolicitud
					and A.id_solicitud_ocs = 0
					and cod_solicitud_devolucion = _CdSltud
					and D.cod_ocs 		not ilike '%-%'
				group by
					a.insumo_adicional,
					a.responsable,
					a.id_solicitud,
					a.tipo_insumo,
					a.codigo_insumo,
					a.descripcion_insumo,
					a.id_unidad_medida,
					a.nombre_unidad_insumo,
					a.insumos_total,
					a.solicitado_temporal,
					a.referencia_externa,
					a.observacion_xinsumo

			LOOP
				RETURN next result;

			END LOOP;
		end if;
		--

	elsif ( _Accion = 'EDIT' ) then

		FOR result IN

			SELECT
				A.insumo_adicional,
				A.responsable,
				A.id_solicitud,
				A.tipo_insumo,
				A.codigo_insumo,
				A.descripcion_insumo,
				A.id_unidad_medida,
				A.nombre_unidad_insumo,
				A.insumos_total,
				sum(c.cantidad_solicitada) 			as insumos_solicitados,
				(a.insumos_total - sum(c.cantidad_solicitada)) 	as insumos_disponibles,
				A.solicitado_temporal,
				coalesce(a.referencia_externa,'') 		as referencia_externa,
				coalesce(a.observacion_xinsumo,'') 		as observacion_xinsumo

			FROM opav.sl_presolicitud_ocs 			as A
			left join	opav.sl_solicitud_ocs		as B on (b.id_solicitud=a.id_solicitud)
			left join	opav.sl_ocs_detalle 		as C on (c.cod_solicitud = b.cod_solicitud and a.codigo_insumo = c.codigo_insumo)
			left join	opav.sl_orden_compra_servicio 	AS D ON (C.id_ocs = D.id)
			WHERE A.responsable = _usuario
				and A.id_solicitud = _idsolicitud
				and A.id_solicitud_ocs = 0
				and cod_solicitud_devolucion = _CdSltud
				and D.cod_ocs 		not ilike '%-%'
			group by
				a.insumo_adicional,
				a.responsable,
				a.id_solicitud,
				a.tipo_insumo,
				a.codigo_insumo,
				a.descripcion_insumo,
				a.id_unidad_medida,
				a.nombre_unidad_insumo,
				a.insumos_total,
				a.solicitado_temporal,
				a.referencia_externa,
				a.observacion_xinsumo

		LOOP
			--result.responsable = _usuario;
			--result.id_solicitud = _idsolicitud;
			RETURN next result;

		END LOOP;

	elsif ( _Accion = 'VISUALIZAR' ) then

		raise notice 'VISUALIZAR';

		FOR result IN

			SELECT
				insumo_adicional,
				responsable,
				id_solicitud,
				tipo_insumo,
				codigo_insumo,
				descripcion_insumo,
				id_unidad_medida,
				nombre_unidad_insumo,
				insumos_total,
				insumos_solicitados,
				insumos_disponibles,
				solicitado_temporal,
				coalesce(referencia_externa,'') as referencia_externa,
				coalesce(observacion_xinsumo,'') as observacion_xinsumo
			FROM opav.sl_presolicitud_ocs
			WHERE responsable = _usuario and id_solicitud = _idsolicitud and solicitado_temporal > 0

		LOOP
			--result.responsable = _usuario;
			--result.id_solicitud = _idsolicitud;
			RETURN next result;

		END LOOP;

	end if;
	--

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_listarinsumos_solicitudocs_ricardo3(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
