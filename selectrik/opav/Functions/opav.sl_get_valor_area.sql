-- Function: opav.sl_get_valor_area(character varying, integer)

-- DROP FUNCTION opav.sl_get_valor_area(character varying, integer);

CREATE OR REPLACE FUNCTION opav.sl_get_valor_area(_id_solicitud character varying, area_ integer)
  RETURNS text AS
$BODY$

DECLARE
retorno text;
begin
select (select
            sum(sum_valor)
            from
            (select id_rel_actividades_apu, sum(k.cantidad_insumo*k.rendimiento_insumo * k.cantidad_apu *
            case
            k.costo_personalizado
            when 0 then  k.valor_insumo
            else k.costo_personalizado
            end) as sum_valor
            from opav.sl_relacion_cotizacion_detalle_apu as k
            inner join opav.sl_cotizacion i on (i.id=k.id_cotizacion)
            where k.reg_status=''
            group by id_rel_actividades_apu)  as w
            inner join opav.sl_rel_actividades_apu f on(w.id_rel_actividades_apu=f.id and f.reg_status='')
            inner join opav.sl_actividades_capitulos e on(f.id_actividad_capitulo= e.id and e.reg_status='')
            inner join opav.sl_capitulos_disciplinas d on(e.id_capitulo=d.id and d.reg_status='')
            inner join opav.sl_disciplinas_areas c on(d.id_disciplina_area=c.id and c.reg_status='')
            inner join opav.sl_areas_proyecto b on(c.id_area_proyecto=b.id and b.reg_status='')
            where b.id=ap.id) as valor into retorno
            FROM opav.sl_areas_proyecto ap WHERE id_solicitud =_id_solicitud and ap.id=area_ AND ap.reg_status = '' order by ap.id;
RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_valor_area(character varying, integer)
  OWNER TO postgres;
