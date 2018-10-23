-- Function: dblink_exec(text, text)

-- DROP FUNCTION dblink_exec(text, text);

CREATE OR REPLACE FUNCTION dblink_exec(text, text)
  RETURNS text AS
'$libdir/dblink', 'dblink_exec'
  LANGUAGE c VOLATILE STRICT;
ALTER FUNCTION dblink_exec(text, text)
  OWNER TO postgres;
