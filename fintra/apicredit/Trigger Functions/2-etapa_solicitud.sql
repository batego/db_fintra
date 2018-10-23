-- Function: apicredit.etapa_solicitud()

-- DROP FUNCTION apicredit.etapa_solicitud();

CREATE OR REPLACE FUNCTION apicredit.etapa_solicitud()
  RETURNS "trigger" AS
$BODY$DECLARE
BEGIN

IF(NEW.actividad='REF' )THEN
  update apicredit.pre_solicitudes_creditos set etapa =4  where numero_solicitud = (SELECT numero_solicitud from solicitud_aval where cod_neg=NEW.cod_neg);
END IF ;

IF(NEW.actividad='ANA' )THEN
  update apicredit.pre_solicitudes_creditos set etapa =5  where numero_solicitud = (SELECT numero_solicitud from solicitud_aval where cod_neg=NEW.cod_neg);
END IF ;

IF(NEW.actividad='DEC' )THEN
  update apicredit.pre_solicitudes_creditos set etapa =6  where numero_solicitud = (SELECT numero_solicitud from solicitud_aval where cod_neg=NEW.cod_neg);
END IF ;

IF(NEW.actividad='FOR' )THEN
 update apicredit.pre_solicitudes_creditos set etapa =7  where numero_solicitud = (SELECT numero_solicitud from solicitud_aval where cod_neg=NEW.cod_neg);
END IF ;

IF(NEW.actividad='DES' )THEN
  update apicredit.pre_solicitudes_creditos set etapa =8  where numero_solicitud = (SELECT numero_solicitud from solicitud_aval where cod_neg=NEW.cod_neg);
END IF ;

IF(NEW.estado_neg='R' )THEN
  update apicredit.pre_solicitudes_creditos set etapa =-1  where numero_solicitud = (SELECT numero_solicitud from solicitud_aval where cod_neg=NEW.cod_neg);
END IF ;

  RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.etapa_solicitud()
  OWNER TO fintravaloressa;
