-- Function: desmontar_recaudo_eca_nuevo_no_aplicado()

-- DROP FUNCTION desmontar_recaudo_eca_nuevo_no_aplicado();

CREATE OR REPLACE FUNCTION desmontar_recaudo_eca_nuevo_no_aplicado()
  RETURNS text AS
$BODY$DECLARE
  respuesta TEXT;
BEGIN

  UPDATE recaudo_eca_nuevo
  SET reg_status='A'
  WHERE reg_status!='A' AND factura='' AND fecha_cruce='0099-01-01 00:00:00' AND procesado='N' AND saldo_recaudo=valor_recaudo;

  SELECT INTO respuesta ' Recaudo nuevo de eca no aplicado fue desmontado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION desmontar_recaudo_eca_nuevo_no_aplicado()
  OWNER TO postgres;
