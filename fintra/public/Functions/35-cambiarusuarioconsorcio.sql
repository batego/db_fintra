-- Function: cambiarusuarioconsorcio(text)

-- DROP FUNCTION cambiarusuarioconsorcio(text);

CREATE OR REPLACE FUNCTION cambiarusuarioconsorcio(text)
  RETURNS text AS
$BODY$DECLARE
  userx ALIAS FOR $1;
  respuesta TEXT;
BEGIN
  SELECT INTO respuesta ' Proceso ejecutado.'	;
  IF (NOT EXISTS (SELECT reg_status FROM tablagen WHERE table_type='USRCONSORC' AND table_code=userx AND reg_status='A')) THEN
	UPDATE tablagen SET reg_status='A' WHERE table_type='USRCONSORC' AND table_code=userx ;
  ELSE
	UPDATE tablagen SET reg_status='' WHERE table_type='USRCONSORC' AND table_code=userx ;
  END IF;
  IF (NOT EXISTS (SELECT reg_status FROM tablagen WHERE table_type='USRCONSORC' AND table_code=userx )) THEN
	INSERT INTO tablagen(reg_status, table_type, table_code, referencia, descripcion,
            last_update, user_update, creation_date, creation_user, dato)
    VALUES ('', 'USRCONSORC', userx, '', 'usuario de consorcio', now(), 'X', NOW(), 'X', '');
  END IF;

RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiarusuarioconsorcio(text)
  OWNER TO postgres;
