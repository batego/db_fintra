-- Function: cambiar_pagare(text, text)

-- DROP FUNCTION cambiar_pagare(text, text);

CREATE OR REPLACE FUNCTION cambiar_pagare(text, text)
  RETURNS text AS
$BODY$DECLARE
  pagare ALIAS FOR $1;
  negocio ALIAS FOR $2;
  respuesta TEXT;
BEGIN
  UPDATE negocios SET cpagare=pagare WHERE cod_neg=negocio;
  SELECT INTO respuesta ' Proceso ejecutado.'	;
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cambiar_pagare(text, text)
  OWNER TO postgres;
