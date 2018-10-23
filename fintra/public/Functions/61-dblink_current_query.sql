-- Function: dblink_current_query()

-- DROP FUNCTION dblink_current_query();

CREATE OR REPLACE FUNCTION dblink_current_query()
  RETURNS text AS
'$libdir/dblink', 'dblink_current_query'
  LANGUAGE c VOLATILE;
ALTER FUNCTION dblink_current_query()
  OWNER TO postgres;
