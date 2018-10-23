-- Function: opav.get_fecha_hist_acciones(character varying, character varying, character varying)

-- DROP FUNCTION opav.get_fecha_hist_acciones(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.get_fecha_hist_acciones(id_accion character varying, estado character varying, contratista character varying)
  RETURNS date AS
$BODY$declare
    fecha date;

begin
    -- retorna la primera fecha hcreation_date para la accion y estado recibidos
    if estado = '020' then
        select into fecha min(hcreation_date)::date
        from opav.historico_acciones ha
        where ha.estado=estado and ha.contratista!=contratista and ha.id_accion=id_accion;
    else
        select into fecha min(hcreation_date)::date
        from opav.historico_acciones ha
        where ha.estado=estado and ha.id_accion=id_accion;
    end if;

  return fecha;

end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.get_fecha_hist_acciones(character varying, character varying, character varying)
  OWNER TO postgres;
