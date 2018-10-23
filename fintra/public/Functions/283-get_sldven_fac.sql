-- Function: get_sldven_fac(text, text)

-- DROP FUNCTION get_sldven_fac(text, text);

CREATE OR REPLACE FUNCTION get_sldven_fac(text, text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  neg text;
  resp TEXT;

begin

         select into resp SUM(fct.valor_saldo)  FROM con.factura fct
         WHERE fct.fecha_vencimiento < now()::date AND reg_status!='A'
               and    fct.nit = $1 and fct.codcli=$2;

	RETURN resp;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_sldven_fac(text, text)
  OWNER TO postgres;
