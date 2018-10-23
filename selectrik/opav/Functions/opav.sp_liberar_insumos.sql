-- Function: opav.sp_liberar_insumos(integer, integer, integer, integer, character varying)

-- DROP FUNCTION opav.sp_liberar_insumos(integer, integer, integer, integer, character varying);

CREATE OR REPLACE FUNCTION opav.sp_liberar_insumos(id_solicitud_ integer, causal_ integer, id_insumo_ integer, unidad_medidad_insumo_ integer, usuario_ character varying)
  RETURNS text AS
$BODY$

DECLARE
_resultado text:= 'Error';
_total numeric := 0;
_no_lote character varying :='';
_costo_insumo numeric :=0;
BEGIN


	select
		costo_personalizado into  _costo_insumo

	from
		opav.sl_wbs_ejecucion
	where
	id_solicitud = id_solicitud_ and
	id_insumo = id_insumo_ and
	unidad_medida_insumo = unidad_medidad_insumo_;



	--Se obtiene el valor que se obtiene al liberar los insumos pasados por parametro
	select
		sum(_costo_insumo *liberar) into  _total

	from
		tem.sl_liberacion_insumos
	where
	id_solicitud = id_solicitud_ and
	id_insumo = id_insumo_ and
	unidad_medida_insumo = unidad_medidad_insumo_ and
	creation_user = usuario_;

	RAISE NOTICE '_total :% ',_total;

	select 'LTWBS' || get_lcod('LTWBS') into _no_lote ;

	--se inserta el movimiento

	INSERT INTO opav.sl_wbs_modificaciones(

		id_directorio_estados,
		id_solicitud,
		id_area,
		id_disciplina,
		id_disciplina_area,
		id_capitulo,
		id_actividad,
		id_actividades_capitulo,
		id_rel_actividades_apu,
		id_relacion_cotizacion_detalle_apu,
		id_cotizacion,
		id_apu,
		unidad_medida_apu,
		nombre_unidad_medida_apu,
		id_insumo,
		tipo_insumo,
		descripcion_insumo,
		unidad_medida_insumo,
		nombre_unidad_insumo,

		cantidad_apu,
		cantidad_insumo,
		rendimiento_insumo,
		costo_personalizado,
		cantidad_insumo_total,
		movimiento,--
		valor_insumo_total,

		creation_date,
		creation_user,
		no_lote

	)
		SELECT
		4,
		A.id_solicitud,
		A.id_area,
		A.id_disciplina,
		A.id_disciplina_area,
		A.id_capitulo,
		A.id_actividad,
		A.id_actividades_capitulo,
		A.id_rel_actividades_apu,
		A.id_relacion_cotizacion_detalle_apu,
		A.id_cotizacion,
		A.id_apu,
		A.unidad_medida_apu,
		A.nombre_unidad_medida_apu,
		A.id_insumo,
		A.tipo_insumo,
		A.descripcion_insumo,
		A.unidad_medida_insumo,
		A.nombre_unidad_insumo,
		A.cantidad_apu,--cantidad_apu ?
		(B.liberar/A.cantidad_apu*A.rendimiento_insumo),--cantidad_insumo ?
		A.rendimiento_insumo,
		A.costo_personalizado,
		(B.liberar), --cantidad_insumo_total,(cantidad_apu*cantidad_insumo*rendimiento_insumo*costo_personalizado)
		2,
		(B.liberar*A.costo_personalizado),--valor_insumo_total



		now(),
		usuario_,
		_no_lote
		FROM
		opav.sl_wbs_ejecucion as A
		INNER JOIN tem.sl_liberacion_insumos as B
		ON(A.id_solicitud = b.id_solicitud AND A.id_rel_actividades_apu = B.id_rel_actividades_apu AND A.id_insumo = B.id_insumo AND A.unidad_medida_insumo = B.unidad_medida_insumo)
		where
		A.id_solicitud = id_solicitud_ and
		A.id_insumo = id_insumo_ and
		A.unidad_medida_insumo= unidad_medidad_insumo_ and
		B.creation_user =  usuario_;


		--se actualiza la cantidad liberada

		update
			opav.sl_wbs_ejecucion as A
			set cantidad_liberada = cantidad_liberada + B.liberar
		from
			(select *  from tem.sl_liberacion_insumos
			where
			id_solicitud = id_solicitud_ and
			creation_user =  usuario_) AS B
		where
			A.id_solicitud = b.id_solicitud AND
			A.id_rel_actividades_apu = B.id_rel_actividades_apu AND
			A.id_insumo = B.id_insumo AND
			A.unidad_medida_insumo = B.unidad_medida_insumo;

 		DELETE FROM tem.sl_liberacion_insumos where id_solicitud = id_solicitud_ and creation_user =  usuario_;

		PERFORM opav.sl_canasta ( id_solicitud_, 1 , 2 ,_no_lote, causal_ , usuario_);

_resultado:= 'OK';
return _resultado;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_liberar_insumos(integer, integer, integer, integer, character varying)
  OWNER TO postgres;
