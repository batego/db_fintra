-- Function: calcular_intereses(numeric, numeric, numeric)

-- DROP FUNCTION calcular_intereses(numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION calcular_intereses(saldo numeric, dias numeric, tasa numeric)
  RETURNS numeric AS
$BODY$

 -- Sirve para pasar una DTF + puntos (dada en TA  a una MV
 -- r = anual trimestre anticipado.

 DECLARE

 r numeric;
 a numeric;

  BEGIN
  r = (1+(tasa/100)) ^ (dias/360);
  a =  saldo*(r)-saldo;

  RETURN a;
        END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION calcular_intereses(numeric, numeric, numeric)
  OWNER TO postgres;
