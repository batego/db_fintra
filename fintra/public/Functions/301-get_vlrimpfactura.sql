-- Function: get_vlrimpfactura(text, text, text, text, text, text, text)

-- DROP FUNCTION get_vlrimpfactura(text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION get_vlrimpfactura(text, text, text, text, text, text, text)
  RETURNS moneda AS
$BODY$DECLARE
 
  nDistrito     ALIAS  FOR  $1;
  nPropietario  ALIAS  FOR  $2;
  nTipoDoc      ALIAS  FOR  $3;
  nDocumento    ALIAS  FOR  $4;
  nAgencia      ALIAS  FOR  $5;
  nFechaFac     ALIAS  FOR  $6;
  nParametro    ALIAS  FOR  $7;
 

  valor                NUMERIC(15,2);
  nFechaDoc            TEXT;
  nAge                 TEXT;
 
--************************************************************************************
-- Funcion .......... get_vlrIMPFactura                                              *
-- Objetivo ......... Busca el valor del tipo de impuesto de una factura             *
-- Parametro 1 ...... El distrito  de la Factura                                     *
-- Parametro 2 ...... El Propietario de la Factura                                   *
-- Parametro 3 ...... El Tipo de Documento de Factura                                *
-- Parametro 4 ...... El Documento o factura                                         *
-- Parametro 5 ...... Codigo Agencia Factura                                         *
-- Parametro 6 ...... Fecha de la Factura                                            *
-- Parametro 7 ...... Parametro de Busqueda:                                         *
--                    IVA   : Devuelve total iva aplicado a la factura               *
--                    RIVA  : Devuelve total Riva aplicado a la factura              *
--                    RICA  : Devuelve total Rica aplicado a la factura              *
--                    RFTE  : Devuelve total retenciÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â³n aplicado a la factura         *
--                    BRUTO : Devuelve valor bruto de la Factura                     *
-- Fecha ............ Octubre  25 de 2006                                            *
-- Autor ............ Ing. Fernel Villacob                                      *
--************************************************************************************
 

BEGIN
 
     valor      := 0;
     nFechaDoc  := nFechaFac; 
     nAge       := nAgencia;
 

     -- Formamos fecha vigencia a partir fecha del documento.
      BEGIN
            IF ( nFechaDoc    IS NULL  OR   nFechaDoc = ''  )  THEN
                 nFechaDoc := '0099-01-01';
            ELSE
                nFechaDoc := substr(nFechaDoc,1,4) || '-12-31';
            END IF;
      EXCEPTION WHEN  others THEN
            nFechaDoc := '0099-01-01';
      END;
 
 
 

      IF ( nParametro='IVA' OR  nParametro='RIVA'  OR  nParametro='RICA'  OR  nParametro='RFTE'  ) THEN
 
          IF (  nParametro = 'RFTE'  OR    nParametro='IVA'  OR   nParametro='RIVA'  ) THEN 
                nAge := '';
          END IF;
 
          -- Buscamos  el total de un tipo de Impuesto aplicado a la factura
                  SELECT
                          INTO  valor  SUM( coalesce( a.vlr_total_impuesto_me,0 )  ) as total 
                  FROM    
                          fin.cxp_imp_item  a,
                          tipo_de_impuesto  b
                  WHERE
                          a.dstrct           = nDistrito
                     AND  a.proveedor        = nPropietario
                     AND  a.tipo_documento   = nTipoDoc
                     AND  a.documento        = nDocumento
 
                     AND  b.dstrct           =  a.dstrct
                     AND  b.codigo_impuesto  =  a.cod_impuesto
                     AND  b.fecha_vigencia   =  nFechaDoc
                     AND  b.agencia          =  nAge
                     AND  b.concepto         =  ''
                     AND  b.tipo_impuesto    =  nParametro;
 

      ELSIF  ( nParametro='BRUTO' ) THEN
 
              SELECT
                       INTO  valor  SUM(coalesce(a.vlr_me,0 )) as total 
 
              FROM    
                       fin.cxp_items_doc  a
              WHERE
                          a.dstrct           = nDistrito
                     AND  a.proveedor        = nPropietario
                     AND  a.tipo_documento   = nTipoDoc
                     AND  a.documento        = nDocumento;
 
      END IF;
 

      IF ( valor  IS NULL ) THEN 
            valor := 0;
      END IF;
 

  RETURN ( valor );
 
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_vlrimpfactura(text, text, text, text, text, text, text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_vlrimpfactura(text, text, text, text, text, text, text) IS 'Retorna valores totales de Impuesto y bruto de una factura';

