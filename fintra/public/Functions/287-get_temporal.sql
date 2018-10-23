-- Function: get_temporal()

-- DROP FUNCTION get_temporal();

CREATE OR REPLACE FUNCTION get_temporal()
  RETURNS text AS
$BODY$DECLARE
     fname TEXT;
     cityname TEXT;
BEGIN
     SELECT INTO fname, cityname
                 table_type, table_code
     FROM tablagen
     LIMIT 1;
RETURN fname || '___' || cityname;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_temporal()
  OWNER TO postgres;
