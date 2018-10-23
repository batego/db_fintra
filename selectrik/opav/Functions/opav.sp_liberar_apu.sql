-- Function: opav.sp_liberar_apu(integer, integer, integer[], integer[], integer[], character varying)

-- DROP FUNCTION opav.sp_liberar_apu(integer, integer, integer[], integer[], integer[], character varying);

CREATE OR REPLACE FUNCTION opav.sp_liberar_apu(causal_ integer, id_solicitud_ integer, id_rel_actividades_apu_ integer[], id_apu_ integer[], id_insumo_ integer[], usuario_ character varying)
  RETURNS text AS
$BODY$

DECLARE
_resultado text:= 'Error';
_total numeric := 0;
_no_lote character varying :='';

BEGIN

	--Se obtiene el valor que se obtiene al liberar los insumos pasados por parametro
	select
		sum(costo_personalizado * cantidad_insumo * rendimiento_insumo * cantidad_apu) into  _total

	from
		opav.sl_wbs_ejecucion
	where
	id_solicitud = id_solicitud_ and
	id_rel_actividades_apu = any(id_rel_actividades_apu_) and
	id_apu = any(id_apu_) and
	id_insumo = any(id_insumo_);

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
		cantidad_apu,--cantidad_apu ?
		cantidad_insumo,--cantidad_insumo ?
		rendimiento_insumo,
		costo_personalizado,
		(cantidad_apu*cantidad_insumo*rendimiento_insumo), --cantidad_insumo_total,(cantidad_apu*cantidad_insumo*rendimiento_insumo*costo_personalizado)
		2,
		(cantidad_apu*cantidad_insumo*rendimiento_insumo*costo_personalizado),--valor_insumo_total



		now(),
		usuario_,
		_no_lote
		FROM opav.sl_wbs_ejecucion
		where
		id_solicitud = id_solicitud_ and
		id_rel_actividades_apu = any(id_rel_actividades_apu_) and
		id_apu = any(id_apu_) and
		id_insumo = any(id_insumo_);


		--se actualiza la cantidad liberada

		update
		opav.sl_wbs_ejecucion
		set cantidad_liberada = (cantidad_insumo * rendimiento_insumo * cantidad_apu)
		where
		id_solicitud = id_solicitud_ and
		id_rel_actividades_apu = any(id_rel_actividades_apu_) and
		id_apu = any(id_apu_) and
		id_insumo = any(id_insumo_);

		PERFORM opav.sl_canasta ( id_solicitud_, 1 , 2 ,_no_lote, causal_ , usuario_);


_resultado:= 'OK';
return _resultado;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_liberar_apu(integer, integer, integer[], integer[], integer[], character varying)
  OWNER TO postgres;
