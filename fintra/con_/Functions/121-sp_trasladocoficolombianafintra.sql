-- Function: con.sp_trasladocoficolombianafintra()

-- DROP FUNCTION con.sp_trasladocoficolombianafintra();

CREATE OR REPLACE FUNCTION con.sp_trasladocoficolombianafintra()
  RETURNS text AS
$BODY$

  DECLARE

    mcad TEXT;

    _hc_factura CHARACTER VARYING;
    _hc_factura_new CHARACTER VARYING;
    _numero_factura CHARACTER VARYING;
    _cuenta CHARACTER VARYING;
    VerifyDetails CHARACTER VARYING;

    cnt numeric;
    BolsaSaldo numeric;
    Diferencia numeric;
    VlDetFactura numeric;

    factura_items record; --con.factura;
    _InsertFacturaDetalle record;

BEGIN

	mcad = 'TERMINADO!';
	--select * from tem.traslado_corfi_fintra --PM04271_3 | PM06327_8

	FOR factura_items IN /*create table tem.traslado_corfi_fintra as*/ select * from con.factura where clasificacion1 = 'CORFIA' and valor_saldo > 0 /*and documento = 'PM04271_3'*/ LOOP

		SELECT INTO _numero_factura get_lcod('ICAC');
		cnt = 1;

		SELECT INTO _hc_factura cuenta from con.cmc_doc where cmc = factura_items.cmc and tipodoc = factura_items.tipo_documento;

		--GENERA LA CABECERA DEL DOCUMENTO DE INGRESO (NOTA AJUSTE)
		INSERT INTO con.ingreso
		(
		dstrct,
		tipo_documento,
		num_ingreso,
		codcli,
		nitcli,
		concepto,
		tipo_ingreso,
		fecha_consignacion,
		fecha_ingreso,
		branch_code,
		bank_account_no,
		codmoneda,
		agencia_ingreso,
		descripcion_ingreso,
		vlr_ingreso,
		vlr_ingreso_me,
		vlr_tasa,
		fecha_tasa,
		cant_item,
		creation_user,
		creation_date,
		base,
		cuenta
		)
		VALUES('FINV','ICA',_numero_factura,factura_items.codcli,factura_items.nit,'EC','C',now(),now(),'BANCOLOMBIA','CA','PES','OP','NOTA DE AJUSTE PARA TRAER CARTERA A FINTRA',factura_items.valor_saldo,factura_items.valor_saldo,'1.000000',substring(now(),1,10)::date,factura_items.cantidad_items,'HCUELLO',now(),'COL','13050703');

		--GENERA EL DETALLE DEL DOCUMENTO DE INGRESO (NOTA AJUSTE)
		INSERT INTO con.ingreso_detalle
		(
		dstrct,
		tipo_documento,
		num_ingreso,
		item,
		nitcli,
		valor_ingreso,
		valor_ingreso_me,
		factura,
		fecha_factura,
		tipo_doc,
		documento,
		creation_user,
		creation_date,
		base,
		cuenta,
		descripcion,
		valor_tasa,
		saldo_factura
		)
		VALUES('FINV','ICA',_numero_factura,factura_items.cantidad_items,factura_items.nit,factura_items.valor_saldo,factura_items.valor_saldo,factura_items.documento,factura_items.fecha_factura,'FAC',factura_items.documento,'HCUELLO',now(),'COL',_hc_factura,factura_items.descripcion,'1.0000000000',factura_items.valor_factura);

		--INSERTO LA FACTURA SM (CABECERA)
		INSERT INTO con.factura SELECT
		reg_status,
		dstrct,
		tipo_documento,
		'SM'||substring(documento,3),
		nit,
		codcli,
		concepto,
		fecha_factura,
		fecha_vencimiento,
		fecha_ultimo_pago,
		fecha_impresion,
		descripcion,
		observacion,
		factura_items.valor_saldo, --valor_factura,
		0, --valor_abono,
		factura_items.valor_saldo, --valor_saldo,
		factura_items.valor_saldo, --valor_facturame,
		0, --valor_abonome,
		factura_items.valor_saldo, --valor_saldome,
		valor_tasa,
		moneda,
		cantidad_items,
		forma_pago,
		agencia_facturacion,
		agencia_cobro,
		zona,
		'FIDFIV', --clasificacion1,
		clasificacion2,
		clasificacion3,
		'0',
		transaccion_anulacion,
		'0099-01-01 00:00:00',
		fecha_anulacion,
		fecha_contabilizacion_anulacion,
		base,
		last_update,
		'HCUELLO', --user_update,
		now(), --creation_date,
		'HCUELLO', --creation_user,
		fecha_probable_pago,
		flujo,
		rif,
		'SR',
		usuario_anulo,
		formato,
		agencia_impresion,
		'',
		valor_tasa_remesa,
		negasoc,
		num_doc_fen,
		obs,
		pagado_fenalco,
		corficolombiana,
		tipo_ref1,
		ref1,
		tipo_ref2,
		ref2,
		dstrct_ultimo_ingreso,
		tipo_documento_ultimo_ingreso,
		num_ingreso_ultimo_ingreso,
		item_ultimo_ingreso,
		fec_envio_fiducia,
		nit_enviado_fiducia,
		tipo_referencia_1,
		referencia_1,
		tipo_referencia_2,
		referencia_2,
		tipo_referencia_3,
		referencia_3,
		nc_traslado,
		fecha_nc_traslado,
		tipo_nc,
		numero_nc,
		factura_traslado,
		factoring_formula_aplicada,
		nit_endoso,
		devuelta,
		fc_eca,
		fc_bonificacion,
		indicador_bonificacion,
		fi_bonificacion
		FROM con.factura WHERE documento = factura_items.documento;

		--INSERTO FACTURA AC (DETALLE)
		BolsaSaldo = factura_items.valor_saldo; --ValorSaldo; --ValorFactura;
		for _InsertFacturaDetalle IN select * from con.factura_detalle where documento = factura_items.documento loop

			VerifyDetails = 'N';
			Diferencia = BolsaSaldo - _InsertFacturaDetalle.valor_unitario;

			if ( Diferencia <= 0 and BolsaSaldo > 0) then

				VlDetFactura = BolsaSaldo;

				BolsaSaldo = BolsaSaldo - _InsertFacturaDetalle.valor_unitario;
				VerifyDetails = 'S';

			elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

				VlDetFactura = _InsertFacturaDetalle.valor_unitario;

				BolsaSaldo = BolsaSaldo - _InsertFacturaDetalle.valor_unitario;
				VerifyDetails = 'S';

			end if;

			if ( VerifyDetails = 'S' ) then

				insert into con.factura_detalle select
				reg_status,
				dstrct,
				tipo_documento,
				'SM'||substring(documento,3),
				item,
				nit,
				concepto,
				factura_items.documento, --factura_items.cmc_new||substring(numero_remesa,3),
				descripcion,
				'13050703',
				cantidad,
				VlDetFactura, --valor_unitario,
				VlDetFactura, --valor_unitariome,
				VlDetFactura, --valor_item,
				VlDetFactura, --valor_itemme,
				valor_tasa,
				moneda,
				last_update,
				user_update,
				now(), --creation_date,
				'HCUELLO', --
				base,
				auxiliar,
				valor_ingreso,
				tipo_documento_rel,
				transaccion,
				documento_relacionado,
				tipo_referencia_1,
				referencia_1,
				tipo_referencia_2,
				referencia_2,
				tipo_referencia_3,
				referencia_3
				from con.factura_detalle where documento = factura_items.documento and item = _InsertFacturaDetalle.item;
			end if;
		end loop;

		--AJUSTO LA FACTURA
		UPDATE con.factura SET valor_abono = factura_items.valor_factura, valor_saldo = '0.00',valor_abonome = factura_items.valor_factura, valor_saldome = '0.00' WHERE documento = factura_items.documento;

		cnt := cnt+1;


	END LOOP;

	RETURN mcad;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.sp_trasladocoficolombianafintra()
  OWNER TO postgres;
