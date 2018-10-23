-- Function: dv_causal_standby(integer, character varying)

-- DROP FUNCTION dv_causal_standby(integer, character varying);

CREATE OR REPLACE FUNCTION dv_causal_standby(business integer, actividad_ character varying)
  RETURNS text AS
$BODY$

DECLARE

     DESCRIPCION_CAUSAL VARCHAR;

BEGIN

	DESCRIPCION_CAUSAL:= COALESCE((SELECT TG.DATO FROM NEGOCIOS_TRAZABILIDAD NT
					INNER JOIN TABLAGEN TG ON (NT.CAUSAL= TG.TABLE_CODE)
					WHERE TG.TABLE_TYPE IN ('CAUSACONCP','CAUSASTBY') AND NT.ACTIVIDAD=ACTIVIDAD_ AND NT.CONCEPTO ='STANDBY'
					AND NUMERO_SOLICITUD=BUSINESS ORDER BY FECHA ASC LIMIT 1),'-');

	RETURN DESCRIPCION_CAUSAL;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_causal_standby(integer, character varying)
  OWNER TO postgres;
