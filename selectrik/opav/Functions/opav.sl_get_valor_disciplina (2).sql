-- Function: opav.sl_get_valor_disciplina(integer, integer)

-- DROP FUNCTION opav.sl_get_valor_disciplina(integer, integer);

CREATE OR REPLACE FUNCTION opav.sl_get_valor_disciplina(id_area_ integer, id_rel_ integer)
  RETURNS text AS
$BODY$

DECLARE
retorno text;
begin
select
            (select
            --to_char(coalesce(sum(i.valor_insumo*(f.cantidad*(i.cantidad_insumo*i.rendimiento_insumo))),0),'LFM9,999,999,999,999')
            --to_char(coalesce(sum(i.precio_compra*(f.cantidad*(g.cantidad*g.rendimiento))),0),'LFM9,999,999')
            coalesce(sum(
            (coalesce((SELECT
            case
            k.costo_personalizado
            when 0 then  k.valor_insumo
            else k.costo_personalizado
            end
            FROM opav.sl_cotizacion i
            inner join opav.sl_cotizacion_detalle j on(j.id_cotizacion=i.id)
            inner join opav.sl_relacion_cotizacion_detalle_apu k on(k.id_cotizacion=i.id and k.id_insumo=j.id_insumo)
            where i.id_accion=a.id_accion and j.id_insumo=g.id_insumo and k.id_unidad_medida=g.id_unidad_medida group by case
            k.costo_personalizado
            when 0 then  k.valor_insumo
            else k.costo_personalizado
            end
            limit 1)::numeric,0))*(f.cantidad*(g.cantidad*g.rendimiento))),0)


            from
            opav.acciones a
            inner join opav.sl_areas_proyecto b on(b.id_solicitud=a.id_solicitud)
            inner join opav.sl_disciplinas_areas c on(c.id_area_proyecto=b.id)
            inner join opav.sl_capitulos_disciplinas d on(d.id_disciplina_area=c.id)
            inner join opav.sl_actividades_capitulos e on(e.id_capitulo=d.id)
            inner join opav.sl_rel_actividades_apu f on(f.id_actividad_capitulo=e.id)
            inner join opav.sl_apu_det g on(g.id_apu=f.id_apu)
            inner join opav.sl_cotizacion h on(h.id_accion=a.id_accion)
            inner join opav.sl_relacion_cotizacion_detalle_apu i on(i.id_cotizacion=h.id and i.id_rel_actividades_apu=f.id and i.id_insumo=g.id_insumo)

            where
            /*a.id_solicitud=ap.id_solicitud and b.id=ap.id*/ c.id=da.id and f.reg_status='' and e.reg_status='') as valor into retorno

            from opav.sl_disciplinas_areas da

            INNER JOIN opav.sl_disciplinas d ON d.id = da.id_disciplina
            inner join opav.sl_areas_proyecto as ar on (ar.id = da.id_area_proyecto)
            WHERE id_area_proyecto =id_area_ and da.id=id_rel_ AND da.reg_status = '' order by id_area_proyecto,da.id;


RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_valor_disciplina(integer, integer)
  OWNER TO postgres;
