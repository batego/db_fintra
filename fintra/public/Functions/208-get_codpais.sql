-- Function: get_codpais(text)

-- DROP FUNCTION get_codpais(text);

CREATE OR REPLACE FUNCTION get_codpais(text)
  RETURNS text AS
$BODY$DECLARE
  codCliente ALIAS FOR $1;
  nomCliente TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³digo.
  SELECT INTO nomCliente pais
  from ciudad
  where codciu=codCliente;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_codpais(text)
  OWNER TO postgres;
