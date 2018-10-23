-- Function: get_cuenta_impuesto(text, text, text, text)

-- DROP FUNCTION get_cuenta_impuesto(text, text, text, text);

CREATE OR REPLACE FUNCTION get_cuenta_impuesto(text, text, text, text)
  RETURNS text AS
$BODY$DECLARE

  distrito ALIAS FOR $1;
  codigo ALIAS FOR $2;
  codigo_agencia ALIAS FOR $3;
  codigo_concepto ALIAS FOR $4;
  cuenta_contable TEXT;

BEGIN


   SELECT INTO cuenta_contable cod_cuenta_contable
   FROM
     tipo_de_impuesto
   WHERE
     dstrct = distrito AND
     codigo_impuesto = codigo AND
     agencia = codigo_agencia AND
     concepto = codigo_concepto
   ORDER BY
     fecha_vigencia desc
   LIMIT 1;

   IF(cuenta_contable is null) THEN
     cuenta_contable = '';
   END IF;


   RETURN cuenta_contable;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_cuenta_impuesto(text, text, text, text)
  OWNER TO postgres;
