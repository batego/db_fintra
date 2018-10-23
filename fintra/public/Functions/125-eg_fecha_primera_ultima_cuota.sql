-- Function: eg_fecha_primera_ultima_cuota(character varying, character varying)

-- DROP FUNCTION eg_fecha_primera_ultima_cuota(character varying, character varying);

CREATE OR REPLACE FUNCTION eg_fecha_primera_ultima_cuota(_codnegocio character varying, operacion character varying)
  RETURNS text AS
$BODY$
  DECLARE
   _fecha varchar:='';
  BEGIN

	RAISE NOTICE 'operacion: % _codNegocio: %',operacion,_codNegocio;
	if(operacion='MAX')then
	  SELECT into _fecha max(fecha) FROM documentos_neg_aceptado  where cod_neg=_codNegocio and reg_Status='';

	else
	 SELECT into _fecha min(fecha) FROM documentos_neg_aceptado  where cod_neg=_codNegocio and reg_Status='';
	end if;


    RETURN _fecha;

  END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_fecha_primera_ultima_cuota(character varying, character varying)
  OWNER TO postgres;
