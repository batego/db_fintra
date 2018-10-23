-- Function: opav.sl_get_valor_cot_disciplina(integer, integer)

-- DROP FUNCTION opav.sl_get_valor_cot_disciplina(integer, integer);

CREATE OR REPLACE FUNCTION opav.sl_get_valor_cot_disciplina(id_area_ integer, id_rel_ integer)
  RETURNS text AS
$BODY$

DECLARE
retorno text;
begin
select       (select
            sum(sum_act_esquema)
            from
            (select k.id_rel_actividades_apu, avg(k.perc_esquema) as prom_act_esquema, sum(k.valor_esquema) as sum_act_esquema
            from opav.sl_relacion_cotizacion_detalle_apu as k
            inner join opav.sl_cotizacion i on (i.id=k.id_cotizacion)
            where k.reg_status=''
            group by id_rel_actividades_apu)  as w
            inner join opav.sl_rel_actividades_apu f on(w.id_rel_actividades_apu=f.id and f.reg_status='')
            inner join opav.sl_actividades_capitulos e on(f.id_actividad_capitulo= e.id and e.reg_status='')
            inner join opav.sl_capitulos_disciplinas d on(e.id_capitulo=d.id and d.reg_status='')
            inner join opav.sl_disciplinas_areas c on(d.id_disciplina_area=c.id and c.reg_status='')
            inner join opav.sl_areas_proyecto b on(c.id_area_proyecto=b.id and b.reg_status='')
            where c.id=da.id
            ) as sum_act_esquema into retorno

            from opav.sl_disciplinas_areas da

            INNER JOIN opav.sl_disciplinas d ON d.id = da.id_disciplina
            inner join opav.sl_areas_proyecto as ar on (ar.id = da.id_area_proyecto)
            WHERE id_area_proyecto =id_area_ and da.id=id_rel_ AND da.reg_status = '' order by id_area_proyecto,da.id;


RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_valor_cot_disciplina(integer, integer)
  OWNER TO postgres;
