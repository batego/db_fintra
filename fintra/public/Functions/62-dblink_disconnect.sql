-- Function: dblink_disconnect(text)

-- DROP FUNCTION dblink_disconnect(text);

CREATE OR REPLACE FUNCTION dblink_disconnect(text)
  RETURNS text AS
'$libdir/dblink', 'dblink_disconnect'
  LANGUAGE c VOLATILE STRICT;
ALTER FUNCTION dblink_disconnect(text)
  OWNER TO postgres;
