-- Function: generar_pms_ias(text, character varying)

-- DROP FUNCTION generar_pms_ias(text, character varying);

CREATE OR REPLACE FUNCTION generar_pms_ias(text, character varying)
  RETURNS text AS
$BODY$DECLARE
  _facs ALIAS FOR $1;
  _usuari ALIAS FOR $2;
  _respuesta TEXT;
  _consulta		TEXT;
  _regs			RECORD;
  _numero_ing	CHARACTER VARYING;
BEGIN
  _consulta:='SELECT *  FROM con.factura WHERE documento IN (' || _facs || ')';
  FOR _regs IN EXECUTE (_consulta) LOOP
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
            tipo_nc, numero_nc, factura_traslado)
	VALUES (_regs.reg_status, _regs.dstrct, _regs.tipo_documento, 'PM'||substr(_regs.documento,3), _regs.nit, _regs.codcli, _regs.concepto,
            _regs.fecha_factura, _regs.fecha_vencimiento, _regs.fecha_ultimo_pago, _regs.fecha_impresion,
            _regs.descripcion || ' . FAC_NM: ' || _regs.documento, _regs.observacion, _regs.valor_factura, _regs.valor_abono, _regs.valor_saldo,
            _regs.valor_facturame, _regs.valor_abonome, _regs.valor_saldome, _regs.valor_tasa, _regs.moneda,
            _regs.cantidad_items, _regs.forma_pago, _regs.agencia_facturacion, _regs.agencia_cobro,
            _regs.zona, _regs.clasificacion1, _regs.clasificacion2, _regs.clasificacion3, 0,
            _regs.transaccion_anulacion, '0099-01-01 00:00:00', '0099-01-01 00:00:00',
            '0099-01-01 00:00:00', _regs.base, NOW(), _usuari,
            NOW(), _usuari, _regs.fecha_probable_pago, _regs.flujo, _regs.rif,
            'OP', '' , _regs.formato, _regs.agencia_impresion, '', _regs.valor_tasa_remesa,
            _regs.negasoc, _regs.num_doc_fen, _regs.obs, _regs.pagado_fenalco, _regs.corficolombiana, _regs.tipo_ref1,
            _regs.ref1, _regs.tipo_ref2, _regs.ref2, _regs.dstrct_ultimo_ingreso, _regs.tipo_documento_ultimo_ingreso,
            _regs.num_ingreso_ultimo_ingreso, _regs.item_ultimo_ingreso, _regs.fec_envio_fiducia,
            _regs.nit_enviado_fiducia, _regs.tipo_referencia_1, _regs.referencia_1, _regs.tipo_referencia_2,
            _regs.referencia_2, _regs.tipo_referencia_3, _regs.referencia_3, _regs.nc_traslado, _regs.fecha_nc_traslado,
            _regs.tipo_nc, _regs.numero_nc, _regs.factura_traslado);

	INSERT INTO con.factura_detalle(
            reg_status, dstrct, tipo_documento, documento, item, nit, concepto,
            numero_remesa, descripcion, codigo_cuenta_contable, cantidad,
            valor_unitario, valor_unitariome, valor_item, valor_itemme, valor_tasa,
            moneda, last_update, user_update, creation_date, creation_user,
            base, auxiliar, valor_ingreso, tipo_documento_rel, transaccion,
            documento_relacionado, tipo_referencia_1, referencia_1, tipo_referencia_2,
            referencia_2, tipo_referencia_3, referencia_3)
	 (SELECT fd.reg_status, fd.dstrct, fd.tipo_documento, 'PM'||substr(fd.documento,3), fd.item, fd.nit, fd.concepto,
            fd.documento/*20100527*/ AS numero_remesa, fd.descripcion, '16252076' AS codigo_cuenta_contable, fd.cantidad,
            fd.valor_unitario, fd.valor_unitariome, fd.valor_item, fd.valor_itemme, fd.valor_tasa,
            fd.moneda, NOW(), _usuari, NOW(), _usuari,
            fd.base, fd.auxiliar, fd.valor_ingreso, fd.tipo_documento_rel, fd.transaccion,
            fd.documento_relacionado, fd.tipo_referencia_1, fd.referencia_1, fd.tipo_referencia_2,
            fd.referencia_2, fd.tipo_referencia_3, fd.referencia_3
           FROM con.factura_detalle fd
           WHERE fd.documento=_regs.documento AND fd.reg_status='');

	SELECT INTO _numero_ing get_lcod('ICAC');

	INSERT INTO con.ingreso(
            reg_status, dstrct, tipo_documento, num_ingreso, codcli, nitcli,
            concepto, tipo_ingreso, fecha_consignacion, fecha_ingreso, branch_code,
            bank_account_no, codmoneda, agencia_ingreso, descripcion_ingreso,
            periodo, vlr_ingreso, vlr_ingreso_me, vlr_tasa, fecha_tasa, cant_item,
            transaccion, transaccion_anulacion, fecha_impresion, fecha_contabilizacion,
            fecha_anulacion_contabilizacion, fecha_anulacion, creation_user,
            creation_date, user_update, last_update, base, nro_consignacion,
            periodo_anulacion, cuenta, auxiliar, abc, tasa_dol_bol, saldo_ingreso,
            cmc, corficolombiana, fec_envio_fiducia, tipo_referencia_1, referencia_1,
            tipo_referencia_2, referencia_2, tipo_referencia_3, referencia_3)
	 (SELECT '' AS reg_status, 'FINV' AS dstrct, 'ICA' AS tipo_documento, _numero_ing AS num_ingreso, f.codcli, f.nit AS nitcli,
            'EC' AS concepto, 'C' AS tipo_ingreso, NOW() AS fecha_consignacion, NOW() AS fecha_ingreso, '' AS branch_code,
            '' AS bank_account_no, 'PES' AS codmoneda, 'OP' AS agencia_ingreso, f.descripcion AS descripcion_ingreso,
            '' AS periodo, f.valor_saldo AS vlr_ingreso, f.valor_saldo AS vlr_ingreso_me, 1 AS vlr_tasa, NOW() AS fecha_tasa, 1 AS cant_item,
            0 AS transaccion, 0 AS transaccion_anulacion, '0099-01-01 00:00:00' AS fecha_impresion, '0099-01-01 00:00:00' AS fecha_contabilizacion,
            '0099-01-01 00:00:00' AS fecha_anulacion_contabilizacion, '0099-01-01 00:00:00' AS fecha_anulacion, _usuari AS creation_user,
            NOW() AS creation_date, _usuari AS user_update, NOW() AS last_update, 'COL' AS base, '' AS nro_consignacion,
            '' AS periodo_anulacion, '16252076' AS cuenta, '' AS auxiliar, '' AS abc, 0 AS tasa_dol_bol, 0 AS saldo_ingreso,
            f.cmc, '' AS corficolombiana, '0099-01-01 00:00:00' AS fec_envio_fiducia, '' AS tipo_referencia_1, '' AS referencia_1,
            '' AS tipo_referencia_2, '' AS referencia_2, '' AS tipo_referencia_3, '' AS referencia_3
           FROM con.factura f
           WHERE f.documento=_regs.documento );

         INSERT INTO con.ingreso_detalle(
            reg_status, dstrct, tipo_documento, num_ingreso, item, nitcli,
            valor_ingreso, valor_ingreso_me, factura, fecha_factura, codigo_retefuente,
            valor_retefuente, valor_retefuente_me, tipo_doc, documento, codigo_reteica,
            valor_reteica, valor_reteica_me, valor_diferencia_tasa, creation_user,
            creation_date, user_update, last_update, base, cuenta, auxiliar,
            fecha_contabilizacion, fecha_anulacion_contabilizacion, periodo,
            fecha_anulacion, periodo_anulacion, transaccion, transaccion_anulacion,
            descripcion, valor_tasa, saldo_factura, procesado,  ref1,
            tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
            tipo_referencia_3, referencia_3)
	 (SELECT '' AS reg_status, 'FINV' AS dstrct, 'ICA' AS tipo_documento, _numero_ing AS num_ingreso, 1 AS item, f.nit AS nitcli,
            f.valor_saldo AS valor_ingreso, f.valor_saldo AS valor_ingreso_me, f.documento AS factura, f.fecha_factura, '' AS codigo_retefuente,
            0 AS valor_retefuente, 0 AS valor_retefuente_me, 'FAC' AS tipo_doc, f.documento, '' AS codigo_reteica,
            0 AS valor_reteica, 0 AS valor_reteica_me, 0 AS valor_diferencia_tasa, _usuari AS creation_user,
            NOW() AS creation_date, _usuari AS user_update, NOW() AS last_update, 'COL' AS base, '13050601' AS cuenta, '' AS auxiliar,
            '0099-01-01 00:00:00' AS fecha_contabilizacion, '0099-01-01 00:00:00' AS fecha_anulacion_contabilizacion, '' AS periodo,
            '0099-01-01 00:00:00' AS fecha_anulacion, '' AS periodo_anulacion, 0 AS transaccion, 0 AS transaccion_anulacion,
            f.descripcion, 1 AS valor_tasa, f.valor_saldo AS saldo_factura, 'NO' AS procesado, '' AS ref1,
            '' AS tipo_referencia_1, '' AS referencia_1, '' AS tipo_referencia_2, '' AS referencia_2,
            '' AS tipo_referencia_3, '' AS referencia_3
           FROM con.factura f
           WHERE f.documento=_regs.documento );

	update
	  con.factura f
	set
	  fecha_ultimo_pago = now()::date,
	  valor_abono  = valor_factura,
	  valor_saldo  = 0,
	  valor_abonome = valor_factura,
	  valor_saldome = 0,
	  dstrct_ultimo_ingreso = 'FINV',
	  tipo_documento_ultimo_ingreso = 'ICA',
	  num_ingreso_ultimo_ingreso = _numero_ing,
	  item_ultimo_ingreso = 1
	where
	  f.dstrct = 'FINV' and
	  f.tipo_documento = 'FAC' and
	  f.documento = _regs.documento ;

  END LOOP;

	--MALTAMIRANDA
	INSERT INTO tablagen(
		    reg_status, table_type, table_code, referencia, descripcion,
		    last_update, user_update, creation_date, creation_user, dato)
	    VALUES ('', 'REPFIDECA', REPLACE(REPLACE(REPLACE(NOW(),'-',''),':',''),'.',''), '', generar_reporte_fiducia_eca(REPLACE(_facs,'NM','PM')),
		    '0099-01-01 00:00:00', '', NOW(), _usuari, '');

  SELECT INTO _respuesta ' Proceso terminado.';
RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION generar_pms_ias(text, character varying)
  OWNER TO postgres;
