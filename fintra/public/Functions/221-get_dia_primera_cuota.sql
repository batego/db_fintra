-- Function: get_dia_primera_cuota(text)

-- DROP FUNCTION get_dia_primera_cuota(text);

CREATE OR REPLACE FUNCTION get_dia_primera_cuota(text)
  RETURNS text AS
$BODY$
declare
codigo ALIAS for $1;
tabla documentos_neg_aceptado;
priemra_fecha text;
dia text;
BEGIN
---obtenemos la primera fehca de pago y el dia de la primera couta partir del codigo del negocio---
SELECT INTO priemra_fecha,dia substring(fecha,1,10), substring(fecha,9,2)
            FROM   documentos_neg_aceptado
            WHERE
            reg_status!='A' AND cod_neg=$1 and dias=(SELECT MIN(dias) from documentos_neg_aceptado where cod_neg=$1)
            ORDER BY fecha ;
RETURN dia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_dia_primera_cuota(text)
  OWNER TO postgres;
