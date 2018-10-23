-- Function: get_tir_no_periodica(numeric, text)

-- DROP FUNCTION get_tir_no_periodica(numeric, text);

CREATE OR REPLACE FUNCTION get_tir_no_periodica(valor_desembolso numeric, codneg text)
  RETURNS numeric AS
$BODY$


DECLARE
  a NUMERIC;
  b NUMERIC;
  c NUMERIC;
  h NUMERIC;
  valc NUMERIC;
  TIR_P NUMERIC;

BEGIN
	a:=0;
	b:=0.8;
	h:=1;
	WHILE h<3000  LOOP
		valc:=0;
		c:=(a+b)/2;
		SELECT INTO valc sum(valor_presente)
		FROM	( SELECT fac1.documento,fac1.valor_factura,fac1.valor_factura/pow((1+c),COALESCE (fac1.fecha_ultimo_pago,fac1.fecha_vencimiento)-cast((select f_desem from negocios where cod_neg='NG00348') as date)) as valor_presente
			  FROM con.factura fac1
			  WHERE fac1.negasoc='NG00348' AND fac1.tipo_documento='FAC' AND fac1.reg_status='' AND fac1.documento LIKE 'F%' AND fac1.cmc='01'
			) AS tabla;
		if (valc<valor_desembolso) then
			b:=c;
		else
			a:=c;
		end if;

		if(valc-valor_desembolso<0.0001 and valc-valor_desembolso>-0.0001) then
			TIR_P:=c;
			h:=3000;
		end if;
		h:=h+1;
	END LOOP;
	if TIR_P is null then TIR_P:=99999;
	end if;
  RETURN TIR_P;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_tir_no_periodica(numeric, text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_tir_no_periodica(numeric, text) IS 'Obtiene la TIR periodica mensual de un negocio  get_TIR(valor_desembolso,codigo_negocio)';
