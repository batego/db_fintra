-- Function: cambiar_sv_recaudo(text, text)

-- DROP FUNCTION cambiar_sv_recaudo(text, text);

CREATE OR REPLACE FUNCTION cambiar_sv_recaudo(text, text)
  RETURNS text AS
$BODY$DECLARE
  svviejo ALIAS FOR $1;
  svnuevo ALIAS FOR $2;
  respuesta TEXT;
BEGIN
  UPDATE recaudo_eca SET simbolo_variable=svnuevo WHERE simbolo_variable=svviejo;
  SELECT INTO respuesta ' Proceso ejecutado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_sv_recaudo(text, text)
  OWNER TO postgres;
