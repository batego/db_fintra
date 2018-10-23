-- Function: get_pagaduria(text)

-- DROP FUNCTION get_pagaduria(text);

CREATE OR REPLACE FUNCTION get_pagaduria(text)
  RETURNS text AS
$BODY$DECLARE
		nitpagaduria ALIAS FOR $1;
		nompagaduria TEXT;

BEGIN
		-- Encontrar el nombre de un cliente a partir de su código.
		SELECT INTO nompagaduria razon_social
		FROM pagadurias
		WHERE documento = nitpagaduria;

		RETURN nompagaduria;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_pagaduria(text)
  OWNER TO postgres;
