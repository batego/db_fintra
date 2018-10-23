-- Function: get_dia_pago(text)

-- DROP FUNCTION get_dia_pago(text);

CREATE OR REPLACE FUNCTION get_dia_pago(text)
  RETURNS text AS
$BODY$
declare
negocio ALIAS for $1;

dia text;
BEGIN
---obtenemos el dia de pago partir del codigo del negocio---

SELECT INTO dia substring(max(fecha_vencimiento),9)::numeric
				FROM con.factura fra
				WHERE fra.dstrct = 'FINV'
				  --AND fra.valor_saldo > 0
				  AND fra.reg_status = ''
				  AND fra.negasoc = negocio
				  AND fra.tipo_documento in ('FAC','NDC')
				  AND substring(fra.documento,1,2) not in ('CP','FF','DF','CA','MI')
				GROUP BY negasoc;

RETURN dia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_dia_pago(text)
  OWNER TO postgres;
