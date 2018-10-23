-- Function: get_dtf_mv(numeric)

-- DROP FUNCTION get_dtf_mv(numeric);

CREATE OR REPLACE FUNCTION get_dtf_mv(r numeric)
  RETURNS numeric AS
$BODY$

 -- Sirve para pasar una DTF + puntos (dada en TA  a una MV

 -- r = anual trimestre anticipado.

 DECLARE

 ipa numeric;
 ipv numeric;
 iev numeric;
 iea numeric;
 ip  numeric;
 rn  numeric;

        BEGIN
  ipa = (r/100)/4;   -- trimestre anticipado
  ipv = ipa/(1-ipa);   -- trimestre vencido

  iev =  ( (1+ipv) ^ 4 ) - 1;  -- efectivo anual
  iea =  ( (1-ipa) ^ -4) - 1;  -- efectivo anual

  rn = 1/12;
                ip  =  ((1+ iea) ^ 0.083333333 ) - 1; -- Tasa periÃ³dica a partir de la tasa efectiva anual

                RETURN ip * 100;
        END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_dtf_mv(numeric)
  OWNER TO postgres;
