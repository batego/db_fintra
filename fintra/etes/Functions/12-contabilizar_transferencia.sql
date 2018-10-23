-- Function: etes.contabilizar_transferencia(integer, date, character varying, character varying, character varying)

-- DROP FUNCTION etes.contabilizar_transferencia(integer, date, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION etes.contabilizar_transferencia(_idmanifiesto integer, fecha_documento date, periodo_corte character varying, reanticipos character varying, usuario character varying)
  RETURNS text AS
$BODY$

DECLARE


	InfoManfts record;
	RsCliente record;
	_grupo_transaccion numeric;
	_transaccion numeric;
	VlrComisionAnt numeric := 0;
	VlrResto numeric := 0;
	CXCPropietario varchar := '';
        queryBusqueda text:='';
	mcad TEXT := 'BAD';

BEGIN


	/**
	CONTABILIZACION DEL PROCESO ANTICIPOS PARA LAS ESTACIONES DE SERVICIO
	**/

	--..::DEBO RECORRER TANTO EL ANTICIPO COMO LOS REANTICIPOS DEPENDIENDO DEL PARAMETRO DE ENTRA::..

	if(reanticipos='N')then
		queryBusqueda:='SELECT
					mc.id,
					mc.id as id_manifiesto_carga,
					mc.planilla,
					mc.valor_neto_anticipo,
					mc.valor_descuentos_fintra,
					mc.valor_desembolsar,
					mc.fecha_corrida,
					''N''::varchar as reanticipo,
					ag.cod_agencia, ag.nombre_agencia, ag.id_transportadora,
					prop.cod_proveedor, prop.nombre,
					transp.cod_transportadora, transp.identificacion, transp.razon_social, transp.direccion
				FROM etes.manifiesto_carga mc
					INNER JOIN etes.agencias as ag on (mc.id_agencia = ag.id)
					INNER JOIN etes.vehiculo as vh on (mc.id_vehiculo = vh.id)
					INNER JOIN etes.propietario as prop on (vh.id_propietario = prop.id and prop.reg_status = '''')
					INNER JOIN etes.transportadoras as transp on (ag.id_transportadora = transp.id)
				WHERE mc.id ='||_idmanifiesto||' and
					mc.cxc_corrida = '''' and
					mc.periodo_contabilizacion = '''' and
					mc.transaccion = 0 and
					mc.reg_status = ''''  ';

	ELSE
		queryBusqueda:='SELECT
					mr.id,
					mr.id_manifiesto_carga,
					mr.planilla,
					mr.valor_reanticipo as valor_neto_anticipo,
					mr.valor_descuentos_fintra,
					mr.valor_desembolsar,
					mr.fecha_corrida,
					''S''::varchar as reanticipo,
					ag.cod_agencia, ag.nombre_agencia, ag.id_transportadora,
					prop.cod_proveedor, prop.nombre,
					transp.cod_transportadora, transp.identificacion, transp.razon_social, transp.direccion
				FROM etes.manifiesto_reanticipos mr
					INNER JOIN etes.manifiesto_carga as ant on (mr.id_manifiesto_carga = ant.id)
					INNER JOIN etes.agencias as ag on (ant.id_agencia = ag.id)
					INNER JOIN etes.vehiculo as vh on (ant.id_vehiculo = vh.id)
					INNER JOIN etes.propietario as prop on (vh.id_propietario = prop.id and prop.reg_status = '''')
					INNER JOIN etes.transportadoras as transp on (ag.id_transportadora = transp.id)
				WHERE mr.id ='||_idmanifiesto||' and
					mr.cxc_corrida = '''' and
					mr.periodo_contabilizacion = '''' and
					mr.transaccion = 0 and
					mr.reg_status = '''' ';
	end if;




	FOR InfoManfts IN  execute queryBusqueda LOOP
		RAISE NOTICE 'InfoManfts %',InfoManfts;

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
			    VALUES ('', 'FINV', 'AET', InfoManfts.planilla, _grupo_transaccion, 'OP',
				    periodo_corte, fecha_documento::date, 'Contabiliza Transferencia: '||InfoManfts.planilla, InfoManfts.cod_proveedor, InfoManfts.valor_neto_anticipo, InfoManfts.valor_neto_anticipo,
				    3, 'PES', '0099-01-01 00:00:00', Usuario, now(),
				    Usuario, now(), Usuario, 'COL', Usuario,
				    '', '', 0.00, 'AET', InfoManfts.cod_proveedor);

			--(Detalle)
			--1.)TEMPORAL ANTICIPO
			_transaccion = 0;
			SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

			INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV','AET', InfoManfts.planilla, _grupo_transaccion, _transaccion,
				    periodo_corte, '13802801', InfoManfts.cod_proveedor, 'Contabiliza AET DEBITO '||InfoManfts.planilla, InfoManfts.valor_neto_anticipo, 0.00,
				    InfoManfts.identificacion, 'AET', now(), Usuario, now(),
				    Usuario, 'COL', 'AET', InfoManfts.planilla, '', 0.00,
				    '', '', '', '',
				    '', '');

			--2.)Comision banco
			_transaccion = 0;
			SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

			--VlrComisionAnt = ROUND(InfoManfts.valor_neto_anticipo*(1.4/100));
			VlrComisionAnt = InfoManfts.valor_descuentos_fintra;

			INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV','AET', InfoManfts.planilla, _grupo_transaccion, _transaccion,
				    periodo_corte, 'I010290024153', InfoManfts.cod_proveedor, 'Contabiliza ATE CREDITO '||InfoManfts.planilla, 0.00, VlrComisionAnt,
				    InfoManfts.cod_proveedor, 'AET', now(), Usuario, now(),
				    Usuario, 'COL','AET', InfoManfts.planilla, '', 0.00,
				    '', '', '', '',
				    '', '');

			--3.)ANTICIPOS-TRANSFERENCIAS
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
			    VALUES ('', 'FINV','AET', InfoManfts.planilla, _grupo_transaccion, _transaccion,
				    periodo_corte, '23050307', InfoManfts.cod_proveedor, 'Contabiliza AET CREDITO '||InfoManfts.planilla, 0.00, VlrResto,
				    InfoManfts.cod_proveedor,'AET', now(), Usuario, now(),
				    Usuario, 'COL','AET', InfoManfts.planilla, '', 0.00,
				    '', '', '', '',
				    '', '');


			--2) Marco las planillas Procesadas.
			IF ( InfoManfts.reanticipo = 'N' ) THEN

				UPDATE etes.manifiesto_carga
				SET
				   fecha_contabilizacion = now(),
				   periodo_contabilizacion = periodo_corte,
				   transaccion = _grupo_transaccion
				WHERE id = InfoManfts.id;

			ELSIF ( InfoManfts.reanticipo = 'S' ) THEN

				UPDATE etes.manifiesto_reanticipos
				SET
				   fecha_contabilizacion = now(),
				   periodo_contabilizacion = periodo_corte,
				   transaccion = _grupo_transaccion
				WHERE id = InfoManfts.id;

			END IF;


		--D) GENERO LA CxC A TRANSPORTADORA

			--HC: IC | 13802802
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
				    VALUES ('', 'FINV', 'FAC', CXCPropietario, InfoManfts.identificacion, RsCliente.codcli, 'AET',
					    fecha_documento::date, fecha_documento::date, '0099-01-01', '0099-01-01 00:00:00',
					    'Tipo operacion: AET  Numero Operacion: '||InfoManfts.planilla, '', InfoManfts.valor_neto_anticipo, 0.00, InfoManfts.valor_neto_anticipo,
					    InfoManfts.valor_neto_anticipo, 0.00, InfoManfts.valor_neto_anticipo, 1.000000, 'PES',
					    1, 'CREDITO', 'OP', 'OP',
					    '', '', '', '', 0,
					    0, '0099-01-01 00:00:00', '0099-01-01 00:00:00',
					    '0099-01-01 00:00:00', 'COL', '0099-01-01 00:00:00', '',
					    now(), Usuario, '0099-01-01', 'S', '',
					    'IC', '', '', 'OP', periodo_corte, 0.000000,
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
						    '', 'Tipo operacion: AET  Numero Operacion: '||InfoManfts.planilla, '13802801', 1.0000,
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
						    periodo_corte, fecha_documento::date, 'CONT FAC '||CXCPropietario, InfoManfts.cod_proveedor, InfoManfts.valor_neto_anticipo, InfoManfts.valor_neto_anticipo,
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
						    periodo_corte, '13802802', InfoManfts.cod_proveedor, InfoManfts.nombre, InfoManfts.valor_neto_anticipo, 0.00,
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
						    periodo_corte, '13802801', InfoManfts.cod_proveedor, 'Tipo operacion: AET  Numero Operacion: '||InfoManfts.planilla, 0.00, InfoManfts.valor_neto_anticipo,
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
ALTER FUNCTION etes.contabilizar_transferencia(integer, date, character varying, character varying, character varying)
  OWNER TO postgres;
