-- Function: opav.sl_get_valor_cot_capitulo(integer, integer)

-- DROP FUNCTION opav.sl_get_valor_cot_capitulo(integer, integer);

CREATE OR REPLACE FUNCTION opav.sl_get_valor_cot_capitulo(id_disc_ integer, id_rel_ integer)
  RETURNS text AS
$BODY$

DECLARE
retorno text;
begin

   select   (select
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
            where d.id=cd.id
            ) as sum_act_esquema into retorno
            FROM opav.sl_capitulos_disciplinas cd
            WHERE id_disciplina_area in (id_disc_) AND cd.id=id_rel_ and reg_status = '' order by id_disciplina_area,id;

RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_valor_cot_capitulo(integer, integer)
  OWNER TO postgres;
