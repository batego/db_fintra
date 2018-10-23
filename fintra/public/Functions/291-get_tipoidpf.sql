-- Function: get_tipoidpf(text)

-- DROP FUNCTION get_tipoidpf(text);

CREATE OR REPLACE FUNCTION get_tipoidpf(text)
  RETURNS text AS
$BODY$DECLARE
  document ALIAS FOR $1;
  nitCliente TEXT;
  codClient TEXT;
  numdoc TEXT;
BEGIN

  SELECT INTO numdoc observacion
  FROM con.factura
  WHERE documento = document;

  SELECT INTO codClient codcli
  FROM con.factura
  WHERE documento = numdoc;

  SELECT INTO nitCliente tipo_id
  FROM cliente
  WHERE codcli = codClient;

  RETURN nitCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_tipoidpf(text)
  OWNER TO postgres;
