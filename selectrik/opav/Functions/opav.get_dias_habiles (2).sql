-- Function: opav.get_dias_habiles(date, date, boolean)

-- DROP FUNCTION opav.get_dias_habiles(date, date, boolean);

CREATE OR REPLACE FUNCTION opav.get_dias_habiles(fecha_inicial date, fecha_final date, completo boolean)
  RETURNS integer AS
$BODY$
declare
    num_dias_habiles integer;
    dias_totales integer;
    dias_festivos integer;

/*
Retorna el numero de dias habiles entre 2 fechas
completo indica si en el calculo se toman dias completos(24h) o no
*/
begin
    dias_totales := fecha_final - fecha_inicial;
    select into dias_festivos count(fecha)
    from fin.dias_festivos
    where festivo=true and fecha between fecha_inicial and fecha_final;

    num_dias_habiles := dias_totales - dias_festivos;
    if num_dias_habiles < 0 then
        num_dias_habiles := 0;
    else
        if completo=false then
            num_dias_habiles := num_dias_habiles + 1;
        end if;
    end if;

    return num_dias_habiles;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.get_dias_habiles(date, date, boolean)
  OWNER TO postgres;
