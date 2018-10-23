-- Function: meter_dtf(character, character, character)

-- DROP FUNCTION meter_dtf(character, character, character);

CREATE OR REPLACE FUNCTION meter_dtf(character, character, character)
  RETURNS text AS
$BODY$
DECLARE  
  fecha1 ALIAS FOR $1;  
  fecha2 ALIAS FOR $2;  
  dtf ALIAS FOR $3;  
  respuesta character(100); 

BEGIN  
  respuesta = '';

  IF trim(fecha1) !~ '^([0-9]{4})-([0-9]{2})-([0-9]{2})$' THEN
	respuesta = 'La fecha de inicio ('|| fecha1 ||') no tiene el formato solicitado ';
  END IF;
  
  IF trim(fecha2) !~ '^([0-9]{4})-([0-9]{2})-([0-9]{2})$' THEN
	respuesta = 'La fecha final ('|| fecha2 ||') no tiene el formato solicitado ';
  END IF;

  IF trim(dtf) !~ E'^([0-9]{1,2})((\.|\,)[0-9]{1,3})?$' THEN
	respuesta = 'El DTF ('|| dtf ||') no cumple con el formato o tiene un valor superior a 99.999';
  END IF;
  
  IF respuesta = '' THEN 
	INSERT INTO tablagen(
	   reg_status, table_type, table_code, referencia, descripcion, 
	   last_update, user_update, creation_date, creation_user, dato)
	VALUES ('', 'DTF_SEMANA', trim(fecha1), trim(fecha2), replace(trim(dtf),',','.'), now(), 'SROBINSON', now(), 'SROBINSON', '');

    respuesta = 'Modificacion terminada. DTF('||replace(trim(dtf),',','.')||')';    
  END IF;

RETURN respuesta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION meter_dtf(character, character, character)
  OWNER TO postgres;

