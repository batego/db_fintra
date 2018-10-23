-- Function: dblink(text, text)

-- DROP FUNCTION dblink(text, text);

CREATE OR REPLACE FUNCTION dblink(text, text)
  RETURNS SETOF record AS
'$libdir/dblink', 'dblink_record'
  LANGUAGE c VOLATILE STRICT;
ALTER FUNCTION dblink(text, text)
  OWNER TO postgres;
