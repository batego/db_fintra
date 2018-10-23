-- Function: opav.sl_get_valor_cot_apu(integer, integer, integer, integer)

-- DROP FUNCTION opav.sl_get_valor_cot_apu(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION opav.sl_get_valor_cot_apu(id_pr integer, id_cap_ integer, id_act_ integer, id_apu_ integer)
  RETURNS text AS
$BODY$

DECLARE
retorno text;
begin

    select	sum((valor_esquema))::numeric(19,3) as total2 into retorno

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
					AND b.id_solicitud = id_pr and e.id_capitulo=id_cap_ and e.id_actividad=id_act_ and aa.id=id_apu_
					AND (costo_personalizado*cantidad_insumo*rendimiento_insumo)::numeric(19,3) >1


            GROUP BY aa.nombre,un.nombre_unidad,i.cantidad_apu;

RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_valor_cot_apu(integer, integer, integer, integer)
  OWNER TO postgres;
