-- Function: opav.sl_cxp_aseguradoras(character varying, character varying, text[], numeric, character varying, character varying)

-- DROP FUNCTION opav.sl_cxp_aseguradoras(character varying, character varying, text[], numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sl_cxp_aseguradoras(num_factura character varying, num_contrato character varying, items_cxp text[], vlr_gastos numeric, codigo_imp character varying, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

recordCabecera record;
rs text :='OK';
numCxP varchar:= '';
total_iva numeric:=0;
total_factura numeric:=0;
vectorCuentas varchar[]='{}';
cmc_factura varchar:='' ;
recordDetalleCXP record;
recordIVACXP record;
items integer;
IdAseguradora varchar:='' ;
IdSolicitud varchar:='' ;
num_multiserv varchar:='' ;
grupoTransaccion integer:=0;

BEGIN

       --VALIDAMOS EL PERFIL CONTABLE PARA CREAR LA CXP DE LA ASEGURADORA--
        IF(opav.sl_validacion_cuentas('CXP_ASEGURADORA'))THEN

		vectorCuentas:=opav.sl_get_cuentas_perfil('CXP_ASEGURADORA');
		RAISE NOTICE 'CUENTA DETALLE :vectorCuentas[2]: %', vectorCuentas[2] ;
		SELECT INTO cmc_factura  cmc FROM con.cmc_doc WHERE tipodoc='FAP' AND cuenta=vectorCuentas[1] ;
		SELECT INTO IdSolicitud  id_solicitud FROM opav.sl_minutas WHERE numero_contrato=num_contrato;
                SELECT INTO num_multiserv  coalesce(num_os,'') FROM opav.ofertas WHERE id_solicitud=IdSolicitud;
		--OBTENEMOS RECORD CON BASE EN CONCEPTO
		SELECT INTO recordIVACXP codigo_impuesto, tipo_impuesto, concepto, porcentaje1::numeric, cod_cuenta_contable FROM tipo_de_impuesto
					WHERE codigo_impuesto = codigo_imp and fecha_vigencia > substring(now()::date,0,11)  	GROUP BY codigo_impuesto, tipo_impuesto, concepto, porcentaje1, cod_cuenta_contable;

		--1.)CABECERA DE LA CUENTA POR COBRAR.
			SELECT INTO recordCabecera
			       'FINV'::VARCHAR as distrito,
				a.nit as proveedor,
				'FAP'::VARCHAR as tipo_doc,
				'CXP ASEGURADORA '||nombre_seguro as descripcion,
				'OP'::VARCHAR as agencia,
				cmc_factura::VARCHAR as handle_code,--FALTA EL HC
				(select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO')as aprobador,
				'BANCOLOMBIA'::VARCHAR as banco,
				'CC'::VARCHAR as sucursal,
				'PES'::VARCHAR as moneda,
				0::numeric as vlr_neto,
				1.0000000000::numeric as tasa
			FROM opav.sl_garantias_aseguradora ga
                        INNER JOIN administrativo.aseguradora a ON a.id = ga.id_aseguradora
			INNER JOIN opav.sl_minutas co ON co.numero_contrato = ga.id_contrato
			/*INNER JOIN opav.sl_rel_minutas_broker relbr ON relbr.id_contrato = ga.id_contrato
			INNER JOIN opav.sl_broker br ON br.id = relbr.id_broker*/
			--LEFT JOIN opav.sl_garantias_otros_costos goc on goc.id_contrato = co.numero_contrato AND goc.id_aseguradora = ga.id_aseguradora
			WHERE ga.id_contrato = num_contrato
			AND ga.id = ANY (items_cxp::int[])
			GROUP BY ga.id_aseguradora,a.nit,nombre_seguro;
			IF(FOUND)THEN
				numCxP :=num_factura;
				--1.1)CABECERA CXP
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
					    recordCabecera.agencia, recordCabecera.handle_code, '', 'SOLICITUD', IdSolicitud,
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
					    'SOL', IdSolicitud,'','',
					    '','', 'N', 'N',
					    'N');

					--1.2) CABECERA IMPUESTOS
					INSERT INTO fin.cxp_imp_doc (reg_status, dstrct, proveedor, tipo_documento, documento, cod_impuesto, porcent_impuesto, vlr_total_impuesto,
					vlr_total_impuesto_me, creation_date, creation_user, base)
					VALUES('', 'FINV', recordCabecera.proveedor, 'FAP', numCxP, recordIVACXP.codigo_impuesto, recordIVACXP.porcentaje1, 0, 0, NOW(),usuario, 'COL');


				--2.)DETALLE DE LA CXP
				SELECT INTO IdAseguradora id_aseguradora FROM opav.sl_garantias_aseguradora WHERE id_contrato = num_contrato AND cotiz_broker_aceptada = 'S' GROUP BY id_aseguradora;
			        raise notice 'Id Aseguradora %', IdAseguradora;
				items :=1;
				FOR recordDetalleCXP in (SELECT
							        ''::VARCHAR AS planilla,
								'FINV'::VARCHAR as distrito,
								a.nit as proveedor,
								'FAP'::VARCHAR as tipo_doc,
								nombre_poliza as descripcion,
								'OP'::VARCHAR as agencia,
								(select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO')as aprobador,
								'BANCOLOMBIA'::VARCHAR as banco,
								'CC'::VARCHAR as sucursal,
								'PES'::VARCHAR as moneda,
                                                                round(sum(valor_aseguradora)) as vlr_neto,
                                                                round(sum(valor_aseguradora)*recordIVACXP.porcentaje1/100)::numeric as vlr_iva,
								1.0000000000::numeric as tasa
							 FROM opav.sl_garantias_aseguradora ga
							 INNER JOIN administrativo.aseguradora a ON a.id = ga.id_aseguradora
							 INNER JOIN opav.sl_minutas co ON co.numero_contrato = ga.id_contrato
                                                         INNER JOIN opav.sl_minutas_garantias mg ON mg.id_contrato = ga.id_contrato AND mg.id = ga.id_garantia
                                                         AND mg.id_beneficiario = ga.id_beneficiario AND mg.secuencia_otro_si = ga.secuencia_otro_si
                                                         INNER JOIN administrativo.polizas p ON p.id = mg.id_poliza
							 WHERE
							 ga.id_contrato = num_contrato
							 AND ga.id = ANY (items_cxp::int[])
							 GROUP BY
							 ga.id_garantia,
							 ga.id_aseguradora,
							 a.nit,
                                                         nombre_poliza,
							 nombre_seguro
							)

				LOOP
					raise notice 'detalle cxp %', items;
					raise notice 'detalle vlr_neto %',  recordDetalleCXP.vlr_neto;
					raise notice 'detalle vlr_iva %',  recordDetalleCXP.vlr_iva;
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
					    '','','', '','SOL',
					    IdSolicitud, 'FOMS', num_multiserv, 'POLIZ',
					    recordDetalleCXP.descripcion);

					--3.) INSERTAMOS EN DETALLE DE IMPUESTOS

					--3.1) DETALLE IMPUESTOS
					INSERT INTO fin.cxp_imp_item (reg_status, dstrct, proveedor, tipo_documento, documento, item, cod_impuesto, porcent_impuesto, vlr_total_impuesto,
					vlr_total_impuesto_me, creation_date, creation_user, base)
					VALUES('', 'FINV', recordDetalleCXP.proveedor, 'FAP', numCxP, lpad(items, 3, '0'), recordIVACXP.codigo_impuesto,  recordIVACXP.porcentaje1,
					recordDetalleCXP.vlr_iva, recordDetalleCXP.vlr_iva, NOW(),usuario, 'COL');

                                        --ACTUALIZAMOS TOTALES DE FACTURA E IVA
                                        total_factura :=  total_factura + recordDetalleCXP.vlr_neto + recordDetalleCXP.vlr_iva;
                                        total_iva :=  total_iva + recordDetalleCXP.vlr_iva;
					items := items+1 ;

				END LOOP;

                                --4.)SI HAY OTROS GASTOS SE INSERTA EN TABLA DETALLE CXP Y TABLA DE IMPUESTOS
				IF vlr_gastos > 0 THEN
				        raise notice 'Valor Gastos %', vlr_gastos;
				        --4.1) DETALLE CXP
                                        INSERT INTO fin.cxp_items_doc(
					    reg_status, dstrct, proveedor, tipo_documento, documento, item,
					    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
					    last_update, user_update, creation_date, creation_user, base,
					    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
					    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
					    referencia_3)
					VALUES('', 'FINV', recordDetalleCXP.proveedor, recordDetalleCXP.tipo_doc, numCxP,lpad(items, 3, '0'),
					    'GASTOS DE EXPEDICIÓN PÓLIZA',  vlr_gastos,  vlr_gastos, vectorCuentas[2], '', recordDetalleCXP.planilla,
					    '0099-01-01 00:00:00'::timestamp, '', NOW(), usuario, 'COL',
					    '','','', '','SOL',
					    IdSolicitud, 'FOMS', num_multiserv,'POLIZ',
					    'GASTOS DE EXPEDICIÓN PÓLIZA');

					--4.2) DETALLE IMPUESTOS
					INSERT INTO fin.cxp_imp_item (reg_status, dstrct, proveedor, tipo_documento, documento, item, cod_impuesto, porcent_impuesto, vlr_total_impuesto,
					vlr_total_impuesto_me, creation_date, creation_user, base)
					VALUES('', 'FINV', recordDetalleCXP.proveedor, 'FAP', numCxP, lpad(items, 3, '0'), recordIVACXP.codigo_impuesto,  recordIVACXP.porcentaje1,
					round(vlr_gastos*recordIVACXP.porcentaje1/100), round(vlr_gastos*recordIVACXP.porcentaje1/100), NOW(),usuario, 'COL');

					 --ACTUALIZAMOS TOTALES DE FACTURA E IVA
                                        total_factura := total_factura + round(vlr_gastos) + round((vlr_gastos*recordIVACXP.porcentaje1/100));
                                        total_iva := total_iva + round(vlr_gastos*recordIVACXP.porcentaje1/100);
			        END IF;
                                raise notice 'Total Factura %', total_factura;
			        raise notice 'Total IVA %', total_iva;
			        --5.) ACTUALIZAMOS TOTAL CABECERA CXP ASEGURADORA

					UPDATE fin.cxp_doc
					   SET
					    vlr_neto=total_factura,
					    vlr_saldo=total_factura,
					    vlr_neto_me=total_factura,
					    vlr_saldo_me=total_factura
					 WHERE
					 documento = numCxP;

				--5.) ACTUALIZAMOS TOTAL CABECERA IMPUESTOS

					UPDATE fin.cxp_imp_doc
					   SET
                                            vlr_total_impuesto = total_iva,
					    vlr_total_impuesto_me = total_iva
					 WHERE
					 documento = numCxP;



				--7.) ACTUALIZAMOS ITEMS TABLA GARANTIAS ASEGURADORA

					UPDATE opav.sl_garantias_aseguradora
					   SET
					   last_update=NOW(),
					   user_update=usuario,
					   cxp_generada='S',
					   cxp_aseguradora = numCxP
					 WHERE
					 id = ANY (items_cxp::int[]);

                                --8.) ACTUALIZAMOS CAMPO CXP CONTRATO SI YA SE GENERARON TODAS LAS POLIZAS
                                PERFORM id FROM opav.sl_garantias_aseguradora WHERE id_contrato = num_contrato AND id_aseguradora = IdAseguradora AND cxp_generada = 'N';
			        IF NOT FOUND THEN
                                     UPDATE opav.sl_minutas set cxp_aseguradora = 'S' WHERE numero_contrato = num_contrato;
			        END IF;

				/*--4.) ACTUALIZAMOS TABLA CONTRATOS CON EL NUMERO DE LA CXP

					UPDATE opav.sl_minutas
					   SET
					   last_update=NOW(),
					   user_update=usuario,
					   cxp_aseguradora=numCxP
					 WHERE
					  numero_contrato=num_contrato
					  AND cxp_aseguradora='';

				*/


			ELSE
			  rs:='ERROR';
			END IF;
	ELSE
	  rs:='ERROR';
	END IF;

	RETURN 	 rs||';'||numCxP||';'||total_factura;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_cxp_aseguradoras(character varying, character varying, text[], numeric, character varying, character varying)
  OWNER TO postgres;
