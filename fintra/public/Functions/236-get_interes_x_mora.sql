-- Function: get_interes_x_mora()

-- DROP FUNCTION get_interes_x_mora();

CREATE OR REPLACE FUNCTION get_interes_x_mora()
  RETURNS text AS
$BODY$DECLARE


BEGIN


  RETURN (0.0200);

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_interes_x_mora()
  OWNER TO fintravaloressa;
COMMENT ON FUNCTION get_interes_x_mora() IS 'Totaliza los porcentajes en plarem';
