-- Function: opav.sl_get_campo_apoteosys(integer, character varying)

-- DROP FUNCTION opav.sl_get_campo_apoteosys(integer, character varying);

CREATE OR REPLACE FUNCTION opav.sl_get_campo_apoteosys(id_sl_apoteosys_tablas_ integer, nombre_campo_ character varying)
  RETURNS text AS
$BODY$
DECLARE
 _resultado 	character varying :='';

BEGIN

 select valor_campo into _resultado
 from opav.sl_apoteosys_tablas_campos where id_sl_apoteosys_tablas = id_sl_apoteosys_tablas_ and nombre_campo = upper(nombre_campo_);



 RETURN _resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_campo_apoteosys(integer, character varying)
  OWNER TO postgres;
