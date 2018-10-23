-- Function: etes.cxc_transportadoras(integer, character varying, character varying)

-- DROP FUNCTION etes.cxc_transportadoras(integer, character varying, character varying);

CREATE OR REPLACE FUNCTION etes.cxc_transportadoras(id_transportadora integer, fechacorrida character varying, usuario character varying)
  RETURNS boolean AS
$BODY$

DECLARE

	recordManifiestos record;
	RsInfoIA record;

	_grupo_transaccion integer;
	_transaccion integer;

	numCxC varchar:='';
	vectorCuentas varchar[]='{}';
	cmc_factura varchar:='' ;
	_PeriodoCte varchar := '';

	rs boolean :=true;

BEGIN

	_PeriodoCte = replace(substring(now(),1,7),'-','')::varchar;

	--CREAMOS NOTA DE AJUSTE PARA MATAR LAS CXC INDIVIDUALES DEL MANIFIESTO.

	IF (etes.validacion_cuentas('IA_TRANSPORTADORA') AND etes.ia_cxc_transportadoras_corrida(fechacorrida, usuario) ) THEN
		--raise notice 'VALIDACION CUENTAS';
		IF ( etes.validacion_cuentas('CXC_TRANSPORTADORA') ) THEN

			vectorCuentas:=etes.get_cuentas_perfil('CXC_TRANSPORTADORA');
			RAISE NOTICE 'CUENTA DETALLE :vectorCuentas[2]: %', vectorCuentas[2] ;

			SELECT INTO cmc_factura cmc FROM con.cmc_doc WHERE tipodoc='FAC' AND cuenta=vectorCuentas[1];

			FOR recordManifiestos IN (

				SELECT
					id,
					identificacion,
					transportadora,
					producto,
					fecha_vencimiento,
					sum(valor_anticipos) AS valor,
					fecha_corrida
				FROM (
					SELECT
						trans.id
						,trans.identificacion
						,trans.razon_social as transportadora
						,producto_ser.codigo_proserv as producto
						,anticipo.fecha_pago_fintra::date as fecha_vencimiento
						,anticipo.valor_neto_anticipo as valor_anticipos
						,anticipo.fecha_corrida::date
					FROM etes.manifiesto_carga anticipo
						INNER JOIN etes.agencias as agencia on(agencia.id=anticipo.id_agencia)
						INNER JOIN etes.vehiculo as vehiculo on(vehiculo.id=anticipo.id_vehiculo)
						INNER JOIN etes.transportadoras as trans on (agencia.id_transportadora=trans.id)
						INNER JOIN etes.conductor as conductor on (anticipo.id_conductor=conductor.id)
						INNER JOIN etes.propietario as propietario on (vehiculo.id_propietario=propietario.id)
						INNER JOIN etes.productos_servicios_transp as producto_ser on (anticipo.id_proserv=producto_ser.id)
					WHERE
					trans.id= id_transportadora
					AND anticipo.reg_status =''
					AND anticipo.fecha_corrida::date <= fechaCorrida::date
					AND anticipo.cxc_corrida =''

					UNION ALL

					SELECT	 trans.id
						,trans.identificacion
						,trans.razon_social as transportadora
						,producto_ser.codigo_proserv as producto
						,reanticipo.fecha_pago_fintra::date as fecha_vencimiento
						,reanticipo.valor_reanticipo as valor_anticipos
						,reanticipo.fecha_corrida::date
					FROM etes.manifiesto_reanticipos reanticipo
						INNER JOIN etes.manifiesto_carga as anticipo on (reanticipo.id_manifiesto_carga=anticipo.id)
						INNER JOIN etes.agencias as agencia on(agencia.id=anticipo.id_agencia)
						INNER JOIN etes.vehiculo as vehiculo on(vehiculo.id=anticipo.id_vehiculo)
						INNER JOIN etes.transportadoras as trans on (agencia.id_transportadora=trans.id)
						INNER JOIN etes.conductor as conductor on (anticipo.id_conductor=conductor.id)
						INNER JOIN etes.propietario as propietario on (vehiculo.id_propietario=propietario.id)
						INNER JOIN etes.productos_servicios_transp as producto_ser on (anticipo.id_proserv=producto_ser.id)
					WHERE
					trans.id= id_transportadora
					AND reanticipo.reg_status =''
					AND reanticipo.fecha_corrida::date <= fechaCorrida::date
					AND reanticipo.cxc_corrida =''
				)tabla
				GROUP BY
				id,
				identificacion,
				transportadora,
				producto,
				fecha_vencimiento,
				fecha_corrida
				order by fecha_vencimiento
				)

			LOOP

				--1.)Generar Cabecera de la cxc
				numCxC := etes.serie_cxc_trans();
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
				    VALUES ('', 'FINV','FAC', numCxC, recordManifiestos.identificacion,  get_codnit(recordManifiestos.identificacion), recordManifiestos.producto,
					    now()::date, recordManifiestos.fecha_vencimiento, '0099-01-01 00:00:00'::timestamp without time zone, now()::date,
					    'CXC CORRIDA TRANSPORTADORAS', '',recordManifiestos.valor, 0.0,recordManifiestos.valor,
					    recordManifiestos.valor, 0.0, recordManifiestos.valor, 1.000000, 'PES',
					    1,'CREDITO','OP','OP',
					    '','','','', 0,
					    0, '0099-01-01 00:00:00'::timestamp without time zone, '0099-01-01 00:00:00'::timestamp without time zone,
					    '0099-01-01 00:00:00'::timestamp without time zone, 'COL', '0099-01-01 00:00:00'::timestamp without time zone, '',
					    NOW(), usuario,'0099-01-01 00:00:00'::timestamp without time zone, 'S', '',
					    cmc_factura, '', '', 'OP', '', 0,
					    '', '0', '0', '', '', '',
					    '', '', '', '', '',
					    '', 0, '0099-01-01 00:00:00'::timestamp without time zone,
					    '', '', '', '',
					    '', '','', 'N', '0099-01-01 00:00:00'::timestamp without time zone,
					    '', '', '', 'N',
					    '', '', '','', '',
					    '', 'N');


				--2.)Generar detalle de la cxc
				INSERT INTO con.factura_detalle(
					    reg_status, dstrct, tipo_documento, documento, item, nit, concepto,
					    numero_remesa, descripcion, codigo_cuenta_contable, cantidad,
					    valor_unitario, valor_unitariome, valor_item, valor_itemme, valor_tasa,
					    moneda, last_update, user_update, creation_date, creation_user,
					    base, auxiliar, valor_ingreso, tipo_documento_rel, transaccion,
					    documento_relacionado, tipo_referencia_1, referencia_1, tipo_referencia_2,
					    referencia_2, tipo_referencia_3, referencia_3)
				    VALUES ('', 'FINV', 'FAC', numCxC, 1,  recordManifiestos.identificacion, '01',
					    '', 'CXC CORRIDA TRANSPORTADORAS', vectorCuentas[2], 1,
					    recordManifiestos.valor, recordManifiestos.valor, recordManifiestos.valor, recordManifiestos.valor, 1,
					    'PES', '0099-01-01 00:00:00'::timestamp without time zone, '', NOW(), usuario,
					    'COL', '', 0, '', 0,
					    '', '', '', '',
					    '', '', '');

				--3.)ACTUALIZAR DOCUMENTO CXC MANIFIESTO Y REANTICIPO.
				UPDATE etes.manifiesto_carga
				SET cxc_corrida=numCxC
				WHERE fecha_corrida::date=recordManifiestos.fecha_corrida AND cxc_corrida='' AND reg_status ='';

				UPDATE etes.manifiesto_reanticipos
				SET cxc_corrida=numCxC
				WHERE fecha_corrida::date=recordManifiestos.fecha_corrida AND cxc_corrida='' AND reg_status ='';



				raise notice 'recordManifiestos.producto: % fecha_corrida: %',recordManifiestos.producto,recordManifiestos.fecha_corrida;
				--4.) ..::CONTABILIZO LA CXC::..
				select into RsInfoIA *
				from con.ingreso
				where num_ingreso in (
					select num_ingreso from con.ingreso_detalle where documento in (
						select documento
						from con.factura
						where documento in (select documento from con.factura where documento like 'PP%'
						and concepto =case when recordManifiestos.producto='ANT00002' then 'AET' else 'AGA' end
						and tipo_documento = 'FAC'
						and cmc = case when recordManifiestos.producto='ANT00002' then 'IC' else 'IL'  end
						and tipo_referencia_1 = 'FCORR'
						and referencia_1::date = fechacorrida::date limit 1)
					)
				);

				_grupo_transaccion = 0;
				SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

				--(Cabecera)
				INSERT INTO con.comprobante(
					    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
					    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
					    total_items, moneda, fecha_aplicacion, aprobador, last_update,
					    user_update, creation_date, creation_user, base, usuario_aplicacion,
					    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
				    VALUES ('', 'FINV', 'FAC', numCxC, _grupo_transaccion, 'OP',
					    _PeriodoCte, now(), 'CONT FAC '||numCxC, recordManifiestos.identificacion, recordManifiestos.valor, recordManifiestos.valor,
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
				    VALUES ('', 'FINV', 'FAC', numCxC, _grupo_transaccion, _transaccion,
					    _PeriodoCte, '13802806', 'CUENTA AUXILIAR', recordManifiestos.transportadora, recordManifiestos.valor, 0.00,
					    recordManifiestos.identificacion, 'FAC', now(), Usuario, now(),
					    Usuario, 'COL', 'ICA', RsInfoIA.num_ingreso, '', 0.00,
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
				    VALUES ('', 'FINV', 'FAC', numCxC, _grupo_transaccion, _transaccion,
					    _PeriodoCte, '13802805', 'CUENTA AUXILIAR', 'CXC CORRIDA TRANSPORTADORAS', 0.00, recordManifiestos.valor,
					    recordManifiestos.identificacion, 'FAC', now(), Usuario, now(),
					    Usuario, 'COL', 'FAC', numCxC, '', 0.00,
					    '', '', '', '',
					    '', '');

				--ACTUALIZAR FACTURA CxC - Para que no se contabilice en el proceso normal.
				update con.factura
				set
				   transaccion = _grupo_transaccion,
				   fecha_contabilizacion = now()
				where documento = numCxC;
				--------------------------------------------------------------------------------------------------------------------------

			END LOOP;

		ELSE --FIN IF VALIDAR CUENTA
			rs:=false;
		END IF;

	ELSE --FIN IF NOTA DE AJUSTES
		rs:=false;
	END IF;

	RETURN  rs;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.cxc_transportadoras(integer, character varying, character varying)
  OWNER TO postgres;
