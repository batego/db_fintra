-- Function: insert_cotizacion_manual(character)

-- DROP FUNCTION insert_cotizacion_manual(character);

CREATE OR REPLACE FUNCTION insert_cotizacion_manual(character)
  RETURNS text AS
$BODY$DECLARE  
  id ALIAS FOR $1;  
  respuesta character(100); 

BEGIN   

INSERT INTO opav.cotizacion(idcotizacion,consecutivo, fecha, id_accion)  
VALUES (nextval('opav.cotizacion_idcotizacion_seq'),get_lcod('COTSER'), now(),id) 
returning consecutivo into  respuesta;


RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION insert_cotizacion_manual(character)
  OWNER TO postgres;

