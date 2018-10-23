-- Function: tem.eg_fecha_actividad_negocio(integer, character varying, character varying)

-- DROP FUNCTION tem.eg_fecha_actividad_negocio(integer, character varying, character varying);

CREATE OR REPLACE FUNCTION tem.eg_fecha_actividad_negocio(_numero_solicitud integer, _actividad character varying, _standby character varying)
  RETURNS timestamp without time zone AS
$BODY$
DECLARE
 _fecha timestamp;
BEGIN

        IF(_ACTIVIDAD IN ('RAD','REF','ANA','DEC','FOR','DES') AND _STANDBY='' )THEN

		_FECHA := COALESCE((SELECT MIN(FECHA)::TIMESTAMP
				    FROM NEGOCIOS_TRAZABILIDAD
				    WHERE NUMERO_SOLICITUD=_NUMERO_SOLICITUD AND ACTIVIDAD = _ACTIVIDAD
				    AND CONCEPTO NOT IN ('STANDBY','DEV_STANDBY')),'0101-01-01');

	ELSIF(_ACTIVIDAD IN ('REF','ANA','DEC','FOR','DES') AND _STANDBY IN ('STANDBY','DEV_STANDBY') )THEN

		_FECHA := COALESCE((SELECT MIN(FECHA)::TIMESTAMP
				    FROM NEGOCIOS_TRAZABILIDAD
				    WHERE NUMERO_SOLICITUD=_NUMERO_SOLICITUD AND ACTIVIDAD = _ACTIVIDAD AND CONCEPTO=_STANDBY
				   ),'0101-01-01');

	ELSIF(_ACTIVIDAD IN ('PRE') AND _STANDBY IN ('STAND BY','DEV_STANDBY') )THEN



		 _FECHA :=COALESCE((SELECT MIN(FECHA)::TIMESTAMP
					FROM APICREDIT.PRE_SOLICITUDES_TRAZABILIDAD
				    WHERE NUMERO_SOLICITUD=_NUMERO_SOLICITUD AND ESTADO=_STANDBY),'0101-01-01');

	END IF;

-- 	--validacion para SOLICITUDES SIN TRAZA.
-- 	IF(_FECHA ='0101-01-01' AND _ACTIVIDAD IN ('RAD','REF','ANA','DEC','FOR','DES'))THEN
--
-- 		return _fecha_flag;
--
-- 	END IF;

	RETURN _FECHA;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.eg_fecha_actividad_negocio(integer, character varying, character varying)
  OWNER TO postgres;
