-- Function: wsdc.get_prioridad_sector(character varying)

-- DROP FUNCTION wsdc.get_prioridad_sector(character varying);

CREATE OR REPLACE FUNCTION wsdc.get_prioridad_sector(sector character varying)
  RETURNS character varying AS
$BODY$
declare
    prioridad character varying;

begin
    select valor into prioridad
    from wsdc.codigo
    where tabla = 'sector_prioridad'
    and codigo = sector;

    if prioridad is null then
        prioridad = '99';
    end if;

    return prioridad;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION wsdc.get_prioridad_sector(character varying)
  OWNER TO postgres;
