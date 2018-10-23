-- Function: etes.cxp_estaciones(integer, character varying, character varying)

-- DROP FUNCTION etes.cxp_estaciones(integer, character varying, character varying);

CREATE OR REPLACE FUNCTION etes.cxp_estaciones(ideds integer, fecha character varying, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

recordCabecera record;
rs text :='OK';
numCxP varchar:= '';
total_factura numeric:=0;
vectorCuentas varchar[]='{}';
cmc_factura varchar:='' ;
recordDetalleCXP record;
items integer;
grupoTransaccion integer:=0;
generaNotaComision text:='';

BEGIN

       --VALIDAMOS EL PERFIL CONTABLE PARA CREAR LA CXP DE LA EDS--
        IF(etes.validacion_cuentas('CXP_EDS'))THEN

		vectorCuentas:=etes.get_cuentas_perfil('CXP_EDS');
		RAISE NOTICE 'CUENTA DETALLE :vectorCuentas[2]: %', vectorCuentas[2] ;
		SELECT INTO cmc_factura  cmc FROM con.cmc_doc WHERE tipodoc='FAP' AND cuenta=vectorCuentas[1] ;

		--1.)CABECERA DE LA CUENTA POR COBRAR.
			SELECT INTO recordCabecera
			       'FINV'::VARCHAR as distrito,
				propietario_es.identificacion as proveedor,
				'FAP'::VARCHAR as tipo_doc,
				'ESTACION DE SERVICIO '||estacion.nombre_eds as descripcion,
				estacion.municipio as agencia,
				cmc_factura::VARCHAR as handle_code,--FALTA EL HC
				(select table_code from tablagen where table_type= 'AUTCXP' AND referencia='CXP_EDS' AND descripcion=usuario)as aprobador,
				'BANCOLOMBIA'::VARCHAR as banco,
				'CPAG'::VARCHAR as sucursal,
				'PES'::VARCHAR as moneda,
				--SUM((veds.total_venta-veds.valor_comision_fintra)) as vlr_neto,
				SUM(veds.total_venta) as vlr_neto,
				1.0000000000::numeric as tasa
			FROM etes.ventas_eds as veds
			INNER JOIN etes.manifiesto_carga as mc on (veds.id_manifiesto_carga=mc.id)
			INNER JOIN etes.conductor as conductor on (conductor.id=mc.id_conductor)
			INNER JOIN etes.vehiculo as vehiculo on (vehiculo.id=mc.id_vehiculo)
			INNER JOIN etes.productos_es as prod on (veds.id_producto=prod.id)
			INNER JOIN etes.unidad_medida as unidad on (unidad.id=prod.id_unidad_medida)
			INNER JOIN etes.estacion_servicio as estacion on (veds.id_eds=estacion.id)
			INNER JOIN etes.propietario_estacion as propietario_es on  (estacion.id_propietario_estacion=propietario_es.id)
			WHERE
			veds.reg_status=''
			AND mc.reg_status=''
			AND veds.id_eds=ideds::integer
			AND veds.documento_cxp='' AND fecha_venta::date=fecha::date
			GROUP BY
			propietario_es.identificacion
			,estacion.nombre_eds
			,estacion.municipio;

			IF(FOUND)THEN
				numCxP :=etes.serie_cxp_eds();
				total_factura:=recordCabecera.vlr_neto;
				--2.)CABECERA
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
					    tipo_referencia_3, referencia_3, indicador_traslado_fintra, factoring_formula_aplicada,
					    factura_tipo_nomina)
				    VALUES ('', recordCabecera.distrito, recordCabecera.proveedor,  recordCabecera.tipo_doc, numCxP, recordCabecera.descripcion,
					    recordCabecera.agencia, recordCabecera.handle_code, '', '', '',
					    '0099-01-01 00:00:00'::timestamp, recordCabecera.aprobador, '', recordCabecera.banco, recordCabecera.sucursal,
					    recordCabecera.moneda, recordCabecera.vlr_neto, 0,  recordCabecera.vlr_neto,  recordCabecera.vlr_neto, 0,
					     recordCabecera.vlr_neto,  recordCabecera.tasa, '', '0099-01-01 00:00:00'::timestamp,
					    '',  '0099-01-01 00:00:00'::timestamp,  '0099-01-01 00:00:00'::timestamp,
					    '', 0, 0, 0,
					    '0099-01-01 00:00:00'::timestamp, '', NOW(), usuario, 'COL',
					    '', '', '', '0099-01-01 00:00:00'::timestamp, '0099-01-01 00:00:00'::timestamp,
					    '0099-01-01 00:00:00'::timestamp, '', '', '',
					    '', 0, 0, '4',
					    0, 'PES', NOW()::date,(NOW() + '8 day')::date,
					     '0099-01-01 00:00:00'::timestamp, 'S', 0, 'N', '4',
					    '', '','','',
					    '','', 'N', 'N',
					    'N');

				--2.)DETALLE DE LA CXP
				items :=1;
				FOR recordDetalleCXP in (
							SELECT
								mc.planilla,
							       'FINV'::VARCHAR as distrito,
								propietario_es.identificacion as proveedor,
								'FAP'::VARCHAR as tipo_doc,
								'ESTACION DE SERVICIO '||estacion.nombre_eds as descripcion,
								estacion.municipio as agencia,
								(select table_code from tablagen where table_type= 'AUTCXP' AND referencia='CXP_EDS' AND descripcion=usuario)as aprobador,
								'BANCOLOMBIA'::VARCHAR as banco,
								'CPAG'::VARCHAR as sucursal,
								'PES'::VARCHAR as moneda,
								--SUM((veds.total_venta-veds.valor_comision_fintra)) as vlr_neto,
								SUM(veds.total_venta) as vlr_neto,
								1.0000000000::numeric as tasa
							FROM etes.ventas_eds as veds
							INNER JOIN etes.manifiesto_carga as mc on (veds.id_manifiesto_carga=mc.id)
							INNER JOIN etes.conductor as conductor on (conductor.id=mc.id_conductor)
							INNER JOIN etes.vehiculo as vehiculo on (vehiculo.id=mc.id_vehiculo)
							INNER JOIN etes.productos_es as prod on (veds.id_producto=prod.id)
							INNER JOIN etes.unidad_medida as unidad on (unidad.id=prod.id_unidad_medida)
							INNER JOIN etes.estacion_servicio as estacion on (veds.id_eds=estacion.id)
							INNER JOIN etes.propietario_estacion as propietario_es on  (estacion.id_propietario_estacion=propietario_es.id)
							WHERE
							veds.reg_status=''
							AND mc.reg_status=''
							AND veds.id_eds=ideds::integer
							AND veds.documento_cxp =''
							AND fecha_venta::date=fecha::date
							GROUP BY
							mc.planilla,
							propietario_es.identificacion
							,estacion.nombre_eds
							,estacion.municipio
							)

				LOOP
					raise notice 'detalle cxp %', items;
					INSERT INTO fin.cxp_items_doc(
					    reg_status, dstrct, proveedor, tipo_documento, documento, item,
					    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
					    last_update, user_update, creation_date, creation_user, base,
					    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
					    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
					    referencia_3)
					VALUES ('', recordDetalleCXP.distrito, recordDetalleCXP.proveedor, recordDetalleCXP.tipo_doc, numCxP,lpad(items, 3, '0'),
					    recordDetalleCXP.descripcion,  recordDetalleCXP.vlr_neto,  recordDetalleCXP.vlr_neto, vectorCuentas[2], '', recordDetalleCXP.planilla,
					    '0099-01-01 00:00:00'::timestamp, '', NOW(), usuario, 'COL',
					    '','','', '','',
					    '', '', '', '',
					    '');

					items := items+1 ;

				END LOOP;

				--3.) ACTUALIZAMOS LAS VENTAS CON EL NUMERO DE LA CXP

					UPDATE etes.ventas_eds
					   SET
					   last_update=NOW(),
					   user_update=usuario,
					   documento_cxp=numCxP
					 WHERE
					  id_eds=ideds::integer
					  AND documento_cxp=''
					  AND fecha_venta::date=fecha::date;


				--4.)CONTABILIZAMOS LA CXP.

				SELECT INTO grupoTransaccion nextval('con.comprobante_grupo_transaccion_seq');

				INSERT INTO con.comprobante(
						    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
						    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
						    total_items, moneda, fecha_aplicacion, aprobador, last_update,
						    user_update, creation_date, creation_user, base, usuario_aplicacion,
						    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
				SELECT
					reg_status,
					dstrct,
					tipo_documento,
					documento,
					grupoTransaccion as grupo_transaccion,
					'OP'::text as sucursal,
					replace(substring(now(),1,7),'-','') as perido,
					now()::date as fechadoc,
					'CONTABLILIZACION CUENTA DE COBRO EDS'::text as detalle,
					proveedor as tercero,
					vlr_neto as valor_debito,
					vlr_neto as valor_credito,
					(SELECT (COUNT(0)+1)::INTEGER FROM fin.cxp_items_doc WHERE documento =fin.cxp_doc.documento) as total_items,
					moneda_banco as moneda,
					now() as fecha_aplicacion,
					''::text as aprobador,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::text as user_update,
					now() as creation_date,
					usuario as creation_user,
					'COL'::text as base,
					usuario as usuario_aplicacion,
					'002'::text as tipo_operacion,
					''::text as moneda_foranea,
					0.00::numeric as vlr_for,
					''::text as ref_1,
					''::text as ref_2
				FROM fin.cxp_doc    WHERE  documento = numCxP  and tipo_documento='FAP' ;

				--4.1)DETALLE CREDITO DE LA CXP

				INSERT INTO con.comprodet(
					    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
					    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
					    tercero, documento_interno, last_update, user_update, creation_date,
					    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
					    tipo_referencia_3, referencia_3)
				SELECT
					reg_status,
					dstrct,
					tipo_documento,
					documento,
					grupoTransaccion as grupo_transaccion,
					nextval('con.comprodet_transaccion_seq') as transaccion,
					replace(substring(now(),1,7),'-','') as perido,
					vectorCuentas[1] as codigo_cuenta,
					'AR-'||proveedor::text as auxiliar,
					'CONTABLILIZACION CUENTA DE COBRO EDS'::text as detalle,
					0.0::numeric as valor_debito,
					sum(vlr) as valor_credito,
					proveedor as tercero,
					documento as documento_interno,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::text as user_update,
					now() as creation_date,
					usuario as creation_user,
					'COL'::text as base,
					tipo_documento as tipodoc_rel,
					documento as documento_rel,
					''::text as  abc,
					0.00 as vlr_for,
					''::text as tipo_referencia_1,
					''::text as referencia_1,
					''::text as tipo_referencia_2,
					''::text as referencia_2,
					''::text as tipo_referencia_3,
					''::text as referencia_3
				FROM fin.cxp_items_doc  WHERE  documento = numCxP and tipo_documento='FAP'
				GROUP BY reg_status,
					dstrct,
					documento,
					codigo_cuenta,
					proveedor,
					tipo_documento ;

				--4.2)DETALLE DEBITO DE LA CXP

				INSERT INTO con.comprodet(
					    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
					    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
					    tercero, documento_interno, last_update, user_update, creation_date,
					    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
					    tipo_referencia_3, referencia_3)
				SELECT
					reg_status,
					dstrct,
					tipo_documento,
					documento,
					grupoTransaccion as grupo_transaccion,
					nextval('con.comprodet_transaccion_seq') as transaccion,
					replace(substring(now(),1,7),'-','') as perido,
					codigo_cuenta,
					''::text as auxiliar,
					'CONTABLILIZACION CUETA DE COBRO EDS'::text as detalle,
					vlr as valor_debito,
					0.0::numeric as valor_credito,
					proveedor as tercero,
					documento as documento_interno,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::text as user_update,
					now() as creation_date,
					usuario as creation_user,
					'COL'::text as base,
					tipo_documento as tipodoc_rel,
					documento as documento_rel,
					''::text as  abc,
					0.00 as vlr_for,
					''::text as tipo_referencia_1,
					''::text as referencia_1,
					''::text as tipo_referencia_2,
					''::text as referencia_2,
					'ANTIC'::text as tipo_referencia_3,
					 planilla as referencia_3
				FROM fin.cxp_items_doc  WHERE documento = numCxP and tipo_documento='FAP' ;


				--4.3 MARCAMOS LA CXP COMO CONTABILIZADA
				UPDATE fin.cxp_doc
				SET fecha_contabilizacion=now(),
					usuario_contabilizo=usuario,
					transaccion=grupoTransaccion,
					periodo=replace(substring(now(),1,7),'-',''),
					last_update=now(),
					user_update=usuario
				WHERE documento=numCxP and tipo_documento='FAP' ;

				--4.4 GENERAMOS LA NOTA CREDITO MENSUAL SI LA CXP ES LA PRIMERA DEL MES.
				--Parametros: documento cxp ,id de la eds.
				generaNotaComision:=etes.descontar_comisiones_xventas(numCxP::varchar,ideds::integer);
				raise notice 'generaNotaComision : %',generaNotaComision;

			ELSE
			  rs:='ERROR';
			END IF;
	ELSE
	  rs:='ERROR';
	END IF;

	RETURN 	 rs||';'||numCxP||';'||total_factura;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.cxp_estaciones(integer, character varying, character varying)
  OWNER TO postgres;
