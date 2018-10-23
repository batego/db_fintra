-- Function: con.eg_cxc_pm_fintra(character varying, character varying)

-- DROP FUNCTION con.eg_cxc_pm_fintra(character varying, character varying);

CREATE OR REPLACE FUNCTION con.eg_cxc_pm_fintra(usuario character varying, documentofactura character varying)
  RETURNS boolean AS
$BODY$

DECLARE

	rs boolean :=TRUE;

BEGIN
		--1.)Creamos la cabecera de la factura PM.
		INSERT INTO con.factura(
			    reg_status, dstrct, tipo_documento, documento, nit, codcli, concepto,
			    fecha_factura, fecha_vencimiento, fecha_ultimo_pago, fecha_impresion,
			    descripcion, observacion, valor_factura, valor_abono, valor_saldo,
			    valor_facturame, valor_abonome, valor_saldome, valor_tasa, moneda,
			    cantidad_items, forma_pago, agencia_facturacion, agencia_cobro,
			    zona, clasificacion1, clasificacion2, clasificacion3, transaccion,
			    transaccion_anulacion, fecha_contabilizacion, fecha_anulacion,
			    fecha_contabilizacion_anulacion, base, last_update, user_update,
			    creation_date, creation_user, fecha_probable_pago, flujo, rif,
			    cmc, usuario_anulo, formato, agencia_impresion, periodo, valor_tasa_remesa,
			    negasoc, num_doc_fen, obs, pagado_fenalco, corficolombiana, tipo_ref1,
			    ref1, tipo_ref2, ref2, dstrct_ultimo_ingreso, tipo_documento_ultimo_ingreso,
			    num_ingreso_ultimo_ingreso, item_ultimo_ingreso, fec_envio_fiducia,
			    nit_enviado_fiducia, tipo_referencia_1, referencia_1, tipo_referencia_2,
			    referencia_2, tipo_referencia_3, referencia_3, nc_traslado, fecha_nc_traslado,
			    tipo_nc, numero_nc, factura_traslado, factoring_formula_aplicada,
			    nit_endoso, devuelta, fc_eca, fc_bonificacion, indicador_bonificacion,
			    fi_bonificacion, endoso_fenalco)

		SELECT reg_status, dstrct, tipo_documento, documento, nit, codcli, concepto,
		       fecha_factura, fecha_vencimiento, fecha_ultimo_pago, fecha_impresion,
		       descripcion, observacion, valor_factura, 0.00::numeric as valor_abono, valor_factura as valor_saldo,
		       valor_facturame, 0.00::numeric as valor_abonome,valor_factura as valor_saldome, valor_tasa, moneda,
		       cantidad_items, forma_pago, agencia_facturacion, agencia_cobro,
		       zona, clasificacion1, clasificacion2, clasificacion3, transaccion,
		       transaccion_anulacion, fecha_contabilizacion, fecha_anulacion,
		       fecha_contabilizacion_anulacion, base, last_update, user_update,
		       NOW(), usuario, fecha_probable_pago, flujo, rif,
		       cmc, usuario_anulo, formato, agencia_impresion, periodo, valor_tasa_remesa,
		       negasoc, num_doc_fen, obs, pagado_fenalco, corficolombiana, tipo_ref1,
		       ref1, tipo_ref2, ref2, dstrct_ultimo_ingreso, tipo_documento_ultimo_ingreso,
		       num_ingreso_ultimo_ingreso, item_ultimo_ingreso, fec_envio_fiducia,
		       nit_enviado_fiducia, tipo_referencia_1, referencia_1, tipo_referencia_2,
		       referencia_2, tipo_referencia_3, referencia_3, nc_traslado, fecha_nc_traslado,
		       tipo_nc, numero_nc, factura_traslado, factoring_formula_aplicada,
		       nit_endoso, devuelta, fc_eca, fc_bonificacion, indicador_bonificacion,
		      fi_bonificacion, endoso_fenalco
		from con.factura_dblink where reg_status='' AND tipo_documento ='FAC' and documento=documentoFactura  ;

		--2.)creamos el detalle de la factura PM

		INSERT INTO con.factura_detalle(
			    reg_status, dstrct, tipo_documento,documento, item, nit, concepto,
			    numero_remesa, descripcion, codigo_cuenta_contable, cantidad,
			    valor_unitario, valor_unitariome, valor_item, valor_itemme, valor_tasa,
			    moneda, last_update, user_update, creation_date, creation_user,
			    base, auxiliar, valor_ingreso, tipo_documento_rel, transaccion,
			    documento_relacionado, tipo_referencia_1, referencia_1, tipo_referencia_2,
			    referencia_2, tipo_referencia_3, referencia_3)

		select reg_status, dstrct, tipo_documento, documento, item, nit, concepto,
			    numero_remesa, descripcion,con.eg_buscar_cuenta_mapa(codigo_cuenta_contable,concepto) as codigo_cuenta_contable,cantidad,
			    valor_unitario, valor_unitariome, valor_item, valor_itemme, valor_tasa,
			    moneda, last_update, user_update, NOW(), usuario,
			    base, auxiliar, valor_ingreso, tipo_documento_rel, transaccion,
			    documento_relacionado, tipo_referencia_1, referencia_1, tipo_referencia_2,
			    referencia_2, tipo_referencia_3, referencia_3
		from con.factura_detalle_dblink where reg_status='' AND tipo_documento ='FAC' and documento=documentoFactura  ;

	RETURN  rs;
/*
EXCEPTION

	WHEN others THEN

		RAISE EXCEPTION 'ERROR AL CREAR LA FACTURA PM EN FINTRA';*/

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.eg_cxc_pm_fintra(character varying, character varying)
  OWNER TO postgres;
