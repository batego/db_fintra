-- Function: tem.tabla_correos_anticipos()

-- DROP FUNCTION tem.tabla_correos_anticipos();

CREATE OR REPLACE FUNCTION tem.tabla_correos_anticipos()
  RETURNS "trigger" AS
$BODY$DECLARE
existe TEXT ;
BEGIN
SELECT INTO existe id FROM tem.correos_anticipos WHERE id=NEW.id;
IF  (existe IS NULL OR existe ='') THEN
	INSERT INTO tem.correos_anticipos(
            reg_status, id, dstrct, agency_id, pla_owner, planilla,
            concept_code,
            last_update,creation_date,
            secuencia,
            enviado, fecha_envio)
    VALUES (NEW.reg_status, NEW.id, 'FINV', NEW.agency_id, NEW.pla_owner, NEW.planilla,
            NEW.concept_code,  NEW.last_update, NEW.creation_date,
            NEW.secuencia,
            NEW.enviado, NEW.fecha_envio);
END IF;
  RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.tabla_correos_anticipos()
  OWNER TO postgres;
