-- Function: apicredit.update_solicitud_laboral()

-- DROP FUNCTION apicredit.update_solicitud_laboral();

CREATE OR REPLACE FUNCTION apicredit.update_solicitud_laboral()
  RETURNS "trigger" AS
$BODY$DECLARE

BEGIN

update solicitud_laboral set direccion_cobro = NEW.direccion where numero_solicitud = NEW.numero_solicitud and tipo ='S';


  RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.update_solicitud_laboral()
  OWNER TO postgres;
