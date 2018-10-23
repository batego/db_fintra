-- Function: get_anualidad(numeric, numeric, numeric)

-- DROP FUNCTION get_anualidad(numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION get_anualidad(vp numeric, i numeric, n numeric)
  RETURNS numeric AS
$BODY$

 -- Sirve para pasar una DTF + puntos (dada en TA  a una MV

 -- r = anual trimestre anticipado.

 DECLARE

 r numeric;
 factor numeric;
 a numeric;

        BEGIN
  r = (1+(i/100)) ^ n;

  factor =  (r-1)/(i/100*r);

  a = vp / factor;

                RETURN a;
        END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_anualidad(numeric, numeric, numeric)
  OWNER TO postgres;
