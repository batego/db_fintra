-- Function: cambiar_fac_conformed_accion(text, text)

-- DROP FUNCTION cambiar_fac_conformed_accion(text, text);

CREATE OR REPLACE FUNCTION cambiar_fac_conformed_accion(text, text)
  RETURNS text AS
$BODY$DECLARE
  nueva_fac ALIAS FOR $1;
  accion ALIAS FOR $2;
  respuesta TEXT;
BEGIN
  UPDATE app_accord
	SET fact_conformada=nueva_fac
	WHERE id_accion=accion;
  UPDATE ws.ms_interface_accord_ftv
	SET fact_conformada=nueva_fac,
		factura_contratista=nueva_fac
	WHERE id_accion=accion;

  SELECT INTO respuesta ' ModificaciÃ³n terminada.'	;


RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_fac_conformed_accion(text, text)
  OWNER TO postgres;
