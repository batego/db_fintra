-- Function: etes.crear_cxp_transferencia()

-- DROP FUNCTION etes.crear_cxp_transferencia();

CREATE OR REPLACE FUNCTION etes.crear_cxp_transferencia()
  RETURNS "trigger" AS
$BODY$
DECLARE


producto varchar:='';
recordManifiesto record;
vectorCuentas varchar[]='{}';
cmc_factura varchar:='' ;
contabilizarCXP text:='';

BEGIN
	--1.)PREGUNTAR SI EL PRODUCTO ES TRANSFERENCIA
	SELECT INTO producto codigo_proserv FROM etes.productos_servicios_transp  WHERE id=NEW.id_proserv;
	--ANTICIPO TRANSFERENCIA
	RAISE NOTICE 'FUNCTION CREAR CXP TRANSFERENCIA: %',producto ;

	IF(producto ='ANT00002' AND OLD.valor_desembolsar = 0 AND NEW.valor_desembolsar > 0) THEN
		IF(etes.validacion_cuentas('CXP_TRANSFERENCIA'))THEN

			vectorCuentas:=etes.get_cuentas_perfil('CXP_TRANSFERENCIA');
			RAISE NOTICE 'CUENTA HC :vectorCuentas[1]: %', vectorCuentas[1] ;
			RAISE NOTICE 'CUENTA DETALLE :vectorCuentas[2]: %', vectorCuentas[2] ;

			SELECT INTO cmc_factura  cmc FROM con.cmc_doc WHERE tipodoc='FAP' AND cuenta=vectorCuentas[1] ;

			FOR recordManifiesto IN(

						SELECT
						    trans.id
						    ,trans.razon_social as transportadora
						    ,anticipo.id as id_manifiesto
						    ,agencia.nombre_agencia
						    ,conductor.nombre as conductor
						    ,propietario.cod_proveedor as cedula_propietario
						    ,propietario.nombre as propietario
						    ,vehiculo.placa
						    ,anticipo.planilla
						    ,to_char(anticipo.fecha_envio_fintra,'YYYY-MM-DD HH24-MM-SS') as fecha_anticipo
						    ,anticipo.creation_user as usuario_creacion
						    ,producto_ser.codigo_proserv
						    ,producto_ser.descripcion
						    ,'N'::text as reanticipo
						    ,anticipo.usuario_aprobacion
						    ,anticipo.valor_neto_anticipo as valor_anticipo
						    ,0.0::numeric as porcentaje_descuento
						    ,anticipo.valor_descuentos_fintra
						    ,anticipo.valor_desembolsar --sin comision banco
						    ,conductor.banco
						    ,conductor.sucursal
						    ,conductor.no_cuenta
						    ,conductor.tipo_cuenta
						    ,conductor.nombre_titular_cuenta
						    ,conductor.cedula_titular_cuenta
						    ,anticipo.documento_cxp
						    ,(select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO')as aprobador
						    FROM etes.manifiesto_carga as anticipo
						    INNER JOIN etes.agencias as agencia on(agencia.id=anticipo.id_agencia)
						    INNER JOIN etes.vehiculo as vehiculo on(vehiculo.id=anticipo.id_vehiculo)
						    INNER JOIN etes.transportadoras as trans on (agencia.id_transportadora=trans.id)
						    INNER JOIN etes.conductor as conductor on (anticipo.id_conductor=conductor.id)
						    INNER JOIN etes.propietario as propietario on (vehiculo.id_propietario=propietario.id)
						    INNER JOIN etes.productos_servicios_transp as producto_ser on (anticipo.id_proserv=producto_ser.id)
						    WHERE
						    anticipo.reg_status=''
						    AND anticipo.id=NEW.id
						    AND anticipo.transferido='N'
						    AND anticipo.fecha_transferencia='0099-01-01 00:00:00'::timestamp without time zone
						    AND anticipo.aprobado='N'
						    AND anticipo.fecha_aprobacion='0099-01-01 00:00:00'::timestamp without time zone
						    AND producto_ser.codigo_proserv=producto
					)

			LOOP

				--A) GENERO LA CXP AL PROPIETARIO TRANSFERENCIA

				--HC: IC | 22050407
				--Detalle: 23050307
				--OPERATIVO

				RAISE NOTICE 'FUNCTION CXP:::::::::: %',producto ;
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

					VALUES ('', 'FINV', recordManifiesto.cedula_propietario,  'FAP', recordManifiesto.planilla, 'TIPO OPERACION : TRANSFERENCIA   PLANILLA: '||recordManifiesto.planilla,
					    'OP', cmc_factura, '', '', '',
					    now(), recordManifiesto.aprobador,recordManifiesto.aprobador,'BANCOLOMBIA', 'CPAG',
					    'PES', recordManifiesto.valor_desembolsar, 0,  recordManifiesto.valor_desembolsar,  recordManifiesto.valor_desembolsar, 0,
					     recordManifiesto.valor_desembolsar,  1, '', '0099-01-01 00:00:00'::timestamp,
					    '',  '0099-01-01 00:00:00'::timestamp,  '0099-01-01 00:00:00'::timestamp,
					    '', 0, 0, 0,
					    '0099-01-01 00:00:00'::timestamp, '', NOW(), NEW.creation_user, 'COL',
					    '', '', '', '0099-01-01 00:00:00'::timestamp, '0099-01-01 00:00:00'::timestamp,
					    '0099-01-01 00:00:00'::timestamp, '', '', '',
					    '', 0, 0, '4',
					    0, 'PES', NOW()::date,NOW()::date,
					     '0099-01-01 00:00:00'::timestamp, 'S', 0, 'N', '4',
					    'PLANI', recordManifiesto.planilla,'','',
					    '','', 'N', 'N');

				INSERT INTO fin.cxp_items_doc(
				    reg_status, dstrct, proveedor, tipo_documento, documento, item,
				    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
				    last_update, user_update, creation_date, creation_user, base,
				    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
				    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
				    referencia_3)

				VALUES ('', 'FINV', recordManifiesto.cedula_propietario, 'FAP', recordManifiesto.planilla, '001',
				    'TIPO OPERACION : TRANSFERENCIA   PLANILLA: '||recordManifiesto.planilla,  recordManifiesto.valor_desembolsar,  recordManifiesto.valor_desembolsar, vectorCuentas[2] , '', recordManifiesto.planilla,
				    '0099-01-01 00:00:00'::timestamp, '', NOW(), NEW.creation_user, 'COL',
				    '','','', '','',
				    '', '', '', '',
				    '');

				--B)ACTUALIZO EL MANIFIESTO CON EL NUMERO DE CXP
				UPDATE etes.manifiesto_carga
				   SET documento_cxp=recordManifiesto.planilla,
				       last_update=now(),
				       user_update='TRIGGER'
				WHERE id=NEW.id;

				contabilizarCXP:=etes.contabilizar_cxp_transferencia(recordManifiesto.planilla, 'TRIGGER');

			END LOOP;

		END IF;
	END IF;
 RETURN NEW;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.crear_cxp_transferencia()
  OWNER TO postgres;
