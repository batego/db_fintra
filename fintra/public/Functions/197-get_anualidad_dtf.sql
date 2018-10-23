-- Function: get_anualidad_dtf(numeric, numeric, numeric)

-- DROP FUNCTION get_anualidad_dtf(numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION get_anualidad_dtf(vp numeric, dtf numeric, n numeric)
  RETURNS numeric AS
$BODY$

 -- Sirve para pasar conseguir el valor de una anualidad especificando una DTF + puntos que sera convertida en Mensual Vencida
 -- (DTF dada en TA+puntos a una MV)

 -- r = anual trimestre anticipado.

 DECLARE

 r numeric;
 factor numeric;
 a numeric;
 i numeric;

        BEGIN


  i = get_dtf_mv(dtf);

  r = (1+(i/100)) ^ n;

  factor =  (r-1)/(i/100*r);
	if (factor!=0) then
		a = vp / factor;
	else
		a=0;
	end if;

                RETURN a;
        END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_anualidad_dtf(numeric, numeric, numeric)
  OWNER TO postgres;
