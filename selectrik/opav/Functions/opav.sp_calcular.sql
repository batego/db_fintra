-- Function: opav.sp_calcular(character varying)

-- DROP FUNCTION opav.sp_calcular(character varying);

CREATE OR REPLACE FUNCTION opav.sp_calcular(id_solicitud_ character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE

_id_accion numeric;
_id_cotizacion numeric;
_cotos_indirectos numeric;
_perc_iva_compensar numeric;
 cotizacion record;
 rs_1 record;
 rs_2 record;

 --select * from opav.sp_generar_cotizacion('920030') as (nombre_area character varying, nombre_capitulo character varying, nombre_apu text, nombre_unidad character varying,cantidad_apu numeric, valor_unitario numeric, total numeric) ;

 BEGIN

		SELECT
			id_accion INTO _id_accion
		from
			opav.acciones
		where
			id_solicitud = id_solicitud_
			and accion_principal = 1;


		SELECT
			 valor_total INTO _cotos_indirectos
		from
			opav.sl_costos_admon_proyecto
		where
			num_solicitud = id_solicitud_;


		SELECT INTO rs_1
			subtotal,valor_cotizacion,perc_administracion,perc_imprevisto,perc_utilidad,subtotal/valor_cotizacion as totalcomision
		FROM
			opav.sl_cotizacion
		WHERE
			id_accion = _id_accion;


	        SELECT * INTO rs_2  FROM  opav.eg_calcular_costo_contratista_aiu2(rs_1.valor_cotizacion,rs_1.perc_administracion,rs_1.perc_imprevisto,rs_1.perc_utilidad,rs_1.totalcomision);

		_perc_iva_compensar:=coalesce((rs_2._ivaCompensar/rs_1.subtotal)+1,1);
		_cotos_indirectos:=coalesce((_cotos_indirectos/rs_1.subtotal)+1,1);







	FOR cotizacion IN
				select
					b.id as id_area,b.nombre_area,d.id as id_capitulo ,d.descripcion as nombre_capitulo , aa.nombre as nombre_apu , un.nombre_unidad, i.cantidad_apu,
					(sum(i.valor_esquema * (
					CASE WHEN cot.modalidad_comercial = 1
						then ((CASE WHEN ab.id_tipo_insumo = 1
							THEN 1.16
							ELSE 1 END)
						*_perc_iva_compensar)
						ELSE 1 END )
					*_cotos_indirectos)/i.cantidad_apu)::numeric(19,2) as valor_unitario,
					sum(i.valor_esquema * (CASE WHEN cot.modalidad_comercial = 1 then (
					(CASE WHEN ab.id_tipo_insumo = 1 THEN 1.16 ELSE 1 END)*_perc_iva_compensar) ELSE 1 END )*_cotos_indirectos)::numeric(19,2) as total
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
					b.id,b.nombre_area,d.id,d.descripcion, aa.nombre,un.nombre_unidad, i.cantidad_apu
				HAVING
					sum(i.valor_esquema) !=0
				ORDER BY
					b.nombre_area,d.descripcion
	LOOP

	RETURN NEXT cotizacion;

	END LOOP;

	raise notice '_id_accion :%', _id_accion;
	raise notice 'rs_1 :%', rs_1;
	raise notice 'rs_2 :%', rs_2;
	raise notice '_cotos_indirectos :%', _cotos_indirectos;
	raise notice 'perc_iva_compensar :%', _perc_iva_compensar;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_calcular(character varying)
  OWNER TO postgres;
