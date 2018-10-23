-- Function: eg_aval_negocio(text)

-- DROP FUNCTION eg_aval_negocio(text);

CREATE OR REPLACE FUNCTION eg_aval_negocio(codneg text)
  RETURNS text AS
$BODY$
DECLARE

  retorno text:='';
  recordNegocio record;

BEGIN

  SELECT INTO recordNegocio financia_aval,negocio_rel,negocio_rel_seguro,negocio_rel_gps,id_convenio FROM negocios WHERE cod_neg=codNeg  ;

   IF(recordNegocio.financia_aval = FALSE AND recordNegocio.negocio_rel !='' AND recordNegocio.negocio_rel_seguro ='' AND recordNegocio.negocio_rel_gps ='')THEN
          IF(recordNegocio.id_convenio IN (35) )THEN
            retorno:='NEGOCIO_SEGURO';
          ELSE
            retorno:='NEGOCIO_AVAL';
          END IF;
    ELSE
      	   retorno:='NEGOCIO_PADRE';
    END IF;

    RETURN retorno;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_aval_negocio(text)
  OWNER TO postgres;
