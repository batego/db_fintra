-- Function: opav.test_test(character varying)

-- DROP FUNCTION opav.test_test(character varying);

CREATE OR REPLACE FUNCTION opav.test_test(oc_ character varying)
  RETURNS character varying AS
$BODY$
DECLARE

 _resultado 		character varying 	:='OK';


BEGIN

	select case when oc_ ilike '%OC%' then 1 ELSE 2 END INTO _resultado;


 RETURN _resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.test_test(character varying)
  OWNER TO postgres;
