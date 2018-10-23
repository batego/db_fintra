-- Function: get_nitpf(text)

-- DROP FUNCTION get_nitpf(text);

CREATE OR REPLACE FUNCTION get_nitpf(text)
  RETURNS text AS
$BODY$DECLARE
  document ALIAS FOR $1;
  nitCliente TEXT;
  codClient TEXT;
  numdoc TEXT;
  nitEnvioFid TEXT;
BEGIN

  SELECT INTO numdoc observacion
  FROM con.factura
  WHERE documento = document;

  SELECT INTO nitEnvioFid,codClient nit_enviado_fiducia,codcli
  FROM con.factura
  WHERE documento = document;

if nitEnvioFid is null then
  SELECT INTO nitEnvioFid,codClient nit_enviado_fiducia,codcli
  FROM con.factura
  WHERE documento = numdoc;
end if;
if nitEnvioFid is null then
  SELECT INTO nitCliente nit
  FROM cliente
  WHERE codcli = codClient;
else
  nitCliente:=nitEnvioFid;
end if;
  RETURN nitCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nitpf(text)
  OWNER TO postgres;
