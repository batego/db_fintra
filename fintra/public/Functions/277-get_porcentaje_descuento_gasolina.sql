-- Function: get_porcentaje_descuento_gasolina(text, text)

-- DROP FUNCTION get_porcentaje_descuento_gasolina(text, text);

CREATE OR REPLACE FUNCTION get_porcentaje_descuento_gasolina(text, text)
  RETURNS numeric AS
$BODY$DECLARE
  _loginx ALIAS FOR $1;
  _agenciax ALIAS FOR $2;
  _respuesta NUMERIC;

BEGIN
  _respuesta :=-1;
  /*SELECT INTO _respuesta t.referencia::NUMERIC
  FROM tablagen t
  WHERE t.table_type='AGENCIADES' AND t.table_code=_agenciax AND t.reg_status!='A';*/

  --IF (_respuesta IS NULL OR _respuesta =-1) THEN
	SELECT INTO _respuesta d.tasa_descuento FROM login_estacion_descuento d WHERE d.loginx=_loginx;
 -- END IF;

  IF (_respuesta IS NULL OR _respuesta =-1) THEN
	_respuesta :=0;
  END IF;
  RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_porcentaje_descuento_gasolina(text, text)
  OWNER TO postgres;
