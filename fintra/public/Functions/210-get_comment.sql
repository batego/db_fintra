-- Function: get_comment(text)

-- DROP FUNCTION get_comment(text);

CREATE OR REPLACE FUNCTION get_comment(text)
  RETURNS text AS
$BODY$DECLARE
  factura ALIAS FOR $1;
  coment TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³digo.
  SELECT INTO coment array_accum(creation_user||': '||creation_date||' - '||observacion)
  FROM con.factura_observacion
  WHERE documento = factura;

  RETURN coment;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_comment(text)
  OWNER TO postgres;
