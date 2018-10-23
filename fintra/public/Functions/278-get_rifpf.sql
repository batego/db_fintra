-- Function: get_rifpf(text)

-- DROP FUNCTION get_rifpf(text);

CREATE OR REPLACE FUNCTION get_rifpf(text)
  RETURNS text AS
$BODY$DECLARE
  document ALIAS FOR $1;
  rifCliente TEXT;
  codClient TEXT;
  numdoc TEXT;
BEGIN

  SELECT INTO numdoc observacion
  FROM con.factura
  WHERE documento = document;

  SELECT INTO codClient codcli
  FROM con.factura
  WHERE documento = numdoc;

  SELECT INTO rifCliente rif
  FROM cliente
  WHERE codcli = codClient;

  RETURN rifCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_rifpf(text)
  OWNER TO postgres;
