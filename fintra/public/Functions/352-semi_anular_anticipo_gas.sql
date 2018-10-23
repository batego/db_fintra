-- Function: semi_anular_anticipo_gas(text)

-- DROP FUNCTION semi_anular_anticipo_gas(text);

CREATE OR REPLACE FUNCTION semi_anular_anticipo_gas(text)
  RETURNS text AS
$BODY$DECLARE
  idant ALIAS FOR $1;
  respuesta TEXT;
BEGIN
  UPDATE fin.anticipos_pagos_terceros_tsp
	SET reg_status='A'
	WHERE id=idant AND vlr_efectivo=0 AND vlr_gasolina=0 AND concept_code='10' AND estado_pago_tercero='';
  SELECT INTO respuesta ' Proceso ejecutado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION semi_anular_anticipo_gas(text)
  OWNER TO postgres;
