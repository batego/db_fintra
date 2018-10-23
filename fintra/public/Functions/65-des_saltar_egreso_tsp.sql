-- Function: des_saltar_egreso_tsp(text, text, text)

-- DROP FUNCTION des_saltar_egreso_tsp(text, text, text);

CREATE OR REPLACE FUNCTION des_saltar_egreso_tsp(text, text, text)
  RETURNS text AS
$BODY$DECLARE
  branch_codex ALIAS FOR $1;
  bank_account_nox ALIAS FOR $2;
  document_nox ALIAS FOR $3;
  respuesta TEXT;
BEGIN
  UPDATE egreso_tsp SET generar_ingreso ='S' WHERE branch_code=branch_codex AND bank_account_no=bank_account_nox AND document_no=document_nox;
  SELECT INTO respuesta ' Proceso ejecutado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION des_saltar_egreso_tsp(text, text, text)
  OWNER TO postgres;
