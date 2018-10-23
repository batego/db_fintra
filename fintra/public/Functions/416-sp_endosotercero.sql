-- Function: sp_endosotercero(character varying, character varying)

-- DROP FUNCTION sp_endosotercero(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_endosotercero(facturafromjava character varying, idconvenio character varying)
  RETURNS text AS
$BODY$

  DECLARE

    mcad TEXT;
    FacEndoso CHARACTER VARYING;
    FacPadre CHARACTER VARYING;
    _NumRemesa CHARACTER VARYING;
    _DocumenType CHARACTER VARYING;
    FacPadreEndosada CHARACTER VARYING;

    DiferenciaSaldoAbono numeric;
    VerificadorIngreso CHARACTER VARYING;
    VerifyDetails CHARACTER VARYING;
    SeDevoluciona CHARACTER VARYING;

    CuentaCabecera varchar;
    CuentaDetalle varchar;
    periodo_corriente varchar;


    _FacDetalle numeric;
    ValorFactura numeric;
    VlDetFactura numeric;
    ValorAbono numeric;
    ValorSaldo numeric;
    BolsaSaldo numeric;
    Diferencia numeric;
    _ValorIngreso numeric;

    _hc_factura record;
    _ConveniosFacFiducia record;
    _FacPadre record;
    _InsertFacturaDetalle record;
    BankPay record;
    VeryfyFacturaOnFoto record;

  BEGIN

	FACEndoso = '';
	FacPadre = '';
	_DocumenType = '';
	FacPadreEndosada = '';
	VerificadorIngreso = '';
	SeDevoluciona = '';
	CuentaCabecera = '';
	CuentaDetalle = '';

	_ValorIngreso = 0; --50444.00;

	periodo_corriente = replace(substring(now()::date,1,7),'-','');

	SELECT INTO _hc_factura *
	,(select tneg from negocios where cod_neg = con.factura.negasoc) as tneg
	,(select valor_saldo from con.factura f where documento = (select documento from con.factura_detalle where numero_remesa = FacturaFromJava and substring(documento,1,2) in ('FF','CP','PF') limit 1)) as valor_saldo_cp
	--,case when (select valor_ingreso from con.ingreso_detalle where factura = con.factura.documento and creation_date::date = now()::date) is null then 0 else (select valor_ingreso from con.ingreso_detalle where factura = con.factura.documento and creation_date::date = now()::date) end as valor_ingreso
	FROM con.factura WHERE documento = FacturaFromJava;

	--select i.num_ingreso, i.descripcion_ingreso, i.branch_code, i.bank_account_no, i.fecha_ingreso, i.fecha_consignacion, sum(id.valor_ingreso) as valor_ingreso --mingreso
	select into BankPay sum(i.vlr_ingreso) as valor_ingreso  --sum(id.valor_ingreso) as valor_ingreso
	from con.ingreso_detalle id, con.ingreso i
	where id.num_ingreso = i.num_ingreso
	and id.dstrct = i.dstrct
	and id.tipo_documento = i.tipo_documento
	and id.dstrct = 'FINV'
	and id.tipo_documento in ('ING','ICA')
	and i.reg_status = ''
	and id.reg_status = ''
	and id.documento = FacturaFromJava
	and substring(i.num_ingreso,1,2) = 'IA'
	and replace(substring(i.fecha_consignacion,1,7),'-','') = periodo_corriente
	and i.concepto in ('EFP','EFF');
	--group by i.num_ingreso, i.descripcion_ingreso, i.branch_code, i.bank_account_no, i.fecha_ingreso, i.fecha_consignacion

	if found then
		_ValorIngreso = BankPay.valor_ingreso;
	end if;



	--DiferenciaSaldoAbono = _hc_factura.valor_factura - _hc_factura.valor_saldo_cp;
	/*
		DiferenciaSaldoAbono = BankPay.valor_ingreso;
		ValorFactura = DiferenciaSaldoAbono;
		ValorAbono = 0;
		ValorSaldo = DiferenciaSaldoAbono;
		VerificadorIngreso = 'OK';
	*/

	--IF ( _hc_factura.valor_ingreso != 0  ) THEN
	IF ( _ValorIngreso != 0  ) THEN
		DiferenciaSaldoAbono = _ValorIngreso; --_hc_factura.valor_ingreso;
		ValorFactura = DiferenciaSaldoAbono;
		ValorAbono = 0;
		ValorSaldo = DiferenciaSaldoAbono;

		VerificadorIngreso = 'OK';
	ELSE
		DiferenciaSaldoAbono = 0; --_hc_factura.valor_factura - _hc_factura.valor_saldo_cp;
		ValorFactura = _hc_factura.valor_factura;
		ValorAbono = _hc_factura.valor_factura - _hc_factura.valor_saldo_cp;
		ValorSaldo = _hc_factura.valor_saldo_cp;

		VerificadorIngreso = 'BAD';

	END IF;


	IF ( VerificadorIngreso = 'OK' ) THEN

		--SELECT INTO _ConveniosFacFiducia *, (select prefix from series where document_type = convenios_cxc_fiducias.prefijo_factura_endoso) as mprefijo from convenios_cxc_fiducias WHERE id_convenio = idConvenio and titulo_valor = _hc_factura.tneg and nit_fiducia = (select nit_fiducia from convenios_fiducias where id_convenio = idconvenio and cuenta_dif_fiducia = (select cuenta_dif_fiducia from convenios where id_convenio = idconvenio));
		IF ( substring(FacturaFromJava,1,2) = 'ND' OR substring(FacturaFromJava,1,2) = 'CI' OR substring(FacturaFromJava,1,2) = 'FI' ) THEN

			SELECT INTO _NumRemesa numero_remesa FROM con.factura_detalle WHERE documento = facturafromjava limit 1;
			SELECT INTO _DocumenType document_type FROM series WHERE prefix = (select substring(_NumRemesa,1,2)) AND agency_id = 'BQ';
			if (substring(FacturaFromJava,1,2) = 'ND') then
				SeDevoluciona = 'AC';
			else
				SeDevoluciona = 'AP';
			end if;


		ELSE
			SELECT INTO _DocumenType document_type FROM series WHERE prefix = (select substring(facturafromjava,1,2)) AND agency_id = 'BQ';
			SeDevoluciona = 'AP';
		END IF;

		SELECT INTO _ConveniosFacFiducia *, (select prefix from series where document_type = convenios_cxc_fiducias.prefijo_factura_endoso) as mprefijo from convenios_cxc_fiducias WHERE id_convenio = idConvenio and titulo_valor = _hc_factura.tneg and prefijo_cxc_fiducia = _DocumenType;

		IF FOUND THEN

			CuentaCabecera = _ConveniosFacFiducia.hc_cxc_endoso;
			CuentaDetalle = _ConveniosFacFiducia.cuenta_cxc_endoso;
			FacEndoso := _ConveniosFacFiducia.mprefijo||substring(FacturaFromJava,3);

		ELSE

			SELECT INTO _ConveniosFacFiducia *
			,SeDevoluciona as mprefijo
			FROM convenios_cxc
			WHERE id_convenio = idConvenio
			AND titulo_valor = _hc_factura.tneg
			AND prefijo_factura = _DocumenType;

			if found then
				CuentaCabecera = _ConveniosFacFiducia.hc_cxc;
				CuentaDetalle = _ConveniosFacFiducia.cuenta_cxc;
			end if;

			CuentaCabecera = 'FF';
			CuentaDetalle = '91350101';
			FacEndoso := _ConveniosFacFiducia.mprefijo||substring(FacturaFromJava,3);


		END IF;

		IF ( substring(FacturaFromJava,1,2) = 'FI' OR substring(FacturaFromJava,1,2) = 'CI' OR substring(FacturaFromJava,1,2) = 'MI' ) THEN

			SELECT INTO _FacPadre numero_remesa FROM con.factura_detalle WHERE documento = facturafromjava limit 1;

			FacPadre = _ConveniosFacFiducia.mprefijo||substring(_FacPadre.numero_remesa,3);
			--mcad := facturafromjava || ' -- ' || FacPadre;

			--SELECT INTO _AcumFacDetalle sum(valor_unitario) as sum_detalle, count(0) as NoDetalles FROM con.factura_detalle WHERE documento = FacturaFromJava;
			_FacDetalle = ValorSaldo; --ValorFactura;

			SELECT INTO FacPadreEndosada documento::varchar from con.factura where documento = FacPadre;

			IF FOUND THEN

				insert into con.factura_detalle select
				reg_status,
				dstrct,
				tipo_documento,
				FacPadre,
				(select count(0)+1 from con.factura_detalle where documento = FacPadre),
				nit,
				concepto,
				FacturaFromJava,
				descripcion,
				CuentaDetalle, --_ConveniosFacFiducia.cuenta_cxc_endoso,
				cantidad,
				_FacDetalle, --valor_unitario,
				_FacDetalle, --valor_unitariome,
				_FacDetalle, --valor_item,
				_FacDetalle, --valor_itemme,
				valor_tasa,
				moneda,
				last_update,
				user_update,
				now(),
				'HCUELLO',
				base,
				'RD-'||nit,
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
				from con.factura_detalle where documento = FacturaFromJava;

				--update con.factura set valor_factura = (valor_factura + _FacDetalle.sum_detalle), valor_facturame = (valor_factura + _FacDetalle.sum_detalle), valor_saldo = (valor_factura + _FacDetalle.sum_detalle) - valor_abono, valor_saldome = (valor_factura + _FacDetalle.sum_detalle) - valor_abono where documento = FacPadre;
				update con.factura set valor_factura = (valor_factura + _FacDetalle), valor_facturame = (valor_factura + _FacDetalle), valor_saldo = (valor_factura + _FacDetalle), valor_saldome = (valor_factura + _FacDetalle) where documento = FacPadre;

			ELSE

				INSERT INTO con.factura SELECT
				'', --reg_status,
				dstrct,
				tipo_documento,
				FacEndoso,--??
				nit,
				codcli,
				concepto,
				now()::date,
				fecha_vencimiento,
				'0099-01-01',
				fecha_impresion,
				descripcion,
				observacion,
				ValorFactura, --valor_factura,
				ValorAbono, --DiferenciaSaldoAbono,
				ValorSaldo, --_hc_factura.valor_saldo_cp,
				ValorFactura, --valor_facturame,
				ValorAbono, --DiferenciaSaldoAbono,
				ValorSaldo,  --_hc_factura.valor_saldo_cp,
				valor_tasa,
				moneda,
				cantidad_items,
				forma_pago,
				agencia_facturacion,
				agencia_cobro,
				zona,
				clasificacion1,
				clasificacion2,
				clasificacion3,
				'0',
				'0',
				'0099-01-01 00:00:00',
				fecha_anulacion,
				fecha_contabilizacion_anulacion,
				base,
				last_update,
				user_update,
				now(),
				'HCUELLO',
				fecha_probable_pago,
				flujo,
				rif,
				CuentaCabecera, --_ConveniosFacFiducia.hc_cxc_endoso, --??
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
				FROM con.factura WHERE documento = FacturaFromJava;

				--INSERTA FACTURA_DETALLE
				BolsaSaldo = ValorSaldo;
				for _InsertFacturaDetalle IN select * from con.factura_detalle where documento = FacturaFromJava loop

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
						FacEndoso,
						item,
						nit,
						concepto,
						FacturaFromJava,
						descripcion,
						CuentaDetalle, --_ConveniosFacFiducia.cuenta_cxc_endoso,
						cantidad,
						VlDetFactura, --valor_unitario,
						VlDetFactura, --valor_unitariome,
						VlDetFactura, --valor_item,
						VlDetFactura, --valor_itemme,
						valor_tasa,
						moneda,
						last_update,
						user_update,
						now(),
						'HCUELLO',
						base,
						'RD-'||nit,
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
						from con.factura_detalle where documento = FacturaFromJava and item = _InsertFacturaDetalle.item;

					end if;
				end loop;

			END IF;

		ELSE

			INSERT INTO con.factura SELECT
			'', --reg_status,
			dstrct,
			tipo_documento,
			FacEndoso,--??
			nit,
			codcli,
			concepto,
			now()::date,
			fecha_vencimiento,
			'0099-01-01',
			fecha_impresion,
			descripcion,
			observacion,
			ValorFactura, --valor_factura, --
			ValorAbono,  --DiferenciaSaldoAbono,
			ValorSaldo, --_hc_factura.valor_saldo_cp,
			ValorFactura, --valor_facturame, --
			ValorAbono,
			ValorSaldo, --_hc_factura.valor_saldo_cp,
			valor_tasa,
			moneda,
			cantidad_items,
			forma_pago,
			agencia_facturacion,
			agencia_cobro,
			zona,
			clasificacion1,
			clasificacion2,
			clasificacion3,
			'0',
			'0',
			'0099-01-01 00:00:00',
			fecha_anulacion,
			fecha_contabilizacion_anulacion,
			base,
			last_update,
			user_update,
			now(),
			'HCUELLO',
			fecha_probable_pago,
			flujo,
			rif,
			CuentaCabecera, --_ConveniosFacFiducia.hc_cxc_endoso, --??
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
			FROM con.factura WHERE documento = FacturaFromJava;


			--INSERTA FACTURA_DETALLE
			BolsaSaldo = ValorSaldo; --ValorFactura;
			for _InsertFacturaDetalle IN select * from con.factura_detalle where documento = FacturaFromJava loop

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
					FacEndoso,
					item,
					nit,
					concepto,
					FacturaFromJava,
					descripcion,
					CuentaDetalle, --_ConveniosFacFiducia.cuenta_cxc_endoso,
					cantidad,
					VlDetFactura, --valor_unitario,
					VlDetFactura, --valor_unitariome,
					VlDetFactura, --valor_item,
					VlDetFactura, --valor_itemme,
					valor_tasa,
					moneda,
					last_update,
					user_update,
					now(),
					'HCUELLO',
					base,
					'RD-'||nit,
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
					from con.factura_detalle where documento = FacturaFromJava and item = _InsertFacturaDetalle.item;

				end if;
			end loop;

		END IF;

		--mcad := FACEndoso;

		IF ( FACEndoso != '' ) THEN

			--Se marca la factura que se indemniza.
			UPDATE con.factura SET endoso_fenalco = 'S' WHERE documento = FacturaFromJava;

			SELECT INTO VeryfyFacturaOnFoto * FROM con.foto_cartera WHERE periodo_lote = periodo_corriente and documento = FacturaFromJava;

			if found then

				--Se deja el saldo en cero la factura a indemnizar.
				UPDATE con.foto_cartera SET valor_abono = valor_factura, valor_saldo = 0 WHERE periodo_lote = periodo_corriente and documento = FacturaFromJava;

				--Insertar Nueva Factura con Saldo.
				insert into con.foto_cartera (periodo_lote,id_convenio,reg_status, dstrct,
				tipo_documento, documento, nit, codcli, concepto, fecha_negocio,fecha_factura, fecha_vencimiento, fecha_ultimo_pago, descripcion,
				valor_factura, valor_abono, valor_saldo, valor_facturame, valor_abonome, valor_saldome, forma_pago, transaccion,
				fecha_contabilizacion, creation_date_cxc, creation_user, cmc, periodo, negasoc, num_doc_fen, agencia_cobro
				)
				select
				replace(substring(now()::date,1,7),'-',''),(select id_convenio from negocios where cod_neg = con.factura.negasoc and dist = 'FINV'),
				reg_status, dstrct,
				tipo_documento, documento, nit, codcli, concepto,
				(select fecha_negocio from negocios where cod_neg = con.factura.negasoc and dist = 'FINV'),
				fecha_factura, fecha_vencimiento, fecha_ultimo_pago,
				descripcion,
				valor_factura, valor_abono, valor_saldo, valor_facturame, valor_abonome, valor_saldome, forma_pago, transaccion,
				fecha_contabilizacion, now(), creation_user, cmc, periodo, negasoc, num_doc_fen, agencia_cobro
				from con.factura
				where reg_status != 'A'
				and dstrct = 'FINV'
				and tipo_documento in ('FAC','NDC')
				and substring(documento,1,2) not in ('NM','PM','RM','IPM','INM','IRM','R0','RE','PP','EF')
				and documento = FacEndoso;

			end if;

			mcad := 'Genero Factura de Orden No: '||FacEndoso;


		ELSE
			mcad := 'ERROR para la Factura: '||FacturaFromJava;
		END IF;

	--mcad := 'Provisional para: '||FacturaFromJava;
	ELSE
		mcad := 'ERROR: No se genero el documento INGRESO para la Factura: '||FacturaFromJava;
	END IF;

	RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_endosotercero(character varying, character varying)
  OWNER TO postgres;
