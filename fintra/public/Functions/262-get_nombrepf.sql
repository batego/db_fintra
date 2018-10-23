-- Function: get_nombrepf(text)

-- DROP FUNCTION get_nombrepf(text);

CREATE OR REPLACE FUNCTION get_nombrepf(text)
  RETURNS text AS
$BODY$DECLARE
  document ALIAS FOR $1;
  nomCliente TEXT;
  codClient TEXT;
  numdoc TEXT;
BEGIN

  SELECT INTO numdoc observacion
  FROM con.factura
  WHERE documento = document;

  SELECT INTO codClient codcli
  FROM con.factura
  WHERE documento = numdoc;

  SELECT INTO nomCliente nomcli
  FROM cliente
  WHERE codcli = codClient;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombrepf(text)
  OWNER TO postgres;
