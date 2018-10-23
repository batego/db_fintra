-- Function: tem.getultimore(text)

-- DROP FUNCTION tem.getultimore(text);

CREATE OR REPLACE FUNCTION tem.getultimore(text)
  RETURNS integer AS
$BODY$DECLARE
ultimox INTEGER;
codx ALIAS FOR $1;
BEGIN
SELECT  INTO ultimox ultimo FROM tem.consignaciones_eca_cxc_re WHERE cxc_re=codx;
UPDATE  tem.consignaciones_eca_cxc_re  SET ultimo=ultimo+1, last_update=now()  WHERE cxc_re=codx;
RETURN ultimox;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.getultimore(text)
  OWNER TO postgres;
