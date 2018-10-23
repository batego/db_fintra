-- Function: opav.exportar_wbs(integer, bigint)

-- DROP FUNCTION opav.exportar_wbs(integer, bigint);

CREATE OR REPLACE FUNCTION opav.exportar_wbs(id_solicitud_ integer, consecutivo bigint)
  RETURNS text AS
$BODY$
declare

    reg record;
    reg1 record;
    reg2 record;
    reg3 record;
    reg4 record;
    prueba text;
    nombre_area text;
    nivel_area text;
    nombre_disc text;
    nivel_disc text;
    tabla text:='tem.wbs_export_'||consecutivo;

begin

select ' CREATE TABLE '||tabla||' AS
select  nombre_proyecto::text as nombre,1 as nivel,
opav.sl_get_valor_proyecto(of.id_solicitud) as valor, opav.sl_get_valor_cot_proyecto(of.id_solicitud) as valor_cot
            from opav.ofertas of where of.id_solicitud = '''||id_solicitud_||''';' into prueba;

execute prueba;

for reg in


	SELECT 2 as nivel,ap.id as id_area_proy,coalesce(opav.sl_get_valor_area(ap.id_solicitud,ap.id),'0') as valor,
		coalesce(opav.sl_get_valor_cot_area(ap.id_solicitud,ap.id),'0') as valor_cot, ap.nombre_area
            FROM opav.sl_areas_proyecto ap WHERE id_solicitud =id_solicitud_ AND ap.reg_status = '' order by ap.id

loop
	--insert del area
	select 'insert into '||tabla||'(nombre, nivel, valor, valor_cot) values('''||reg.nombre_area||''','||reg.nivel||','''||reg.valor||''', '''||reg.valor_cot||''');' into prueba;
	execute prueba;

	for reg1 in
		SELECT da.id, coalesce(opav.sl_get_valor_disciplina(reg.id_area_proy, da.id),'0') as valor,
			coalesce(opav.sl_get_valor_cot_disciplina(reg.id_area_proy, da.id),'0') as valor_cot,
			d.nombre as nombre, 3 as nivel
		    from opav.sl_disciplinas_areas da
		    INNER JOIN opav.sl_disciplinas d ON d.id = da.id_disciplina
		    inner join opav.sl_areas_proyecto as ar on (ar.id = da.id_area_proyecto)
		    WHERE id_area_proyecto in(reg.id_area_proy) AND da.reg_status = '' order by id_area_proyecto,da.id

            loop
		--insert de disciplina
		select 'insert into '||tabla||'(nombre, nivel, valor, valor_cot) values('''||reg1.nombre||''','||reg1.nivel||','''||reg1.valor||''','''||reg1.valor_cot||''');' into prueba;
		execute prueba;

		for reg2 in

			SELECT cd.id_disciplina_area, cd.id, 4 as nivel ,
			coalesce(opav.sl_get_valor_capitulo(cd.id_disciplina_area, cd.id),'0') as valor,
			coalesce(opav.sl_get_valor_cot_capitulo(cd.id_disciplina_area, cd.id),'0') as valor_cot,
			cd.descripcion as nombre
			FROM opav.sl_capitulos_disciplinas cd
			WHERE cd.id_disciplina_area in(reg1.id) AND reg_status = '' order by id_disciplina_area,id

		loop
			--insert de capitulos
			select 'insert into '||tabla||'(nombre, nivel, valor, valor_cot) values('''||reg2.nombre||''','||reg2.nivel||','''||reg2.valor||''','''||reg2.valor_cot||''');' into prueba;
			execute prueba;


			for reg3 in

			SELECT ac.id, ac.id_capitulo, act.descripcion as nombre, ac.id_actividad,5 as nivel,
				coalesce(opav.sl_get_valor_actividad(ac.id_capitulo, ac.id_actividad),'0') as valor,
				coalesce(opav.sl_get_valor_cot_actividad(ac.id_capitulo, ac.id_actividad),'0') as valor_cot
			    FROM opav.sl_actividades_capitulos ac
			    INNER JOIN opav.sl_actividades act ON act.id = ac.id_actividad
			    WHERE ac.reg_status='' and id_capitulo in(reg2.id) order by ac.id

			    loop
				--insert de actividades
				select 'insert into '||tabla||'(nombre, nivel, valor, valor_cot) values('''||reg3.nombre||''','||reg3.nivel||','''||reg3.valor||''','''||reg3.valor_cot||''');' into prueba;
				execute prueba;

			for reg4 in
				SELECT act_apu.id, id_actividad_capitulo, act_apu.id_apu, apu.nombre, 6 as nivel,
				coalesce(opav.sl_get_valor_apu(id_solicitud_, reg3.id_capitulo, reg3.id_actividad, act_apu.id_apu),'0')as valor,
				coalesce(opav.sl_get_valor_cot_apu(id_solicitud_, reg3.id_capitulo, reg3.id_actividad, act_apu.id_apu),'0')as valor_cot
			        FROM opav.sl_rel_actividades_apu act_apu
			        INNER JOIN opav.sl_apu apu ON act_apu.id_apu = apu.id
			        WHERE id_actividad_capitulo = reg3.id AND act_apu.reg_status = '' order by act_apu.id

				loop
					--insert de apu
					select 'insert into '||tabla||'(nombre, nivel, valor, valor_cot) values('''||reg4.nombre||''','||reg4.nivel||','''||reg4.valor||''','''||reg4.valor_cot||''');' into prueba;
					execute prueba;

				end loop;

			    end loop;


		end loop;


            end loop;

end loop;



  return tabla;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.exportar_wbs(integer, bigint)
  OWNER TO postgres;
