-- Function: anulacion_ejemplos_anticipos()

-- DROP FUNCTION anulacion_ejemplos_anticipos();

CREATE OR REPLACE FUNCTION anulacion_ejemplos_anticipos()
  RETURNS text AS
$BODY$DECLARE
  algo TEXT;
BEGIN
  UPDATE fin.anticipos_pagos_terceros_tsp SET reg_status ='A' WHERE id IN ('1234566','1234567','1234568','1234569','951753450','951753455','951753456','951753457','951753458','951753459');
  SELECT INTO algo ' Ejemplos de anticipos anulados.'	;
RETURN algo;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION anulacion_ejemplos_anticipos()
  OWNER TO postgres;
