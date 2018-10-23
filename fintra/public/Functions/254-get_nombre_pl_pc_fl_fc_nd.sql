-- Function: get_nombre_pl_pc_fl_fc_nd(text)

-- DROP FUNCTION get_nombre_pl_pc_fl_fc_nd(text);

CREATE OR REPLACE FUNCTION get_nombre_pl_pc_fl_fc_nd(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  nomCliente TEXT;

BEGIN

  SELECT INTO nomCliente cliente.nomcli
  FROM
	cliente,
	con.factura f
  WHERE
	f.documento = codFactura
	AND f.nit = cliente.nit;

  RETURN nomCliente;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombre_pl_pc_fl_fc_nd(text)
  OWNER TO postgres;
