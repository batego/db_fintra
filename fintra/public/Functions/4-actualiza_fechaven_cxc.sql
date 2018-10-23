-- Function: actualiza_fechaven_cxc(date, text)

-- DROP FUNCTION actualiza_fechaven_cxc(date, text);

CREATE OR REPLACE FUNCTION actualiza_fechaven_cxc(date, text)
  RETURNS text AS
$BODY$DECLARE

  doc TEXT;

BEGIN
  doc = 'Hecho';
 update con.factura set fecha_vencimiento = $1 where documento=$2 and tipo_documento ='FAC';


  RETURN doc;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualiza_fechaven_cxc(date, text)
  OWNER TO postgres;
