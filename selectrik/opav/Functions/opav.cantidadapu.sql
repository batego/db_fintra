-- Function: opav.cantidadapu(integer, integer)

-- DROP FUNCTION opav.cantidadapu(integer, integer);

CREATE OR REPLACE FUNCTION opav.cantidadapu(accion integer, codigo integer)
  RETURNS text AS
$BODY$
declare
    valor numeric;

begin
valor:=0.00;

select sum(ff.cantidad) into valor
		from
		opav.acciones aa
		inner join opav.sl_areas_proyecto bb on(bb.id_solicitud=aa.id_solicitud)
		inner join opav.sl_disciplinas_areas cc on(cc.id_area_proyecto=bb.id)
		inner join opav.sl_capitulos_disciplinas dd on(dd.id_disciplina_area=cc.id)
		inner join opav.sl_actividades_capitulos ee on(ee.id_capitulo=dd.id)
		inner join opav.sl_rel_actividades_apu ff on(ff.id_actividad_capitulo=ee.id)
		where
		id_accion=accion and ff.id_apu=codigo;

		if(valor is null) then
				valor:=0.00;
			end if;

 return valor;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.cantidadapu(integer, integer)
  OWNER TO postgres;
