-- Function: modificar_agencia_anticipo(text, text)

-- DROP FUNCTION modificar_agencia_anticipo(text, text);

CREATE OR REPLACE FUNCTION modificar_agencia_anticipo(text, text)
  RETURNS text AS
$BODY$DECLARE  	
    _idanticipo ALIAS FOR $1; 
    _agenciax ALIAS FOR $2; 
    _respuesta TEXT;        
BEGIN  
	_respuesta :='Proceso iniciado...';
	IF (        EXISTS (SELECT a.agency_id FROM fin.anticipos_pagos_terceros a WHERE a.agency_id=_agenciax LIMIT 1)
		AND EXISTS (SELECT b.id FROM fin.anticipos_pagos_terceros b WHERE b.id=_idanticipo AND b.numero_operacion='')
		AND EXISTS (SELECT c.id FROM fin.anticipos_pagos_terceros_tsp c WHERE c.id=_idanticipo AND c.estado_pago_tercero='')
		) THEN 		
		UPDATE fin.anticipos_pagos_terceros d SET agency_id=_agenciax WHERE d.id=_idanticipo;
		UPDATE fin.anticipos_pagos_terceros_tsp e SET agency_id=_agenciax WHERE e.id=_idanticipo;		
	END IF;	
RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION modificar_agencia_anticipo(text, text)
  OWNER TO postgres;

