-- Function: get_egresopend_faccxp(text, text, text, text)

-- DROP FUNCTION get_egresopend_faccxp(text, text, text, text);

CREATE OR REPLACE FUNCTION get_egresopend_faccxp(text, text, text, text)
  RETURNS text AS
$BODY$DECLARE
  distrito ALIAS FOR $1;
  nit ALIAS FOR $2;
  tipodoc ALIAS FOR $3;
  doc ALIAS FOR $4;
  egre_rel   TEXT;

--*************************************************************************************
-- Funcion .......... get_egresopend_faccxp                                           *
-- Objetivo ......... Busca los egresos pendientes por imprimir relacionados          *
--         a la factura del proveedor.                                     *
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
    DISTINCT egre.dstrct || '-' || banco || '-'  || sucursal || '-'  || egre.id AS egre
   FROM
    fin.precheque egre
   JOIN  fin.precheque_detalle det ON ( egre.id = det.id )
   WHERE
    egre.dstrct = distrito
    AND egre.proveedor = nit
    AND det.tipo_documento = tipodoc
    AND det.documento = doc
    AND egre.reg_status = ''
  )docrel
 ) documentos;
  RETURN egre_rel::TEXT;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_egresopend_faccxp(text, text, text, text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_egresopend_faccxp(text, text, text, text) IS 'Encontrar los egresos pendientes relacionados a una factura de proveedor';
