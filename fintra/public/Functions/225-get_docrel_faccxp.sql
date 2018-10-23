-- Function: get_docrel_faccxp(text, text, text)

-- DROP FUNCTION get_docrel_faccxp(text, text, text);

CREATE OR REPLACE FUNCTION get_docrel_faccxp(text, text, text)
  RETURNS text AS
$BODY$DECLARE
  documento ALIAS FOR $1;
  proveedor ALIAS FOR $2;
  distrito  ALIAS FOR $3;
  doc_rel   TEXT;

--*************************************************************************************
-- Funcion .......... get_docrel_faccxp                                              *
-- Objetivo ......... Busca los documentos relacionados de una factura de proveedor   *
--              Ej: '036-FP001,035-FP002', 036 es el tipo de documento          *
--             relacionado y FP001 es el documento relacionado           *
-- Parametro 1 ...... numero de documento                                             *
-- Parametro 2 ...... proveedor                                                       *
-- Parametro 3 ...... distrito                                                        *
-- Fecha ............ Diciembre 14 de 2006                                            *
-- Autor ............ Ing. Osvaldo Perez                                       *
--*************************************************************************************

BEGIN
  -- Encontrar los documentos relacionados de una factura de proveedor
  SELECT INTO doc_rel documentos.docs FROM
 (
 SELECT  array_to_string( array_accum(  docrel.rel ), ',' ) AS docs FROM
  (
  SELECT cxp.tipo_documento || '-' || cxp.documento AS rel
  FROM fin.cxp_doc cxp WHERE cxp.proveedor = proveedor AND cxp.dstrct = distrito AND cxp.documento_relacionado = documento
  )docrel
 ) documentos;
  RETURN doc_rel::TEXT;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_docrel_faccxp(text, text, text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_docrel_faccxp(text, text, text) IS 'Encontrar los documentos relacionados de una factura de proveedor';
