-- Function: valor_factura_detalle_eca(character varying, character varying)

-- DROP FUNCTION valor_factura_detalle_eca(character varying, character varying);

CREATE OR REPLACE FUNCTION valor_factura_detalle_eca(factura character varying, operacion character varying)
  RETURNS text AS
$BODY$

DECLARE

resultado text;

BEGIN
		if(operacion='comision_eca')then
			SELECT into resultado sum(valor_unitario) FROM con.factura_detalle where documento in (factura) and codigo_cuenta_contable = 'I010120064141';

		elsif (operacion='iva_eca') then
			SELECT into resultado sum(valor_unitario) FROM con.factura_detalle where documento in (factura) and codigo_cuenta_contable = '24080106';

		end if;
		raise notice 'resultado%',resultado;

		if(resultado = '' or resultado is null)then
		raise notice 'entro';
			resultado:= '0.00';
		end if;

	return resultado;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION valor_factura_detalle_eca(character varying, character varying)
  OWNER TO postgres;
