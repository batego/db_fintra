-- Function: existe_precheque(text, text, text, text)

-- DROP FUNCTION existe_precheque(text, text, text, text);

CREATE OR REPLACE FUNCTION existe_precheque(text, text, text, text)
  RETURNS text AS
$BODY$DECLARE
  p_distrito 	 ALIAS FOR $1;
  p_proveedor 	 ALIAS FOR $2;
  p_tipo_documento ALIAS FOR $3;
  p_documento 	 ALIAS FOR $4;
  existe TEXT;
  docu    TEXT;

--**************************************************************************************
-- Funcion .......... existe_precheque
-- Objetivo ......... retorna S o N dependiendo si el registro existe en precheque con
--		      reg_status '' (pendiente por imprimir)
-- Parametro 1 ...... Distrito
-- Parametro 2 ...... Proveedor
-- Parametro 3 ...... Tipo de documento
-- Parametro 4 ...... Documento
-- Fecha ............ Mayo 4 de 2006
-- Autor ............ Osvaldo PÃƒÂ©rez Ferrer
--**************************************************************************************

BEGIN
  existe :='N';


  	SELECT INTO docu documento
	FROM 	fin.precheque_detalle a
	WHERE 	a.dstrct = p_distrito AND
		a.proveedor =  p_proveedor AND
		a.tipo_documento = p_tipo_documento AND
		a.documento = p_documento AND
		a.reg_status = '';


    IF FOUND THEN
         existe :='S';
    END IF;

  RETURN existe;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION existe_precheque(text, text, text, text)
  OWNER TO postgres;
