-- Function: fin.updateprestamo()

-- DROP FUNCTION fin.updateprestamo();

CREATE OR REPLACE FUNCTION fin.updateprestamo()
  RETURNS "trigger" AS
$BODY$DECLARE
    reg RECORD;
BEGIN
  -- extraccion de acumulados de descuentos y pago terceros
  -- valor migrado a mims y valor registrado en mims
  SELECT INTO reg
         SUM(CASE WHEN estado_descuento = '50' THEN valor_descuento ELSE 0 END )  as vDescontado,
         SUM(CASE WHEN estado_pago_ter  = '50' THEN valor_pago_ter  ELSE 0 END )  as vPagado,
         SUM(CASE WHEN fecha_transferencia!='0099-01-01 00:00:00' THEN valor_a_pagar ELSE 0 END) as vMigrado,
         SUM(CASE WHEN fecha_transferencia!='0099-01-01 00:00:00' AND  estado_descuento != ''  THEN valor_a_pagar ELSE 0 END) as vRegistrado,
         SUM(CASE WHEN estado_descuento = '50' THEN valor_capital ELSE 0 END) as vCapital,
         SUM(CASE WHEN estado_descuento = '50' THEN valor_interes ELSE 0 END) as vInteres
  FROM   fin.amortizaciones
  WHERE  dstrct = new.dstrct
    AND  prestamo = new.prestamo;


  -- actualizacion de acumulados de los prestamos
  UPDATE fin.prestamo
  SET    vlracu_pagfintra = reg.vPagado,
         vlracu_desprop   = reg.vDescontado,
         vlracu_migmims   = reg.vMigrado,
         vlracu_regmims   = reg.vRegistrado,
         vlracu_capdes    = reg.vCapital,
         vlracu_intdes    = reg.vInteres,
         user_update      = new.user_update,
         last_update      = new.last_update
  WHERE
         dstrct = new.dstrct
     AND id     = new.prestamo;



  RAISE NOTICE 'Descuento %, Pagado %',reg.vDescontado, reg.vPagado;

  RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fin.updateprestamo()
  OWNER TO postgres;
