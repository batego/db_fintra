-- Function: con.get_sumapor(text, text)

-- DROP FUNCTION con.get_sumapor(text, text);

CREATE OR REPLACE FUNCTION con.get_sumapor(text, text)
  RETURNS text AS
$BODY$DECLARE
  pDoc  ALIAS  FOR  $1;
  pTipo ALIAS  FOR  $2;
  nSuma       INT4;

--************************************************************************************
-- Funcion .......... con.get_sumapor                                                *
-- Objetivo ......... Totaliza los % de participacion de una planilla o remesa       *
-- Parametro 1 ...... El numero de documento                                         *
-- Parametro 2 ...... Tipo de Documento: P=Planilla, R=Remesa                        *
-- Fecha ............ Diciembre 13 de 2006                                           *
-- Autor ............ Nestor Parejo Donado                                           *
--************************************************************************************
BEGIN

  IF pTipo = 'P' THEN
     SELECT INTO nSuma SUM(porcent)
     FROM public.plarem
     WHERE numpla = pDoc;
  ELSE
     SELECT INTO nSuma SUM(porcent)
     FROM public.plarem
     WHERE numrem = pDoc;
  END IF;

  RETURN ( nSuma );

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.get_sumapor(text, text)
  OWNER TO postgres;
COMMENT ON FUNCTION con.get_sumapor(text, text) IS 'Totaliza los porcentajes en plarem';
