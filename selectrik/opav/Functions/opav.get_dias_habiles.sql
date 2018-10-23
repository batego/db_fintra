-- Function: opav.get_dias_habiles(date, date)

-- DROP FUNCTION opav.get_dias_habiles(date, date);

CREATE OR REPLACE FUNCTION opav.get_dias_habiles(fecha_inicial date, fecha_final date)
  RETURNS integer AS
$BODY$
declare
    num_dias_habiles integer;
    dias_totales integer;
    dias_festivos integer;

begin
    -- retorna el numero de dias habiles entre 2 fechas
    dias_totales := fecha_final - fecha_inicial;
    select into dias_festivos count(fecha)
    from fin.dias_festivos
    where festivo=true and fecha between fecha_inicial and fecha_final;

    num_dias_habiles := dias_totales - dias_festivos;
    if num_dias_habiles < 0 then
        num_dias_habiles := 0;
    end if;

    return num_dias_habiles;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.get_dias_habiles(date, date)
  OWNER TO postgres;
