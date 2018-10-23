-- Function: etes.sp_contabilizaretesgasolina(integer, character varying, integer)

-- DROP FUNCTION etes.sp_contabilizaretesgasolina(integer, character varying, integer);

CREATE OR REPLACE FUNCTION etes.sp_contabilizaretesgasolina(_idmanifiesto integer, usuario character varying, _idestacion integer)
  RETURNS text AS
$BODY$

DECLARE


	InfoManfts record;
	RsCliente record;
	RsEstacion record;
	ESinfo record;

	_grupo_transaccion numeric;
	_transaccion numeric;

	VlrComisionAnt numeric := 0;
	VlrResto numeric := 0;
	secuencia integer :=1;

	ReturnAplicarPagoCartera varchar;
	_PeriodoCte varchar := '';
	CXCPropietario varchar := '';
	EGRPropietario varchar := '';
	UserAprobador varchar := '';

	miHoy date;

	ValidarIxMGaC boolean := true;

	mcad TEXT := 'BAD';

BEGIN

	miHoy = now()::date;
	_PeriodoCte = replace(substring(miHoy,1,7),'-','')::varchar;

	/**
	CONTABILIZACION DEL PROCESO ANTICIPOS PARA LAS ESTACIONES DE SERVICIO
	**/

	--..::DEBO RECORRER TANTO EL ANTICIPO COMO LOS REANTICIPOS ASOCIADOS A ESTE ANTICIPO PADRE::..
	FOR InfoManfts IN

		SELECT
			mc.id,
			mc.id as id_manifiesto_carga,
			mc.planilla,
			mc.valor_neto_anticipo,
			mc.valor_descuentos_fintra,
			mc.valor_desembolsar,
			mc.fecha_corrida,
			'N'::varchar as reanticipo,
			ag.cod_agencia, ag.nombre_agencia, ag.id_transportadora,
			prop.cod_proveedor, prop.nombre,
			transp.cod_transportadora, transp.identificacion, transp.razon_social, transp.direccion
		FROM etes.manifiesto_carga mc
			INNER JOIN etes.agencias as ag on (mc.id_agencia = ag.id)
			INNER JOIN etes.vehiculo as vh on (mc.id_vehiculo = vh.id)
			INNER JOIN etes.propietario as prop on (vh.id_propietario = prop.id and prop.reg_status = '')
			INNER JOIN etes.transportadoras as transp on (ag.id_transportadora = transp.id)
		WHERE mc.id = _idmanifiesto and
			--mc.fecha_corrida::date = '2015-08-17' and
			--mc.cxc_corrida = '' and
			mc.periodo_contabilizacion = '' and
			mc.transaccion = 0 and
			mc.reg_status = ''

		UNION ALL

		SELECT
			mr.id,
			mr.id_manifiesto_carga,
			mr.planilla,
			mr.valor_reanticipo as valor_neto_anticipo,
			mr.valor_descuentos_fintra,
			mr.valor_desembolsar,
			mr.fecha_corrida,
			'S'::varchar as reanticipo,
			ag.cod_agencia, ag.nombre_agencia, ag.id_transportadora,
			prop.cod_proveedor, prop.nombre,
			transp.cod_transportadora, transp.identificacion, transp.razon_social, transp.direccion
		FROM etes.manifiesto_reanticipos mr
			INNER JOIN etes.manifiesto_carga as ant on (mr.id_manifiesto_carga = ant.id)
			INNER JOIN etes.agencias as ag on (ant.id_agencia = ag.id)
			INNER JOIN etes.vehiculo as vh on (ant.id_vehiculo = vh.id)
			INNER JOIN etes.propietario as prop on (vh.id_propietario = prop.id and prop.reg_status = '')
			INNER JOIN etes.transportadoras as transp on (ag.id_transportadora = transp.id)
		WHERE mr.id_manifiesto_carga = _idmanifiesto and
			--mr.cxc_corrida = '' and
			mr.periodo_contabilizacion = '' and
			mr.transaccion = 0 and
			mr.reg_status = ''

	LOOP

		--A) CONTABILIZO EL ANTICIPO

			--1) Crea Comprobante

			_grupo_transaccion = 0;
			SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

			--(Cabecera)
			INSERT INTO con.comprobante(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
				    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
				    total_items, moneda, fecha_aplicacion, aprobador, last_update,
				    user_update, creation_date, creation_user, base, usuario_aplicacion,
				    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
			    VALUES ('', 'FINV', 'AGA', InfoManfts.planilla, _grupo_transaccion, 'OP',
				    _PeriodoCte, now()::date, 'Contabiliza AGA'||InfoManfts.planilla, InfoManfts.cod_proveedor, InfoManfts.valor_neto_anticipo, InfoManfts.valor_neto_anticipo,
				    3, 'PES', '0099-01-01 00:00:00', Usuario, now(),
				    Usuario, now(), Usuario, 'COL', Usuario,
				    '', '', 0.00, 'AGA', InfoManfts.cod_proveedor);

			--(Detalle)
			--1
			_transaccion = 0;
			SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

			INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV', 'AGA', InfoManfts.planilla, _grupo_transaccion, _transaccion,
				    _PeriodoCte, '13802801', InfoManfts.cod_proveedor, 'Contabiliza AGA DEBITO '||InfoManfts.planilla, InfoManfts.valor_neto_anticipo, 0.00,
				    InfoManfts.identificacion, 'AGA', now(), Usuario, now(),
				    Usuario, 'COL', 'AGA', InfoManfts.planilla, '', 0.00,
				    '', '', '', '',
				    '', '');

			--2
			_transaccion = 0;
			SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

			VlrComisionAnt = InfoManfts.valor_descuentos_fintra; --ROUND(InfoManfts.valor_neto_anticipo*(1.4/100));

			INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV', 'AGA', InfoManfts.planilla, _grupo_transaccion, _transaccion,
				    _PeriodoCte, 'I010290024154', InfoManfts.cod_proveedor, 'Contabiliza AGA CREDITO'||InfoManfts.planilla, 0.00, VlrComisionAnt,
				    InfoManfts.cod_proveedor, 'AGA', now(), Usuario, now(),
				    Usuario, 'COL', 'AGA', InfoManfts.planilla, '', 0.00,
				    '', '', '', '',
				    '', '');

			--3
			_transaccion = 0;
			SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

			VlrResto = InfoManfts.valor_neto_anticipo - VlrComisionAnt;

			INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV', 'AGA', InfoManfts.planilla, _grupo_transaccion, _transaccion,
				    _PeriodoCte, '23050311', InfoManfts.cod_proveedor, 'Contabiliza AGA CREDITO'||InfoManfts.planilla, 0.00, VlrResto,
				    InfoManfts.cod_proveedor, 'AGA', now(), Usuario, now(),
				    Usuario, 'COL', 'AGA', InfoManfts.planilla, '', 0.00,
				    '', '', '', '',
				    '', '');


			--2) Marco las planillas Procesadas.
			IF ( InfoManfts.reanticipo = 'N' ) THEN

				UPDATE etes.manifiesto_carga
				SET
				   fecha_contabilizacion = now(),
				   periodo_contabilizacion = _PeriodoCte,
				   transaccion = _grupo_transaccion
				WHERE id = InfoManfts.id;

			ELSIF ( InfoManfts.reanticipo = 'S' ) THEN

				UPDATE etes.manifiesto_reanticipos
				SET
				   fecha_contabilizacion = now(),
				   periodo_contabilizacion = _PeriodoCte,
				   transaccion = _grupo_transaccion
				WHERE id = InfoManfts.id;

			END IF;

		--B) GENERO LA CXP AL PROPIETARIO

			--HC: IL | 22050411
			--Detalle: 23050311
			--Debe guardarse en el Anticipo-Reanticipo

			--OPERATIVO
			select into UserAprobador table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO';

			INSERT INTO fin.cxp_doc(
				    reg_status, dstrct, proveedor, tipo_documento, documento, descripcion,
				    agencia, handle_code, id_mims, tipo_documento_rel, documento_relacionado,
				    fecha_aprobacion, aprobador, usuario_aprobacion, banco, sucursal,
				    moneda, vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me,
				    vlr_saldo_me, tasa, usuario_contabilizo, fecha_contabilizacion,
				    usuario_anulo, fecha_anulacion, fecha_contabilizacion_anulacion,
				    observacion, num_obs_autorizador, num_obs_pagador, num_obs_registra,
				    last_update, user_update, creation_date, creation_user, base,
				    corrida, cheque, periodo, fecha_procesado, fecha_contabilizacion_ajc,
				    fecha_contabilizacion_ajv, periodo_ajc, periodo_ajv, usuario_contabilizo_ajc,
				    usuario_contabilizo_ajv, transaccion_ajc, transaccion_ajv, clase_documento,
				    transaccion, moneda_banco, fecha_documento, fecha_vencimiento,
				    ultima_fecha_pago, flujo, transaccion_anulacion, ret_pago, clase_documento_rel,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3, indicador_traslado_fintra, factoring_formula_aplicada)
			    VALUES ('', 'FINV', InfoManfts.cod_proveedor,  'FAP', InfoManfts.planilla, 'TIPO OPERACION : AGA   PLANILLA: '||InfoManfts.planilla,
				    'OP', 'IL', '', '', '',
				    now(), UserAprobador, UserAprobador, 'ESTACION', 'GASOLINA',
				    'PES', InfoManfts.valor_desembolsar, 0,  InfoManfts.valor_desembolsar,  InfoManfts.valor_desembolsar, 0,
				     InfoManfts.valor_desembolsar,  1, '', '0099-01-01 00:00:00'::timestamp,
				    '',  '0099-01-01 00:00:00'::timestamp,  '0099-01-01 00:00:00'::timestamp,
				    '', 0, 0, 0,
				    '0099-01-01 00:00:00'::timestamp, '', NOW(), Usuario, 'COL',
				    '', '', '', '0099-01-01 00:00:00'::timestamp, '0099-01-01 00:00:00'::timestamp,
				    '0099-01-01 00:00:00'::timestamp, '', '', '',
				    '', 0, 0, '4',
				    0, 'PES', NOW()::date,(NOW() + '8 day')::date,
				     '0099-01-01 00:00:00'::timestamp, 'S', 0, 'N', '4',
				    'PLANI', InfoManfts.planilla,'','',
				    '','', 'N', 'N');

			INSERT INTO fin.cxp_items_doc(
			        reg_status, dstrct, proveedor, tipo_documento, documento, item,
				descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
				last_update, user_update, creation_date, creation_user, base,
				codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
				referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
				referencia_3)
			VALUES ('', 'FINV', InfoManfts.cod_proveedor, 'FAP', InfoManfts.planilla, '001',
			        'TIPO OPERACION : AGA   PLANILLA: '||InfoManfts.planilla,  InfoManfts.valor_desembolsar,  InfoManfts.valor_desembolsar, '23050311', '', InfoManfts.planilla,
			        '0099-01-01 00:00:00'::timestamp, '', NOW(), Usuario, 'COL',
			        '','','', '','',
			        '', '', '', '',
			        '');

		--C) GENERO EL EGRESO AL PROPIETARIO

		        --HC: 23050313
		        --Detalle: 22050411
		        --Debe guardarse en el Anticipo-Reanticipo

		        --..::OPERATIVO::..
		        SELECT INTO EGRPropietario etes.serie_egreso_propietario();

		        --(cabecera)
			INSERT INTO egreso(
				    reg_status, dstrct, branch_code, bank_account_no, document_no,
				    nit, payment_name, agency_id, pmt_date, printer_date, concept_code,
				    vlr, vlr_for, currency, last_update, user_update, creation_date,
				    creation_user, base, tipo_documento, tasa, fecha_cheque, usuario_impresion,
				    usuario_contabilizacion, fecha_contabilizacion,nit_beneficiario,
				    nit_proveedor, usuario_generacion, contabilizable)
			    VALUES ('','FINV','ESTACION', 'GASOLINA',EGRPropietario,
				    InfoManfts.cod_proveedor, get_nombp(InfoManfts.cod_proveedor), 'OP', NOW()::date, NOW()::date, 'FAC',
				    InfoManfts.valor_desembolsar,InfoManfts.valor_desembolsar,'PES', '0099-01-01'::TIMESTAMP,'', NOW(),
				    Usuario, 'COL', '004', 1.0,  NOW()::date, Usuario,
				    '','0099-01-01'::TIMESTAMP, InfoManfts.cod_proveedor,
				    InfoManfts.cod_proveedor, Usuario, 'S');

			--Detalle: (Propietario)
			INSERT INTO egresodet(
				    reg_status, dstrct, branch_code, bank_account_no, document_no,
				    item_no, concept_code, vlr, vlr_for, currency, last_update,
				    user_update, creation_date, creation_user, description, base,
				    tasa, tipo_documento, documento, tipo_pago, cuenta, auxiliar)
			    VALUES ('','FINV', 'ESTACION', 'GASOLINA', EGRPropietario,
				    lpad(secuencia, 3, '0'), 'FAC',InfoManfts.valor_desembolsar, InfoManfts.valor_desembolsar, 'PES', '0099-01-01'::TIMESTAMP,
				    '', NOW(),Usuario,'', 'COL',
				    1.0, 'FAP', InfoManfts.planilla, 'C', '22050411', '');

			--..::CONTABLE::..
			_grupo_transaccion = 0;
			SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

			--(Cabecera)
			INSERT INTO con.comprobante(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
				    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
				    total_items, moneda, fecha_aplicacion, aprobador, last_update,
				    user_update, creation_date, creation_user, base, usuario_aplicacion,
				    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
			    VALUES ('', 'FINV', 'EGR', EGRPropietario, _grupo_transaccion, 'OP',
				    _PeriodoCte, now()::date, 'EGRESO '||_grupo_transaccion, InfoManfts.cod_proveedor, InfoManfts.valor_desembolsar, InfoManfts.valor_desembolsar,
				    2, 'PES', '0099-01-01 00:00:00', Usuario, now(),
				    Usuario, now(), Usuario, 'COL', Usuario,
				    '003', '', 0.00, '', '');

			--(Detalle)
			--1
			_transaccion = 0;
			SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

			INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV', 'EGR', EGRPropietario, _grupo_transaccion, _transaccion,
				    _PeriodoCte, '22050411', InfoManfts.cod_proveedor, 'PROPIETARIO '||InfoManfts.cod_proveedor, InfoManfts.valor_desembolsar, 0.00,
				    InfoManfts.cod_proveedor, EGRPropietario, now(), Usuario, now(),
				    Usuario, 'COL', 'FAP', InfoManfts.planilla, '', 0.00,
				    '', '', '', '',
				    '', '');

			SELECT INTO RsEstacion * FROM etes.estacion_servicio WHERE id = _idEstacion;

			--2
			_transaccion = 0;
			SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

			--Buscamos el Nit de la Estacion de Servicio.
			SELECT INTO ESinfo * FROM etes.estacion_servicio WHERE id = _idEstacion;

			INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV', 'EGR', EGRPropietario, _grupo_transaccion, _transaccion,
				    _PeriodoCte, '23050313', InfoManfts.cod_proveedor, 'ESTACION-GASOLINA '||RsEstacion.nit_estacion, 0.00, InfoManfts.valor_desembolsar,
				    ESinfo.nit_estacion, EGRPropietario, now(), Usuario, now(),
				    Usuario, 'COL', 'FAP', InfoManfts.planilla, '', 0.00,
				    '', '', '', '',
				    '', '');


			--ACTUALIZAR EGRESO - Para que no se contabilice en el proceso normal
			update egreso
			set
			   transaccion = _grupo_transaccion,
			   fecha_contabilizacion = now(),
			   usuario_contabilizacion = Usuario,
			   periodo = _PeriodoCte
			where document_no = EGRPropietario;

		--D) GENERO LA CxC A TRANSPORTADORA

			--HC: IL | 13802804
			--Detalle: 13802801

			--Codigo Cliente
			SELECT INTO RsCliente * FROM cliente WHERE nit = InfoManfts.identificacion;
			RAISE NOTICE 'cod_proveedor: %, RsCliente: %', InfoManfts.identificacion, RsCliente.codcli;

			IF FOUND THEN

				SELECT INTO CXCPropietario etes.serie_cxc_propietario();

				--(Cabecera)
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
				    VALUES ('', 'FINV', 'FAC', CXCPropietario, InfoManfts.identificacion, RsCliente.codcli, 'AGA',
					    now()::date, now()::date, '0099-01-01', '0099-01-01 00:00:00',
					    'Tipo operacion: AGA  Numero Operacion: '||InfoManfts.planilla, '', InfoManfts.valor_neto_anticipo, 0.00, InfoManfts.valor_neto_anticipo,
					    InfoManfts.valor_neto_anticipo, 0.00, InfoManfts.valor_neto_anticipo, 1.000000, 'PES',
					    1, 'CREDITO', 'OP', 'OP',
					    '', '', '', '', 0,
					    0, '0099-01-01 00:00:00', '0099-01-01 00:00:00',
					    '0099-01-01 00:00:00', 'COL', '0099-01-01 00:00:00', '',
					    now(), Usuario, '0099-01-01', 'S', '',
					    'IL', '', '', 'OP', _PeriodoCte, 0.000000,
					    '', '0', '0', NULL, '', 'TRANSPORTADORA',
					    InfoManfts.razon_social, 'PLANILLA', InfoManfts.planilla, 'FINV', '',
					    '',1, '0099-01-01 00:00:00',
					    NULL, 'FCORR', InfoManfts.fecha_corrida, 'PLANI',
					    InfoManfts.planilla, '', '', 'N', '0099-01-01 00:00:00',
					    '', '', '', 'N',
					    '', '', '', '', '',
					    '', 'N');

				IF FOUND THEN

					INSERT INTO con.factura_detalle(
						    reg_status, dstrct, tipo_documento, documento, item, nit, concepto,
						    numero_remesa, descripcion, codigo_cuenta_contable, cantidad,
						    valor_unitario, valor_unitariome, valor_item, valor_itemme, valor_tasa,
						    moneda, last_update, user_update, creation_date, creation_user,
						    base, auxiliar, valor_ingreso, tipo_documento_rel, transaccion,
						    documento_relacionado, tipo_referencia_1, referencia_1, tipo_referencia_2,
						    referencia_2, tipo_referencia_3, referencia_3)
					    VALUES ('', 'FINV', 'FAC', CXCPropietario, 1, InfoManfts.identificacion, '097',
						    '', 'Tipo operacion: AGA  Numero Operacion: '||InfoManfts.planilla, '13802801', 1.0000,
						    InfoManfts.valor_neto_anticipo, InfoManfts.valor_neto_anticipo, InfoManfts.valor_neto_anticipo, InfoManfts.valor_neto_anticipo, 1.000000,
						    'PES', '0099-01-01 00:00:00', '', now(), Usuario,
						    'COL', InfoManfts.cod_proveedor, InfoManfts.valor_neto_anticipo, '', 0,
						    '', '', '', '',
						    '', '', '');

					--------------------------------------------------------------------------------------------------------------------------
					--..::CONTABLE::..
					_grupo_transaccion = 0;
					SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

					--(Cabecera)
					INSERT INTO con.comprobante(
						    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
						    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
						    total_items, moneda, fecha_aplicacion, aprobador, last_update,
						    user_update, creation_date, creation_user, base, usuario_aplicacion,
						    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
					    VALUES ('', 'FINV', 'FAC', CXCPropietario, _grupo_transaccion, 'OP',
						    _PeriodoCte, now()::date, 'CONT FAC '||CXCPropietario, InfoManfts.cod_proveedor, InfoManfts.valor_neto_anticipo, InfoManfts.valor_neto_anticipo,
						    2, 'PES', '0099-01-01 00:00:00', Usuario, now(),
						    Usuario, now(), Usuario, 'COL', Usuario,
						    '003', '', 0.00, '', '');

					--(Detalle)
					--1
					_transaccion = 0;
					SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

					INSERT INTO con.comprodet(
						    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
						    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
						    tercero, documento_interno, last_update, user_update, creation_date,
						    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
						    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
						    tipo_referencia_3, referencia_3)
					    VALUES ('', 'FINV', 'FAC', CXCPropietario, _grupo_transaccion, _transaccion,
						    _PeriodoCte, '13802804', InfoManfts.cod_proveedor, InfoManfts.nombre, InfoManfts.valor_neto_anticipo, 0.00,
						    InfoManfts.identificacion, 'FAC', now(), Usuario, now(),
						    Usuario, 'COL', 'PLANI', InfoManfts.planilla, '', 0.00,
						    '', '', '', '',
						    '', '');

					--2
					_transaccion = 0;
					SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

					INSERT INTO con.comprodet(
						    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
						    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
						    tercero, documento_interno, last_update, user_update, creation_date,
						    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
						    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
						    tipo_referencia_3, referencia_3)
					    VALUES ('', 'FINV', 'FAC', CXCPropietario, _grupo_transaccion, _transaccion,
						    _PeriodoCte, '13802801', InfoManfts.cod_proveedor, 'Tipo operacion: AGA  Numero Operacion: '||InfoManfts.planilla, 0.00, InfoManfts.valor_neto_anticipo,
						    InfoManfts.identificacion, 'FAC', now(), Usuario, now(),
						    Usuario, 'COL', 'PLANI', InfoManfts.planilla, '', 0.00,
						    '', '', '', '',
						    '', '');

					--ACTUALIZAR FACTURA CxC - Para que no se contabilice en el proceso normal.
					update con.factura
					set
					   transaccion = _grupo_transaccion,
					   fecha_contabilizacion = now()
					where documento = CXCPropietario;
					--------------------------------------------------------------------------------------------------------------------------

				END IF;

			END IF;

		mcad = 'OK';

	END LOOP;

	RETURN mcad;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.sp_contabilizaretesgasolina(integer, character varying, integer)
  OWNER TO postgres;
