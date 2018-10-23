-- Function: opav.sl_get_valor_cot_actividad(integer, integer)

-- DROP FUNCTION opav.sl_get_valor_cot_actividad(integer, integer);

CREATE OR REPLACE FUNCTION opav.sl_get_valor_cot_actividad(id_cap_ integer, id_act_ integer)
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
                where e.id=ac.id
                ) as sum_act_esquema into retorno


                FROM opav.sl_actividades_capitulos ac
                INNER JOIN opav.sl_actividades act ON act.id = ac.id_actividad
                WHERE ac.reg_status='' and id_capitulo in(id_cap_) and ac.id_actividad=id_act_ order by ac.id;

RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_valor_cot_actividad(integer, integer)
  OWNER TO postgres;
