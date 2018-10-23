-- Function: eg_tipo_negocio(text)

-- DROP FUNCTION eg_tipo_negocio(text);

CREATE OR REPLACE FUNCTION eg_tipo_negocio(codneg text)
  RETURNS text AS
$BODY$
DECLARE

  retorno text:='';
  recordNegocio record;

BEGIN

  SELECT INTO recordNegocio financia_aval,negocio_rel,negocio_rel_seguro,negocio_rel_gps,id_convenio FROM negocios where cod_neg=codNeg;

    IF(recordNegocio.financia_aval = TRUE AND recordNegocio.negocio_rel='' AND recordNegocio.id_convenio NOT IN (17,31))THEN
         retorno:='NEGOCIO_PADRE';
         IF(recordNegocio.negocio_rel_seguro !='')THEN
           retorno:='NEGOCIO_SEGURO';
         END IF;
         IF(recordNegocio.negocio_rel_gps !='')THEN
           retorno:='NEGOCIO_GPS';
         END IF;
    ELSIF(recordNegocio.financia_aval = FALSE AND recordNegocio.negocio_rel ='' AND recordNegocio.negocio_rel_seguro ='' AND recordNegocio.negocio_rel_gps =''  AND recordNegocio.id_convenio NOT IN (17,31))THEN
          retorno:='NEGOCIO_PADRE';
    ELSIF(recordNegocio.financia_aval = FALSE AND recordNegocio.negocio_rel !='' AND recordNegocio.negocio_rel_seguro ='' AND recordNegocio.negocio_rel_gps ='')THEN
          IF(recordNegocio.id_convenio IN (35) )THEN
            retorno:='NEGOCIO_SEGURO';
          ELSE
            retorno:='NEGOCIO_AVAL';
          END IF;
    ELSIF(recordNegocio.financia_aval = FALSE AND recordNegocio.negocio_rel ='' AND recordNegocio.negocio_rel_seguro !='' AND recordNegocio.negocio_rel_gps ='')THEN
          retorno:='NEGOCIO_SEGURO';
    ELSIF(recordNegocio.financia_aval = FALSE AND (recordNegocio.negocio_rel ='' or recordNegocio.negocio_rel !='' ) AND recordNegocio.negocio_rel_seguro ='' AND recordNegocio.negocio_rel_gps !='')THEN
         retorno:='NEGOCIO_GPS';
    ELSIF(recordNegocio.financia_aval in (FALSE,TRUE) AND recordNegocio.id_convenio IN (17,31))THEN
         retorno:='NEGOCIO_EDUCATIVO';
    END IF;

    RETURN retorno;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_tipo_negocio(text)
  OWNER TO postgres;
