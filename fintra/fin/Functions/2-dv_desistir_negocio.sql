-- Function: fin.dv_desistir_negocio(character varying, character varying, character varying)

-- DROP FUNCTION fin.dv_desistir_negocio(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fin.dv_desistir_negocio(negocio character varying, _usuario character varying, comentario character varying)
  RETURNS text AS
$BODY$

DECLARE

resultado text;
_egreso record;
traza  record;
_cxp_aplica_nc varchar := '';
Doc numeric;

BEGIN

	--1.) Paso 1:= se desiste el  negocio y borra contabilidad si tiene
	raise notice 'paso 1: ';
		UPDATE NEGOCIOS SET ESTADO_NEG='D' ,update_user = _usuario WHERE COD_NEG IN (negocio);
		UPDATE solicitud_aval SET estado_sol ='D' ,user_update = _usuario WHERE COD_NEG IN (negocio);
		raise notice 'paso update negocio: ';
		DELETE FROM CON.COMPRODET WHERE NUMDOC IN  (negocio);
		raise notice 'paso comprodet: ';
		DELETE FROM CON.COMPROBANTE WHERE NUMDOC IN  (negocio);
		raise notice 'paso comprobandte: ';

	--2.) Paso 2:= Se anulan las cxp operativas (Fianza,CXP aval, Cxp Afialido ) y borrar contabilidad
	raise notice 'paso 2: ';
		DELETE FROM CON.COMPRODET WHERE NUMDOC IN  (SELECT documento FROM fin.cxp_doc  WHERE documento_relacionado IN (negocio)) AND TIPODOC='FAP';
		raise notice 'paso comprodet cxp: ';
		DELETE FROM CON.COMPROBANTE WHERE NUMDOC IN  (SELECT documento FROM fin.cxp_doc  WHERE documento_relacionado IN (negocio)) AND TIPODOC='FAP';

		UPDATE fin.cxp_items_doc  SET reg_status='A', user_update = _usuario,last_update = now() WHERE documento in (select documento from fin.cxp_doc  where documento_relacionado in (negocio) AND tipo_documento='FAP');
		raise notice 'paso update  cxp det: ';
		UPDATE fin.cxp_doc  SET reg_status='A' , user_update = _usuario, last_update = now() WHERE documento_relacionado in (negocio) AND tipo_documento='FAP';
		raise notice 'paso update  cxp: ';

		for _egreso in
			select cheque
			from fin.cxp_doc
			where documento_relacionado in (negocio) AND tipo_documento='FAP' and cheque !=''

		loop
			UPDATE egresodet SET reg_status='A',user_update = _usuario, last_update = now()  WHERE document_no in (_egreso.cheque);
			raise notice 'paso update  egresodet: ';
			UPDATE egreso SET reg_status='A', user_update = _usuario, last_update = now() WHERE document_no in (_egreso.cheque);
			raise notice 'paso update  egreso: ';
		end loop;

		DELETE FROM CON.COMPRODET WHERE NUMDOC IN (_egreso.cheque);
		raise notice 'paso comprodet  egreso : ';
		DELETE FROM CON.COMPROBANTE WHERE NUMDOC IN (_egreso.cheque);
		raise notice 'paso comprobante  egreso : ';



	--3.) paso 3:= Notas de ajuste (se anula operativo y se borra contable )
	raise notice 'paso 3: ';

	select into _cxp_aplica_nc documento from fin.cxp_doc WHERE documento_relacionado in (negocio);
	--select into _nc_reversion from fin.cxp_doc WHERE documento in (_cxp_aplica_nc);

	if (_cxp_aplica_nc != '')then
		DELETE FROM CON.COMPRODET WHERE NUMDOC IN (select documento from fin.cxp_doc where documento_relacionado in (_cxp_aplica_nc) and tipo_documento = 'NC');
		raise notice 'paso comprodet  nc : ';
		DELETE FROM CON.COMPROBANTE WHERE NUMDOC IN (select documento from fin.cxp_doc where documento_relacionado in (_cxp_aplica_nc) and tipo_documento = 'NC');
		raise notice 'paso comprobante  nc : ';

		UPDATE fin.cxp_items_doc set reg_status='A' ,user_update = _usuario,last_update = now()  where documento in (
		select documento from fin.cxp_doc where documento_relacionado in (_cxp_aplica_nc));
		raise notice 'paso nc det : ';
		UPDATE fin.cxp_doc set reg_status='A', user_update = _usuario,last_update = now()  where documento_relacionado in (_cxp_aplica_nc);
		raise notice 'paso nc : ';
	end if;

	--3.) Paso 4:= cartera (se anula operativo y se borra lo contable) primero borrar el detalle
	raise notice 'paso 4: ';
		DELETE FROM CON.COMPRODET WHERE NUMDOC IN (SELECT documento FROM con.factura WHERE negasoc in (negocio) AND TIPO_DOCUMENTO='FAC');
		raise notice 'paso comprodet  cxc : ';
		DELETE FROM CON.COMPROBANTE WHERE NUMDOC IN (SELECT documento FROM con.factura WHERE negasoc in (negocio) AND TIPO_DOCUMENTO='FAC');
		raise notice 'paso comprobante  cxc : ';

		UPDATE con.factura_detalle SET REG_STATUS='A', user_update = _usuario WHERE documento in (SELECT documento FROM con.factura WHERE negasoc in (negocio));
		raise notice 'paso cxc det : ';
		UPDATE con.factura SET  REG_STATUS='A', user_update = _usuario WHERE  negasoc in (negocio) ;
		raise notice 'paso cxc : ';

	--4.)pasa 5:= anular los ingresos fenalco
	raise notice 'paso 5: ';
		UPDATE ing_fenalco SET REG_STATUS ='A', user_update = _usuario WHERE  codneg in (negocio);

	--5.) paso 6:= Insertar trazabilidad sobre el desistimiento

	raise notice 'paso 6: ';
		SELECT INTO traza * from negocios_trazabilidad  where cod_neg = negocio order by fecha desc limit 1;

		INSERT INTO negocios_trazabilidad(
		    reg_status, dstrct, numero_solicitud, actividad, usuario, fecha, cod_neg, comentarios)
		VALUES ('', 'FINV', traza.numero_solicitud, traza.actividad, _usuario, NOW(), negocio, comentario);

	--6.)  paso 7:= Foto ciclo pagos

	---No olvidar eliminar ingresos diferidos.

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
ALTER FUNCTION fin.dv_desistir_negocio(character varying, character varying, character varying)
  OWNER TO postgres;
