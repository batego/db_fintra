-- Function: get_validar_primera_cuota(text, text)

-- DROP FUNCTION get_validar_primera_cuota(text, text);

CREATE OR REPLACE FUNCTION get_validar_primera_cuota(text, text)
  RETURNS text AS
$BODY$
declare
tabla documentos_neg_aceptado;
dia boolean;
BEGIN
---obtenemos la primera fehca de pago y el dia de la primera couta partir del codigo del negocio---
SELECT into dia case when substring(fecha,1,10)=$2 then true else false end as resultado
            FROM   documentos_neg_aceptado
            WHERE
            reg_status!='A' AND cod_neg=$1 and dias=(SELECT MIN(dias) from documentos_neg_aceptado where cod_neg=$1)
            ORDER BY fecha ;
RETURN dia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_validar_primera_cuota(text, text)
  OWNER TO postgres;
