-- Function: eg_saldo_cartera_negocio(text)

-- DROP FUNCTION eg_saldo_cartera_negocio(text);

CREATE OR REPLACE FUNCTION eg_saldo_cartera_negocio(codneg text)
  RETURNS numeric AS
$BODY$
DECLARE

  saldo_cartera numeric:=0.00;

BEGIN

	SELECT coalesce(sum(valor_saldo),0.00) into saldo_cartera
	  FROM con.factura fra
	WHERE fra.dstrct = 'FINV'
	AND fra.valor_saldo > 0
	AND fra.reg_status = ''
	AND fra.negasoc = codneg
	AND fra.tipo_documento in ('FAC','NDC')
	AND substring(fra.documento,1,2) not in ('CP','FF','DF');

    RETURN saldo_cartera;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_saldo_cartera_negocio(text)
  OWNER TO postgres;
