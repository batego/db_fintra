-- Function: apicredit.eg_presolicitudes_tramite(character varying)

-- DROP FUNCTION apicredit.eg_presolicitudes_tramite(character varying);

CREATE OR REPLACE FUNCTION apicredit.eg_presolicitudes_tramite(_identificacion character varying)
  RETURNS integer AS
$BODY$
DECLARE

  _entramite integer:=-1;
  recordTramite record;

BEGIN

	FOR recordTramite IN (
				SELECT numero_solicitud,
				       identificacion,
				       fecha_credito,
				       fecha_pago,
				       estado_sol,
				       etapa,
				       now()::date-fecha_pago::date as dias_restantes_al_pago,
				       now()::date-fecha_credito::date as dias_transcurridos
				FROM apicredit.pre_solicitudes_creditos
				WHERE CASE WHEN _identificacion='' THEN 1=1 ELSE identificacion=_identificacion END  AND etapa between 0 and 2 AND estado_sol='P'
			     )

        LOOP
		IF(recordTramite.dias_transcurridos >=15 )THEN

		  UPDATE apicredit.pre_solicitudes_creditos
			SET estado_sol='C' ,last_update=now() , user_update='APICREDIT'
		  WHERE identificacion=recordTramite.identificacion AND  etapa between 0 and 2 AND estado_sol='P' AND numero_solicitud=recordTramite.numero_solicitud;

		END IF;
		raise notice 'recordTramite: %',recordTramite;

        END LOOP;

	IF(_identificacion !='')THEN
		SELECT INTO _entramite count(0) as entramite  FROM apicredit.pre_solicitudes_creditos  where identificacion=_identificacion and etapa between 0 and 2 and estado_sol='P';
	END IF;

	return _entramite;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_presolicitudes_tramite(character varying)
  OWNER TO postgres;
