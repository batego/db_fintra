-- Function: opav.sl_set_combo_by_user(character varying)

-- DROP FUNCTION opav.sl_set_combo_by_user(character varying);

CREATE OR REPLACE FUNCTION opav.sl_set_combo_by_user(usuario_ character varying)
  RETURNS text AS
$BODY$

DECLARE
_es_super integer;

begin
 SELECT into _es_super count(*) from opav.sl_super_bodeguista;

RETURN 'ok';
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_set_combo_by_user(character varying)
  OWNER TO postgres;
