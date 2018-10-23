-- Function: get_egresorel_faccxp(text, text, text, text)

-- DROP FUNCTION get_egresorel_faccxp(text, text, text, text);

CREATE OR REPLACE FUNCTION get_egresorel_faccxp(text, text, text, text)
  RETURNS text AS
$BODY$DECLARE
  cia ALIAS FOR $1;
  nit ALIAS FOR $2;
  tipodoc ALIAS FOR $3;
  doc ALIAS FOR $4;
  egre_rel   TEXT;

--*************************************************************************************
-- Funcion .......... get_egresorel_faccxp                                            *
-- Objetivo ......... Busca los egresos relacionados a la factura del proveedor       *
-- Parametro 1 ...... Distrito                                                        *
-- Parametro 2 ...... Nit del proveedor                                               *
-- Parametro 3 ...... tipo de documento                                               *
-- Parametro 4 ...... numero del documento                                            *
-- Fecha ............ Enero 07 del 2007                                               *
-- Autor ............ Ing. AndrÃƒÆ’Ã‚Â©s Maturana De La Cruz                                 *
--*************************************************************************************

BEGIN
  -- Encontrar los documentos relacionados de una factura de proveedor
  SELECT INTO egre_rel documentos.docs FROM
 (
  SELECT  array_to_string( array_accum(  docrel.egre ), ',' ) AS docs
  FROM (
   SELECT
    det.dstrct || '-' || det.branch_code || '-'  || det.bank_account_no || '-'  || det.document_no AS egre
   FROM
    egreso egre
    JOIN egresodet det ON ( det.dstrct = egre.dstrct
       AND det.branch_code = egre.branch_code
       AND det.bank_account_no = egre.bank_account_no
       AND det.document_no = egre.document_no )
   WHERE
    egre.dstrct = cia
    AND egre.nit_proveedor = nit
    AND det.tipo_documento = tipodoc
    AND det.documento = doc
  )docrel
 ) documentos;
  RETURN egre_rel::TEXT;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_egresorel_faccxp(text, text, text, text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_egresorel_faccxp(text, text, text, text) IS 'Encontrar los egresos relacionados a una factura de proveedor';
