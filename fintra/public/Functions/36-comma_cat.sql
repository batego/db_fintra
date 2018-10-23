-- Function: comma_cat(text, text)

-- DROP FUNCTION comma_cat(text, text);

CREATE OR REPLACE FUNCTION comma_cat(text, text)
  RETURNS text AS
$BODY$select case
 WHEN $2 is null or $2 = '' THEN $1
 WHEN $1 is null or $1 = '' THEN $2
 ELSE $1 || ' ' || $2
 END$BODY$
  LANGUAGE sql VOLATILE;
ALTER FUNCTION comma_cat(text, text)
  OWNER TO postgres;
