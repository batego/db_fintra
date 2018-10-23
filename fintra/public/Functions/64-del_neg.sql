-- Function: del_neg(text)

-- DROP FUNCTION del_neg(text);

CREATE OR REPLACE FUNCTION del_neg(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  retcod TEXT;
begin
	--NEGOCIOS
	Update negocios
	set
	estado_neg='R'
	where
	cod_neg=varpar;
	--COMPROBANTE Y COMPRODET DE LOS NEGOCIOS


	--FACTURA
	update con.factura
	set reg_status='A'
	where negasoc = varpar;

	--FACTURA DETALLE
	update con.factura_detalle
	set reg_status = 'A'
	where documento in (select documento from con.factura where negasoc = varpar);

	--INGRESOS DIFERIDOS DE FENALCO
	update
	ing_fenalco
	set reg_status='A'
	where codneg=varpar;

	--CUENTAS POR PAGAR
	update fin.cxp_doc
	set	reg_status='A'
	where   tipo_documento_rel ='NEG'
	and	documento_relacionado =varpar;

	--CXP ITEMS
	update fin.cxp_items_doc
	set reg_status='A'
	where	planilla=varpar;

	--EGRESO DET
	UPDATE
	egresodet
	SET
	reg_status='A'
	WHERE
	documento in (SELECT documento from fin.cxp_items_doc where planilla = varpar );

	--EGRESO
	UPDATE
		egreso
	SET
		reg_status='A'
	where
		document_no in
		(select document_no from egresodet where documento in
		(SELECT documento from fin.cxp_items_doc where planilla =varpar ));

	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION del_neg(text)
  OWNER TO postgres;
