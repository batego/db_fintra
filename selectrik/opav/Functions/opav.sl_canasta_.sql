-- Function: opav.sl_canasta_(integer, integer, integer, character varying, integer, character varying)

-- DROP FUNCTION opav.sl_canasta_(integer, integer, integer, character varying, integer, character varying);

CREATE OR REPLACE FUNCTION opav.sl_canasta_(id_solicitud_ integer, id_movimiento_ integer, tipo_entrada_ integer, documento_origen_ character varying, id_causal_ integer, usuario_ character varying)
  RETURNS text AS
$BODY$

DECLARE
_resultado text:= 'Error';
_total numeric := 0;
_lote character varying :='';
_id_canasta integer;
_ltwbs record;
_monto_debito numeric:= 0;
_monto_credito numeric:= 0;

BEGIN
	--Buscamos la cabecera de la canasta si no existe la crea
	INSERT INTO opav.sl_canasta_proyectos (
		    id_solicitud, presupuesto_comercial, total_debitado, total_acreditado,saldo_canasta, creation_date, creation_user)
		    select   id_solicitud_, 0, 0 , 0 , 0 ,now() , usuario_
		    WHERE  not exists
		    (select id_solicitud  from opav.sl_canasta_proyectos where id_solicitud =id_solicitud_);

	--Obtenemos el id_canasta_proyecto.
	select
		id into  _id_canasta
	from
		opav.sl_canasta_proyectos
	where
		id_solicitud =id_solicitud_;






	IF(documento_origen_ ilike '%LTWBS%') THEN

		FOR _ltwbs IN

			SELECT * FROM opav.sl_wbs_modificaciones  WHERE no_lote = documento_origen_

		LOOP

			IF(_ltwbs.movimiento= 2) THEN

				_monto_debito := _monto_debito + _ltwbs.valor_insumo_total;


				insert into opav.sl_canasta_detalle
					(id_canasta , lote_transaccion, documento_origen,
					responsable, id_tipo_entrada, id_causal, id_tipo_movimiento,
					fecha_transaccion, tipo_insumo, codigo_insumo, descripcion_insumo,
					id_unidad_medida, nombre_unidad_insumo, cantidad_afectada, costo_presupuestado,
					costo_unitario_compra, monto_debitado, monto_acreditado, creation_date,
					creation_user)
				values
					(_id_canasta , 0 , documento_origen_ ,
					usuario_ , tipo_entrada_ ,  id_causal_ , 2 ,
					NOW() , _ltwbs.tipo_insumo ,  _ltwbs.id_insumo , _ltwbs.descripcion_insumo,
					_ltwbs.unidad_medida_insumo ,  _ltwbs.nombre_unidad_insumo , _ltwbs.cantidad_insumo_total , _ltwbs.costo_personalizado,
					0 , _ltwbs.valor_insumo_total , 0 , now() , usuario_);

			END IF;



		END LOOP;

		update opav.sl_canasta_proyectos
		set
			total_acreditado = total_acreditado +  _monto_credito ,
			total_debitado = total_debitado + _monto_debito
		 where id_solicitud = id_solicitud;

	ELSE

		create temporary table oc as
			select *
			from opav.sl_ocs_detalle
			where id_ocs in (select id from opav.sl_orden_compra_servicio where cod_ocs in (documento_origen_) ) and cantidad_solicitada > 0;

		create temporary table pres as
			SELECT
				tp.nombre_insumo as tipo_insumo,
				insu.codigo_material as codigo_insumo,
				insu.descripcion as descripcion_insumo,
				i.id_unidad_medida,
				un2.nombre_unidad as nombre_unidad_insumo,
				i.costo_personalizado,
				sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) as cantidad_presupuestada

			FROM opav.sl_relacion_cotizacion_detalle_apu as i
				INNER JOIN opav.sl_rel_actividades_apu as 	f  ON (i.id_rel_actividades_apu = f.id)
				INNER JOIN opav.sl_apu as 			aa ON (f.id_apu = aa.id)
				INNER JOIN opav.sl_apu_det as 			ab ON (aa.id = ab.id_apu and ab.id_insumo = i.id_insumo and ab.id_unidad_medida = i.id_unidad_medida)
				INNER JOIN opav.sl_actividades_capitulos as 	e  ON (f.id_actividad_capitulo = e.id)
				INNER JOIN opav.sl_actividades as 		ea ON (e.id_actividad = ea.id)
				INNER JOIN opav.sl_capitulos_disciplinas 	d  ON (e.id_capitulo = d.id)
				INNER JOIN opav.sl_disciplinas_areas 		c  ON (d.id_disciplina_area = c.id)
				INNER JOIN opav.sl_disciplinas 			ca ON (c.id_disciplina = ca.id)
				INNER JOIN opav.sl_areas_proyecto 		b  ON (c.id_area_proyecto = b.id)
				INNER JOIN unidad_medida_general 		un ON (aa.id_unidad_medida = un.id)
				INNER JOIN opav.sl_cotizacion 			cot ON (i.id_cotizacion = cot.id)
				INNER JOIN opav.sl_insumo  			insu ON (i.id_insumo = insu.id)
				INNER JOIN opav.sl_rel_cat_sub 			catsub ON (catsub.id_subcategoria = insu.id_subcategoria)
				INNER JOIN opav.sl_categoria 			cat ON (cat.id =catsub.id_categoria)
				INNER JOIN opav.sl_tipo_insumo 			tp ON (cat.id_tipo_insumo = tp.id)
				INNER JOIN unidad_medida_general 		un2 ON (i.id_unidad_medida = un2.id)
				INNER JOIN opav.ofertas as  			ofe ON (b.id_solicitud  = ofe.id_solicitud)
			WHERE i.reg_status=''
			AND b.id_solicitud = id_solicitud_
			GROUP BY i.id_insumo,tp.nombre_insumo, i.costo_personalizado, insu.codigo_material, insu.descripcion ,i.id_unidad_medida, un2.nombre_unidad
			HAVING sum(i.cantidad_insumo*i.cantidad_apu*i.rendimiento_insumo) > 0
			ORDER BY tp.nombre_insumo;

		create temporary table liberado as
			select
				b.codigo_material as codigo_insumo, a.unidad_medida_insumo as id_unidad_medida, sum(cantidad_insumo_total) as cantidad_liberada
			from opav.sl_wbs_modificaciones as a
			INNER JOIN opav.sl_insumo  	as b		ON (a.id_insumo = b.id)
			where 	id_solicitud = id_solicitud_ and id_directorio_estados = 4
			group by b.codigo_material, a.unidad_medida_insumo;


		select coalesce(pres.cantidad_presupuestada,0) as cantidad_presupuestada, coalesce(liberado.cantidad_liberada,0) as cantidad_liberada, oc.*
		from 		oc
		LEFT JOIN 	pres		ON (oc.codigo_insumo = pres.codigo_insumo and oc.id_unidad_medida = pres.id_unidad_medida )
		LEFT JOIN	liberado	ON (oc.codigo_insumo = liberado.codigo_insumo and oc.id_unidad_medida = liberado.id_unidad_medida );





	END IF;

	raise notice '_monto_debito :%', _monto_debito;





_resultado:= 'OK';
return _resultado;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_canasta_(integer, integer, integer, character varying, integer, character varying)
  OWNER TO postgres;
