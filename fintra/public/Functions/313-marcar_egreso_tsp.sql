-- Function: marcar_egreso_tsp(text, text, text, text)

-- DROP FUNCTION marcar_egreso_tsp(text, text, text, text);

CREATE OR REPLACE FUNCTION marcar_egreso_tsp(text, text, text, text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  banco ALIAS FOR $2;
  sucursal ALIAS FOR $3;
  documento ALIAS FOR $4;
  respuesta TEXT;
BEGIN

--ACTUALIZO
	UPDATE egreso_tsp 
	SET generar_ingreso = varpar
	WHERE 
		dstrct = 'TSP' 
		AND branch_code = banco
		AND bank_account_no = sucursal
		AND document_no = documento;
	
	SELECT INTO respuesta ' Actualizacion terminada.'	;    
	
	RETURN respuesta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION marcar_egreso_tsp(text, text, text, text)
  OWNER TO postgres;

