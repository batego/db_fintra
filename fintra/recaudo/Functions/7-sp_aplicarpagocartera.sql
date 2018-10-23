-- Function: recaudo.sp_aplicarpagocartera(integer, date, integer, integer, integer, boolean, character varying, character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION recaudo.sp_aplicarpagocartera(integer, date, integer, integer, integer, boolean, character varying, character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION recaudo.sp_aplicarpagocartera(_entidadrecaudadora integer, _fecharecaudo date, _loterecaudo integer, _idetalle_recaudo integer, codrop integer, generarixmgac boolean, tipoingreso character varying, formadeingreso character varying, cuentatwochar character varying, unidadnegocio integer, usersesion character varying, cmcdoc character varying, cuentacabingreso character varying, cuentadetingreso character varying, cuentacarterafrom character varying, cuentaixm character varying, cuentagac character varying)
  RETURNS text AS
$BODY$

DECLARE

	RoP record;
	RsNOcartera record;
	RsCartera record;
	RsFactsByNegocio record;
	RsIngresosPlenos record;

	BolsaPorNegocio numeric := 0;
	--BolsaRop numeric := 0;
	BolsaValorAbono numeric;
	_PeriodoCte numeric;
	ItemDetalleIngreso numeric := 0;
	SaldoFactura numeric := 0;
	AplicarPorValorDe numeric := 0;
	DeterminarCuanto numeric := 0;
	ExisteLoteIngreso numeric := 0;
	CantidadExiste numeric := 0;

	NumeroIngreso varchar := '';
	CuentaDetalle varchar := '';
	CtaCmcDoc varchar := '';
	Dscpt varchar := '';
	Procesado varchar := 'N';
	_TipoIngreso varchar := '';
	_BranchCode varchar := 'SUPEREFECTIVO';
	_BankAccountNo varchar := 'SUPEREFECTIVO';

	fecha_hoy date;
	fechaAnterior date;
	miHoy date;

	mcad TEXT;

BEGIN

	miHoy = now()::date;
	_PeriodoCte = replace(substring(miHoy,1,7),'-','')::numeric;

	if ( TipoIngreso = 'INGC' ) then
		_TipoIngreso = 'ING';
	else
		_TipoIngreso = 'ICA';
	end if;

	/*OBTENEMOS LA INFORMACION DEL RECIBO OFICIAL DE PAGO - EXTRACTO*/
	SELECT INTO RoP *,(SELECT codcli FROM cliente where nit = rp.cedula) as cod_cli FROM recibo_oficial_pago rp WHERE id = CodRop;

	SELECT INTO NumeroIngreso get_lcod(TipoIngreso);
	--raise notice 'NUMERO IA: %',NumeroIngreso;

	/*CABECERA DEL INGRESO*/
	INSERT INTO con.ingreso(dstrct,tipo_documento,num_ingreso,codcli,nitcli,
		     concepto,tipo_ingreso,fecha_consignacion,fecha_ingreso,branch_code,
		     bank_account_no,codmoneda,agencia_ingreso,descripcion_ingreso,vlr_ingreso,
		     vlr_ingreso_me,vlr_tasa,fecha_tasa,cant_item,creation_user,
		     creation_date,base,cuenta)
	VALUES('FINV',_TipoIngreso,NumeroIngreso,RoP.cod_cli,RoP.cedula,
	       'FE','C',_FechaRecaudo,now(),_BranchCode,
		_BankAccountNo,'PES','OP','INGRESO AUTOMATICO - EXTRACTO No: '||CodRop,1,
	       1,'1.000000',substring(now(),1,10)::date,1,UserSesion,
	       now(),'COL',CuentaCabIngreso);

	/*
	SELECT INTO ExisteLoteIngreso count(0) as LoteIngresado FROM recaudo.rel_ingreso_rop WHERE id_recaudo = _LoteRecaudo;

	if ( ExisteLoteIngreso = 0 ) then

		--OBTENER NUMERO DE INGRESO
		SELECT INTO NumeroIngreso get_lcod(TipoIngreso);
		--raise notice 'NUMERO IA: %',NumeroIngreso;

		/*CABECERA DEL INGRESO
		INSERT INTO con.ingreso(dstrct,tipo_documento,num_ingreso,codcli,nitcli,
			     concepto,tipo_ingreso,fecha_consignacion,fecha_ingreso,branch_code,
			     bank_account_no,codmoneda,agencia_ingreso,descripcion_ingreso,vlr_ingreso,
			     vlr_ingreso_me,vlr_tasa,fecha_tasa,cant_item,creation_user,
			     creation_date,base,cuenta)
		VALUES('FINV','ICA',NumeroIngreso,RoP.cod_cli,RoP.cedula,
		       'FE','C',_FechaRecaudo,now(),'',
			'','PES','OP','INGRESO AUTOMATICO - EXTRACTO No: '||CodRop,1,
		       1,'1.000000',substring(now(),1,10)::date,1,UserSesion,
		       now(),'COL',CuentaCabIngreso);

		ItemDetalleIngreso:=ItemDetalleIngreso+1;

	else
		select into NumeroIngreso num_ingreso from recaudo.rel_ingreso_rop where id_recaudo = _LoteRecaudo limit 1;
		SELECT INTO CantidadExiste count(0) FROM con.ingreso_detalle WHERE num_ingreso = NumeroIngreso;
		ItemDetalleIngreso:=CantidadExiste+1;
	end if;
	*/

	raise notice 'ItemDetalleIngreso: %', ItemDetalleIngreso;

	--RELACIONAMOS LOS INGRESOS REALIZADOS POR EXTRACTO
	INSERT INTO recaudo.rel_ingreso_rop (id_recaudo, reg_status, dstrct, id_rop, id_unidad_negocio, cartera_en, detalle_recaudo, num_ingreso, usuario_aplica)
	VALUES (_LoteRecaudo, '', 'FINV', CodRop, UnidadNegocio, CuentaTwoChar, _idetalle_recaudo, NumeroIngreso, UserSesion);

	/*INGRESO DE LOS INTERESES DE MORA Y GASTO DE COBRANZA**/
	IF ( GenerarIxMGaC ) THEN

		FOR RsNOcartera IN

			select *
			from detalle_rop dr
			where dr.id_rop = CodRop
			and dr.descripcion in ('INTERES MORA','GASTOS DE COBRANZA')
			and dr.valor_concepto > 0

		LOOP
			IF FOUND THEN

				IF ( RsNoCartera.descripcion = 'INTERES MORA' ) THEN

					Dscpt = 'INTERES MORA - EXTRACTO No: '||CodRop;
					CuentaDetalle = CuentaIxM;

				ELSIF ( RsNoCartera.descripcion = 'GASTOS DE COBRANZA' ) THEN

					Dscpt = 'GASTOS DE COBRANZA - EXTRACTO No: '||CodRop;
					CuentaDetalle = CuentaGaC;

				END IF;

				ItemDetalleIngreso:=ItemDetalleIngreso+1;

				INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
								valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
								documento,creation_user,creation_date,base,cuenta,descripcion,
								valor_tasa,saldo_factura)
				VALUES('FINV',_TipoIngreso,NumeroIngreso,ItemDetalleIngreso,RoP.cedula,
					RsNoCartera.valor_concepto,RsNoCartera.valor_concepto,'',now()::date,'',
					'',UserSesion,now(),'COL',CuentaDetalle,
					Dscpt,'1.0000000000',RsNoCartera.valor_concepto);

				Procesado = 'S';

			END IF;

		END LOOP;

	END IF;
	--

	--RECAUDO PLENO -> AFECTA LAS CUENTAS TEMPORALES.
	IF ( FormaDeIngreso = 'Pleno' ) THEN

		select into RsIngresosPlenos id_rop, sum(saldo_rop) as saldo_rop
		from (
			select dr.id_rop, dr.negocio, f.negasoc, f.num_doc_fen, f.saldo_cartera, sum(dr.valor_concepto) as saldo_rop
			from detalle_rop dr
				INNER JOIN (
					select negasoc, num_doc_fen, sum(valor_saldo) as saldo_cartera
					from con.factura f
					where f.dstrct = 'FINV'
					and f.reg_status = ''
					and f.tipo_documento in ('FAC','NDC')
					and substring(f.documento,1,2) not in ('CP','FF','DF')
					and f.valor_saldo > 0
					and replace(substring(f.fecha_vencimiento,1,7),'-','') <= RoP.periodo_rop --replace(substring(RoP.vencimiento_rop::date,1,7),'-','')
					and cmc = CmcDoc
					group by negasoc, num_doc_fen
				) f ON (f.negasoc = dr.negocio and f.num_doc_fen = dr.cuota)
			where dr.id_rop = CodRop
			and dr.descripcion not in ('INTERES MORA','GASTOS DE COBRANZA')
			group by dr.id_rop, dr.negocio, f.negasoc, f.num_doc_fen, f.saldo_cartera
			order by f.negasoc
		) c
		group by id_rop;

		ItemDetalleIngreso:=ItemDetalleIngreso+1;

		CtaCmcDoc = CuentaDetIngreso;

		Dscpt = 'RECAUDO DE APLICACION PLENA';
		SaldoFactura = RsIngresosPlenos.saldo_rop;

		INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
						valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
						documento,creation_user,creation_date,base,cuenta,descripcion,
						valor_tasa,saldo_factura,tipo_referencia_1,referencia_1)
		VALUES('FINV',_TipoIngreso,NumeroIngreso,ItemDetalleIngreso,RoP.cedula,
			RsIngresosPlenos.saldo_rop,RsIngresosPlenos.saldo_rop,'',now()::date,'FAC',
			'',UserSesion,now(),'COL',CtaCmcDoc,
			Dscpt,'1.0000000000',SaldoFactura,'NEG',RoP.negocio
		);

		IF ( NumeroIngreso != '' ) THEN

			UPDATE
				con.ingreso
			SET
				vlr_ingreso =(SELECT coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso = con.ingreso.num_ingreso),
				vlr_ingreso_me = (SELECT coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso = con.ingreso.num_ingreso),
				cant_item= ItemDetalleIngreso
			WHERE num_ingreso = NumeroIngreso;

		END IF;

		if ( Procesado = 'N' ) then Procesado = 'S'; end if;

	--RECAUDO DETALLADO.
	ELSIF ( FormaDeIngreso = 'Distribuido' ) THEN

		/*INGRESO DEL DETALLE DE LA CARTERA**/
		FOR RsCartera IN

			select id_rop, negocio, negasoc, sum(saldo_cartera) as saldo_cartera, sum(saldo_rop) as saldo_rop
			from (
				select dr.id_rop, dr.negocio, f.negasoc, f.num_doc_fen, f.saldo_cartera, sum(dr.valor_concepto) as saldo_rop
				from detalle_rop dr
					INNER JOIN (
						select negasoc, num_doc_fen, sum(valor_saldo) as saldo_cartera
						from con.factura f
						where f.dstrct = 'FINV'
						and f.reg_status = ''
						and f.tipo_documento in ('FAC','NDC')
						and substring(f.documento,1,2) not in ('CP','FF','DF')
						and f.valor_saldo > 0
						and replace(substring(f.fecha_vencimiento,1,7),'-','') <= RoP.periodo_rop --replace(substring(RoP.vencimiento_rop::date,1,7),'-','')
						and cmc = CmcDoc
						group by negasoc, num_doc_fen
					) f ON (f.negasoc = dr.negocio and f.num_doc_fen = dr.cuota)
				where dr.id_rop = CodRop
				and dr.descripcion not in ('INTERES MORA','GASTOS DE COBRANZA')
				group by dr.id_rop, dr.negocio, f.negasoc, f.num_doc_fen, f.saldo_cartera
				order by f.negasoc
			) c
			group by id_rop, negocio, negasoc
			order by negasoc

		LOOP

			--GUARDAMOS UNA COPIA DE LAS FACTURAS ANTES DE APLICAR EL PAGO
			INSERT INTO recaudo.auditoria_ingresos_automaticos (id_recaudo, extracto, reg_status, dstrct, negasoc, periodo, transaccion, nit, codcli, tipo_documento, documento, num_doc_fen, cmc, fecha_vencimiento, valor_factura, valor_abono, valor_saldo, creation_date, creation_user)
			SELECT _LoteRecaudo, CodRop, reg_status, dstrct, negasoc, periodo, transaccion, nit, codcli, tipo_documento, documento, num_doc_fen, cmc, fecha_vencimiento, valor_factura, valor_abono, valor_saldo, now(), 'HCUELLO'
			from con.factura
			where negasoc = RsCartera.negasoc
			--and valor_saldo > 0
			and substring(documento,1,2) not in ('CP','FF','DF')
			order by negasoc, num_doc_fen;

			--GUARDAMOS EL VALOR DEL EXTRACTO PARA EL NEGOCIO(s) ESPECIFICO.
			BolsaPorNegocio = RsCartera.saldo_rop;

			FOR RsFactsByNegocio IN

				select dr.id_rop, f.negasoc, f.documento, f.fecha_vencimiento, (select cuenta from con.cmc_doc where cmc = f.cmc and tipodoc = 'FAC') as cuenta_cmc, f.valor_saldo
				from detalle_rop dr, con.factura f
				where f.negasoc = dr.negocio
					and f.num_doc_fen = dr.cuota --cambio Edgar Gonzalez
					and dr.id_rop = CodRop
					and f.dstrct = 'FINV'
					and f.reg_status = ''
					and f.tipo_documento in ('FAC','NDC')
					and substring(f.documento,1,2) not in ('CP','FF','DF')
					and replace(substring(f.fecha_vencimiento,1,7),'-','') <= RoP.periodo_rop --replace(substring(RoP.vencimiento_rop::date,1,7),'-','')
					and f.valor_saldo > 0
					and negasoc = RsCartera.negasoc
					and (select cuenta from con.cmc_doc where cmc = f.cmc and tipodoc = 'FAC') = CuentaCarteraFrom
				group by dr.id_rop, f.negasoc, f.documento, f.fecha_vencimiento, cuenta_cmc, f.valor_saldo
				order by f.fecha_vencimiento asc
			LOOP

				IF ( BolsaPorNegocio >= 0 )THEN

					ItemDetalleIngreso := ItemDetalleIngreso + 1;

					if ( CuentaDetIngreso = 'cmc_factura' ) then
						CtaCmcDoc = RsFactsByNegocio.cuenta_cmc;
					else
						CtaCmcDoc = CuentaDetIngreso;
					end if;

					Dscpt = 'INGRESO AFECTA FACTURA No: '||RsFactsByNegocio.documento;
					--SaldoFactura = RsFactsByNegocio.valor_saldo;

					DeterminarCuanto = BolsaPorNegocio - RsFactsByNegocio.valor_saldo;

					if ( DeterminarCuanto >= 0 ) then

						AplicarPorValorDe = RsFactsByNegocio.valor_saldo;
					else
						AplicarPorValorDe = BolsaPorNegocio;
					end if;

					SaldoFactura = RsFactsByNegocio.valor_saldo - AplicarPorValorDe;

					INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
									valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
									documento,creation_user,creation_date,base,cuenta,descripcion,
									valor_tasa,saldo_factura,tipo_referencia_1,referencia_1)
					VALUES('FINV',_TipoIngreso,NumeroIngreso,ItemDetalleIngreso,RoP.cedula,
						AplicarPorValorDe,AplicarPorValorDe,RsFactsByNegocio.documento,now()::date,'FAC',
						RsFactsByNegocio.documento,UserSesion,now(),'COL',CtaCmcDoc,
						Dscpt,'1.0000000000',SaldoFactura,'NEG',RsFactsByNegocio.negasoc
					);

					BolsaPorNegocio = BolsaPorNegocio - AplicarPorValorDe;

					--ACTUALIZAR SALDOS DE C/U DE LAS FACTURAS.
					UPDATE con.factura SET
						valor_abono = valor_abono + RsFactsByNegocio.valor_saldo,
						valor_saldo = valor_saldo - RsFactsByNegocio.valor_saldo ,
						valor_abonome = valor_abonome + RsFactsByNegocio.valor_saldo,
						valor_saldome =valor_saldome - RsFactsByNegocio.valor_saldo,
						user_update=UserSesion,
						last_update=now(), fecha_ultimo_pago = now()
					WHERE documento = RsFactsByNegocio.documento;

				END IF;

			END LOOP;

			IF ( BolsaPorNegocio > 0 ) THEN

				--Tomamos las facturas por vencer sin incluir la del periodo actual.
				--Ojo con los ingresos diferidos para el caso de Fenalco
				--Ojo con los MI y CAT (Diferidos) que no han sido generados para el caso de Microcredito.

				FOR RsFactsByNegocio IN

					select dr.id_rop, f.negasoc, f.documento, f.fecha_vencimiento, (select cuenta from con.cmc_doc where cmc = f.cmc and tipodoc = 'FAC') as cuenta_cmc, f.valor_saldo
					from detalle_rop dr, con.factura f
					where f.negasoc = dr.negocio
						--and f.num_doc_fen = dr.cuota --cambio Edgar Gonzalez
						and dr.id_rop = CodRop
						and f.dstrct = 'FINV'
						and f.reg_status = ''
						and f.tipo_documento in ('FAC','NDC')
						and substring(f.documento,1,2) not in ('CP','FF','DF')
						and replace(substring(f.fecha_vencimiento,1,7),'-','') > RoP.periodo_rop --replace(substring(RoP.vencimiento_rop::date,1,7),'-','')
						and f.valor_saldo > 0
						and negasoc = RsCartera.negasoc
						and (select cuenta from con.cmc_doc where cmc = f.cmc and tipodoc = 'FAC') = CuentaCarteraFrom
					group by dr.id_rop, f.negasoc, f.documento, f.fecha_vencimiento, cuenta_cmc, f.valor_saldo
					order by f.fecha_vencimiento asc
				LOOP

					IF ( BolsaPorNegocio >= 0 )THEN

						ItemDetalleIngreso := ItemDetalleIngreso + 1;

						if ( CuentaDetIngreso = 'cmc_factura' ) then
							CtaCmcDoc = RsFactsByNegocio.cuenta_cmc;
						else
							CtaCmcDoc = CuentaDetIngreso;
						end if;

						Dscpt = 'INGRESO AFECTA FACTURA No: '||RsFactsByNegocio.documento;
						--SaldoFactura = 0; --OJO QUE CUANDO HABILITES ESTE: NO PUEDE SER CERO

						DeterminarCuanto = BolsaPorNegocio - RsFactsByNegocio.valor_saldo;

						if ( DeterminarCuanto >= 0 ) then

							AplicarPorValorDe = RsFactsByNegocio.valor_saldo;
						else
							AplicarPorValorDe = BolsaPorNegocio;
						end if;

						SaldoFactura = RsFactsByNegocio.valor_saldo - AplicarPorValorDe;

						INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
										valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
										documento,creation_user,creation_date,base,cuenta,descripcion,
										valor_tasa,saldo_factura,tipo_referencia_1,referencia_1)
						VALUES('FINV',_TipoIngreso,NumeroIngreso,ItemDetalleIngreso,RoP.cedula,
							AplicarPorValorDe,AplicarPorValorDe,RsFactsByNegocio.documento,now()::date,'FAC',
							RsFactsByNegocio.documento,UserSesion,now(),'COL',CtaCmcDoc,
							Dscpt,'1.0000000000',SaldoFactura,'NEG',RsFactsByNegocio.negasoc
						);

						BolsaPorNegocio = BolsaPorNegocio - AplicarPorValorDe;

						--ACTUALIZAR SALDOS DE C/U DE LAS FACTURAS.
						UPDATE con.factura SET
							valor_abono = valor_abono + RsFactsByNegocio.valor_saldo,
							valor_saldo = valor_saldo - RsFactsByNegocio.valor_saldo ,
							valor_abonome = valor_abonome + RsFactsByNegocio.valor_saldo,
							valor_saldome =valor_saldome - RsFactsByNegocio.valor_saldo,
							user_update=UserSesion,
							last_update=now(), fecha_ultimo_pago = now()
						WHERE documento = RsFactsByNegocio.documento;

					END IF;

				END LOOP;

			END IF;

		END LOOP;
		--*Fin*

		IF ( NumeroIngreso != '' ) THEN

			UPDATE
				con.ingreso
			SET
				vlr_ingreso =(SELECT coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso = con.ingreso.num_ingreso),
				vlr_ingreso_me = (SELECT coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso = con.ingreso.num_ingreso),
				cant_item= ItemDetalleIngreso
			WHERE num_ingreso = NumeroIngreso;

		END IF;

		if ( Procesado = 'N' ) then Procesado = 'S'; end if;

	END IF;
	--

	--CONDICIONES QUE DEBEN DARSE SI SE GENERAN LOS INGRESOS ADECUADAMENTE.
	IF ( Procesado = 'S' ) THEN

		--MARCAMOS EL EXTRACTO PARA QUE INDIQUE QUE FUE APLICADO EL PAGO
		UPDATE recibo_oficial_pago SET recibo_aplicado = 'S' WHERE id = CodRop;

		--INDICAMOS EN LA RELACION EXTRACTO-INGRESO QUE EL INGRESO TENIA CARTERA PARA APLICAR
		UPDATE recaudo.rel_ingreso_rop SET w_detalle = 'S' WHERE num_ingreso = NumeroIngreso;

		--INDICAMOS QUE LA REFERENCIA DEL LOTE FUE PROCESADO.
		UPDATE recaudo.recaudo_detalles SET procesado_cartera = true, negocio = RoP.negocio WHERE id_rec = _LoteRecaudo AND referencia_factura = CodRop;

	ELSIF ( Procesado = 'N' ) THEN

		----CAUSAL DE NO PROCESADO. C04->SE CREA LA CABECERA PERO NO HAY DETALLE.
		UPDATE recaudo.recaudo_detalles SET causal_dev_procesamiento = 'C04' WHERE id_rec = LoteRecaudo AND referencia_factura = CodRop;
	END IF;

	mcad = NumeroIngreso;

	RETURN mcad;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION recaudo.sp_aplicarpagocartera(integer, date, integer, integer, integer, boolean, character varying, character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
