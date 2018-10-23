-- Function: fin.proceso_rechazo_negocios(character varying, character varying)

-- DROP FUNCTION fin.proceso_rechazo_negocios(character varying, character varying);

CREATE OR REPLACE FUNCTION fin.proceso_rechazo_negocios(negocio character varying, usuario character varying)
  RETURNS text AS
$BODY$

DECLARE

resultado text;
_egreso record;

BEGIN

	--1.) Paso 1:= se rechaza  negocios y borra contabilidad si tiene
		UPDATE NEGOCIOS SET ESTADO_NEG='R' ,update_user = usuario WHERE COD_NEG IN (negocio);
		UPDATE solicitud_aval SET estado_sol ='R' ,user_update = usuario WHERE COD_NEG IN (negocio);
		raise notice 'paso update negocio: ';
		DELETE FROM CON.COMPRODET WHERE NUMDOC IN  (negocio);
		raise notice 'paso comprodet: ';
		DELETE FROM CON.COMPROBANTE WHERE NUMDOC IN  (negocio);
		raise notice 'paso comprobandte: ';

	--2.) Paso 2:= Se anulan las cxp operativas (Fianza,CXP aval, Cxp Afialido ) y borrar contabilidad

		DELETE FROM CON.COMPRODET WHERE NUMDOC IN  (SELECT documento FROM fin.cxp_doc  WHERE documento_relacionado IN (negocio)) AND TIPODOC='FAP';
		raise notice 'paso comprodet cxp: ';
		DELETE FROM CON.COMPROBANTE WHERE NUMDOC IN  (SELECT documento FROM fin.cxp_doc  WHERE documento_relacionado IN (negocio)) AND TIPODOC='FAP';

		for _egreso in
			select cheque
			from fin.cxp_doc
			where documento_relacionado in (negocio) AND tipo_documento='FAP' and cheque !=''

		loop
			UPDATE egresodet SET reg_status='A',user_update = usuario, last_update = now()  WHERE document_no in (_egreso.cheque);
			raise notice 'paso update  egresodet: ';
			UPDATE egreso SET reg_status='A', user_update = usuario, last_update = now() WHERE document_no in (_egreso.cheque);
			raise notice 'paso update  egreso: ';
		end loop;

		UPDATE fin.cxp_items_doc  SET reg_status='A', user_update = usuario,last_update = now() WHERE documento in (select documento from fin.cxp_doc  where documento_relacionado in (negocio) AND tipo_documento='FAP');
		raise notice 'paso update  cxp det: ';
		UPDATE fin.cxp_doc  SET reg_status='A' , user_update = usuario, last_update = now() WHERE documento_relacionado in (negocio) AND tipo_documento='FAP';
		raise notice 'paso update  cxp: ';

	--3.) paso 3:= Notas de ajuste (se anula operativo y se borra contable )
		DELETE FROM CON.COMPRODET WHERE NUMDOC IN (select documento from fin.cxp_doc where documento_relacionado in (select documento from fin.cxp_doc WHERE documento_relacionado in (negocio)) and tipo_documento = 'NC');
		raise notice 'paso comprodet  nc : ';
		DELETE FROM CON.COMPROBANTE WHERE NUMDOC IN (select documento from fin.cxp_doc where documento_relacionado in (select documento from fin.cxp_doc WHERE documento_relacionado in (negocio)) and tipo_documento = 'NC');
		raise notice 'paso comprobante  nc : ';

		UPDATE fin.cxp_items_doc set reg_status='A' ,user_update = usuario,last_update = now()  where documento in (
		select documento from fin.cxp_doc where documento_relacionado in (select documento from fin.cxp_doc WHERE documento_relacionado in (negocio)));
		raise notice 'paso nc det : ';
		UPDATE fin.cxp_doc set reg_status='A', user_update = usuario,last_update = now()  where documento_relacionado in (select documento from fin.cxp_doc WHERE documento_relacionado in (negocio));
		raise notice 'paso nc : ';

	--3.) Paso 3:= cartera (se anula operativo y se borra lo contable) primero borrar el detalle

		DELETE FROM CON.COMPRODET WHERE NUMDOC IN (SELECT documento FROM con.factura WHERE negasoc in (negocio) AND TIPO_DOCUMENTO='FAC');
		raise notice 'paso comprodet  cxc : ';
		DELETE FROM CON.COMPROBANTE WHERE NUMDOC IN (SELECT documento FROM con.factura WHERE negasoc in (negocio) AND TIPO_DOCUMENTO='FAC');
		raise notice 'paso comprobante  cxc : ';

		UPDATE con.factura_detalle SET REG_STATUS='A', user_update = usuario WHERE documento in (SELECT documento FROM con.factura WHERE negasoc in (negocio));
		raise notice 'paso cxc det : ';
		UPDATE con.factura SET  REG_STATUS='A', user_update = usuario WHERE  negasoc in (negocio) ;
		raise notice 'paso cxc : ';

	--4.)pasa 4:= anular los ingresos fenalco

		UPDATE ing_fenalco SET REG_STATUS ='A', user_update = usuario WHERE  codneg in (negocio);

	resultado:= 'proceso finalizado';
	return resultado;
-- 	EXCEPTION
-- 		WHEN OTHERS THEN
-- 	BEGIN
-- 		resultado:= 'un error';
-- 		return resultado;
-- 	end ;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fin.proceso_rechazo_negocios(character varying, character varying)
  OWNER TO postgres;
