-- Function: cambiar_sv_de_oferta_y_factura(text, text, text, text)

-- DROP FUNCTION cambiar_sv_de_oferta_y_factura(text, text, text, text);

CREATE OR REPLACE FUNCTION cambiar_sv_de_oferta_y_factura(text, text, text, text)
  RETURNS text AS
$BODY$DECLARE
  svviejo ALIAS FOR $1;
  svnuevo ALIAS FOR $2;
  multiser ALIAS FOR $3;
  cliente ALIAS FOR $4;

  respuesta TEXT;
BEGIN
  UPDATE app_ofertas SET simbolo_variable=svnuevo WHERE simbolo_variable=svviejo AND num_os=multiser AND id_cliente= cliente ;
  UPDATE ws.ms_ofertas_ftv SET simbolo_variable=svnuevo WHERE simbolo_variable=svviejo AND num_os=multiser AND id_cliente= cliente ;
  UPDATE con.factura SET last_update=NOW(), user_update='ADMINSV',ref2=svnuevo WHERE ref2=svviejo AND tipo_ref2='SV' AND tipo_ref1='MS' AND ref1=multiser AND codcli= cliente ;
  SELECT INTO respuesta ' Proceso ejecutado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_sv_de_oferta_y_factura(text, text, text, text)
  OWNER TO postgres;
