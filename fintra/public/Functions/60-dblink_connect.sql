-- Function: dblink_connect(text, text)

-- DROP FUNCTION dblink_connect(text, text);

CREATE OR REPLACE FUNCTION dblink_connect(text, text)
  RETURNS text AS
'$libdir/dblink', 'dblink_connect'
  LANGUAGE c VOLATILE STRICT;
ALTER FUNCTION dblink_connect(text, text)
  OWNER TO postgres;
