-- Function: sp_grant_all_privileges(text, text, text)

-- DROP FUNCTION sp_grant_all_privileges(text, text, text);

CREATE OR REPLACE FUNCTION sp_grant_all_privileges(p_db text, p_user text, p_schema text)
  RETURNS void AS
$BODY$
DECLARE
objeto text;
BEGIN
FOR objeto IN
  SELECT tablename FROM pg_tables WHERE schemaname = p_schema
  UNION
  SELECT relname FROM pg_statio_all_sequences WHERE schemaname = p_schema
LOOP

  RAISE NOTICE 'Asignando todos los privilegios a % sobre %.%', p_user, p_schema, objeto;

  --EXECUTE 'GRANT ALL PRIVILEGES ON ' || p_db || '.' || p_schema || '.' || objeto || ' TO ' || p_user ;
  --EXECUTE 'REVOKE ALL ON ' || p_schema || '.' || objeto || ' FROM ' || p_user ;

  EXECUTE 'GRANT SELECT ON ' || p_db || '.' || p_schema || '.' || objeto || ' TO ' || p_user ;

END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_grant_all_privileges(text, text, text)
  OWNER TO postgres;
