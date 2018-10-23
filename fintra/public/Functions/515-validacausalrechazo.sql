-- Function: validacausalrechazo(text, text)

-- DROP FUNCTION validacausalrechazo(text, text);

CREATE OR REPLACE FUNCTION validacausalrechazo(text, text)
  RETURNS boolean AS
$BODY$DECLARE
  _id ALIAS FOR $1;
  _causal ALIAS FOR $2;
  _respuesta BOOLEAN;
BEGIN



  SELECT INTO _respuesta  true
            FROM   (SELECT Sum(lmd)    AS LMD,
                           Sum(no_lmd) AS NO_lMD
                     FROM   (SELECT CASE
                             WHEN linea = _causal THEN 1
                             ELSE 0
                             END AS LMD,
                             CASE
                             WHEN linea != _causal THEN 1
                             ELSE 0
                           END AS NO_LMD
                FROM   wsdc.respuesta_personalizada
                WHERE  linea != '*********** CAUSALES RECHAZO **********'
                       AND identificacion =_id
               ) AS vista) AS vista_2
            WHERE  vista_2.lmd > no_lmd;



RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION validacausalrechazo(text, text)
  OWNER TO postgres;
