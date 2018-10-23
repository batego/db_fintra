-- Function: desaprobar_anticipo_gasolina(text, text)

-- DROP FUNCTION desaprobar_anticipo_gasolina(text, text);

CREATE OR REPLACE FUNCTION desaprobar_anticipo_gasolina(text, text)
  RETURNS text AS
$BODY$DECLARE
    _idanticipo ALIAS FOR $1;
    _observation ALIAS FOR $2;
    _respuesta TEXT;
BEGIN
	_respuesta :='Proceso iniciado...';

		UPDATE fin.anticipos_pagos_terceros_tsp
		SET fecha_autorizacion='0099-01-01 00:00:00', user_autorizacion=''
			,estado_pago_tercero=''
			,observacion= user_autorizacion || ' @ ' || fecha_autorizacion || ' @ ' || _observation || ' @ ' || now()
		WHERE
			id=_idanticipo
			AND fecha_autorizacion!='0099-01-01 00:00:00'
			AND user_autorizacion!=''
			AND estado_pago_tercero='A'
			AND observacion=''
			AND concept_code='10'
			AND reg_status=''
			;

RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION desaprobar_anticipo_gasolina(text, text)
  OWNER TO postgres;
