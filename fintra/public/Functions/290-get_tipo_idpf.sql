-- Function: get_tipo_idpf(text)

-- DROP FUNCTION get_tipo_idpf(text);

CREATE OR REPLACE FUNCTION get_tipo_idpf(text)
  RETURNS text AS
$BODY$DECLARE
  document ALIAS FOR $1;
  tipo_idCliente TEXT;
  codClient TEXT;
  numdoc TEXT;
BEGIN

  SELECT INTO numdoc observacion
  FROM con.factura
  WHERE documento = document;

  SELECT INTO codClient codcli
  FROM con.factura
  WHERE documento = numdoc;

  SELECT INTO tipo_idCliente  tipo_id
  FROM cliente
  WHERE codcli = codClient;

  RETURN tipo_idCliente ;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_tipo_idpf(text)
  OWNER TO postgres;
