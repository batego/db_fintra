-- Function: administrativo.cxp_fianza_definitiva(integer, character varying, character varying, text[], numeric, character varying, character varying)

-- DROP FUNCTION administrativo.cxp_fianza_definitiva(integer, character varying, character varying, text[], numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION administrativo.cxp_fianza_definitiva(_unidad_negocio integer, empresafianza character varying, periodo_corte character varying, items_cxp text[], vlr_cxp numeric, usuario character varying, _agencia character varying)
  RETURNS text AS
$BODY$
DECLARE

recordCabecera record;
rs text :='OK';
numCxP varchar:= '';
total_iva numeric:=0;
total_factura numeric:=0;
vectorCuentas varchar[]='{}';
vectorCuentasNC varchar[]='{}';
cmc_factura_cxp varchar:='' ;
cmc_factura_nc varchar:='' ;
recordDetalleCXP record;
recordProveedorCXP record;
items integer:=1;
grupoTransaccion integer:=0;
codigo_nc_fianza_temp varchar:='' ;
codigo_cxp_fianza_def varchar:='' ;
_idConvenio integer;

BEGIN

   IF (_unidad_negocio in (1,22)) THEN

	IF(_unidad_negocio = 1)THEN

	    codigo_nc_fianza_temp := 'NC_FIANZA_TEMP';
            codigo_cxp_fianza_def := 'CXP_FIANZA_DEF';

	   --VALIDAMOS LA AGENCIA
		IF(_agencia='ATL')THEN
		   _idConvenio:=10;
		ELSIF(_agencia='COR')THEN
		   _idConvenio:=43;
		END IF;

		IF(_agencia='SUC')THEN
		   _idConvenio:=49;
		END IF;
	ELSE

	    codigo_nc_fianza_temp := 'NC_FIANZA_LBT';
            codigo_cxp_fianza_def := 'CXP_FIANZA_LBD';

	     --VALIDAMOS LA AGENCIA
		IF(_agencia='ATL')THEN
		   _idConvenio:=38;
		END IF;


	END IF;

       --VALIDAMOS EL PERFIL CONTABLE PARA CREAR LA CXP DE FIANZA--
        IF(administrativo.validacion_cuentas(codigo_cxp_fianza_def) AND administrativo.validacion_cuentas(codigo_nc_fianza_temp))THEN

                vectorCuentasNC:=administrativo.get_cuentas_perfil(codigo_nc_fianza_temp,_idConvenio);
		vectorCuentas:=administrativo.get_cuentas_perfil(codigo_cxp_fianza_def,_idConvenio);
		RAISE NOTICE 'CUENTA DETALLE :vectorCuentas[2]: %', vectorCuentas[2] ;
		SELECT INTO cmc_factura_nc  cmc FROM con.cmc_doc WHERE tipodoc='NC' AND cuenta=vectorCuentasNC[1];
		SELECT INTO cmc_factura_cxp  cmc FROM con.cmc_doc WHERE tipodoc='FAP' AND cuenta=vectorCuentas[1];

		--OBTENEMOS INFORMACION DEL PROVEEDOR
		SELECT INTO recordProveedorCXP payment_name, branch_code, bank_account_no  FROM proveedor
		WHERE nit = empresaFianza;

                --1.) CABECERA DE LA NOTA CREDITO DE AJUSTE
                        INSERT INTO fin.cxp_doc

			select	'', 'FINV', cp.proveedor, 'NC', cp.documento, 'NC CANCELACION CXP TEMPORALES FIANZA A '||recordProveedorCXP.payment_name||' '||periodo_corte, cp.agencia, cmc_factura_nc, '', 'FAP', cp.documento, '0099-01-01 00:00:00',
				(select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO'), '', cp.banco, cp.sucursal, cp.moneda,
				cp.vlr_neto, cp.vlr_total_abonos,cp.vlr_saldo, cp.vlr_neto_me, cp.vlr_total_abonos_me,cp.vlr_saldo_me, 1.0000000000, '', '0099-01-01 00:00:00', '', '0099-01-01 00:00:00',
				 '0099-01-01 00:00:00', '', 0, 0, 0, NOW(), usuario, NOW(), usuario, 'COL', '', '', '',
				'0099-01-01 00:00:00', '0099-01-01 00:00:00', '0099-01-01 00:00:00', '', '', '', '', 0, 0, '', 0, 'PES', cp.fecha_documento, cp.fecha_documento, '0099-01-01', 'S', 0, 'N', '4',
				'FAP', cp.documento,'NEG', df.negocio,'',''
			FROM administrativo.historico_deducciones_fianza df
			LEFT JOIN fin.cxp_doc cp ON (cp.documento=df.documento_relacionado and cp.reg_status='' and cp.proveedor=df.nit_cliente  and cp.dstrct='FINV' and cp.tipo_documento='FAP')
			WHERE id = ANY (items_cxp::int[]) AND df.reg_status='';

                --1.1.)DETALLE DE LA NOTA CREDITO DE AJUSTE

			INSERT	INTO fin.cxp_items_doc

			select	'', 'FINV', cp.proveedor, 'NC', cp.documento, '001',
				'NOTA CREDITO QUE CANCELA CXP TEMPORAL FIANZA '||cp.documento,
                                cp.vlr_neto, cp.vlr_neto_me, vectorCuentasNC[2], '', '',
				NOW(), usuario, NOW(), usuario, 'COL', '','','','',
				'FAP', cp.documento,'NEG', df.negocio,'',''
			FROM administrativo.historico_deducciones_fianza df
			LEFT JOIN fin.cxp_doc cp ON (cp.documento=df.documento_relacionado and cp.reg_status='' and cp.proveedor=df.nit_cliente  and cp.dstrct='FINV' and cp.tipo_documento='FAP')
			WHERE id = ANY (items_cxp::int[]);

	        --2.) ACTUALIZAMOS CXP RELACIONADAS COLOCANDO SALDO EN CERO
	        UPDATE fin.cxp_doc SET vlr_total_abonos = vlr_neto, vlr_saldo = 0, vlr_total_abonos_me = vlr_neto_me, vlr_saldo_me = 0
		WHERE documento in(SELECT documento_relacionado FROM administrativo.historico_deducciones_fianza df
		WHERE id = ANY (items_cxp::int[])) and reg_status='' and dstrct='FINV' and tipo_documento='FAP';

                --3.)CUENTA POR PAGAR DEFINITIVA.
			SELECT INTO recordCabecera
			        'FINV'::VARCHAR as distrito,
				empresaFianza::VARCHAR  as proveedor,
				'FAP'::VARCHAR as tipo_doc,
				'CXP A '||recordProveedorCXP.payment_name||' '||periodo_corte as descripcion,
				'OP'::VARCHAR as agencia,
				cmc_factura_cxp::VARCHAR as handle_code,--FALTA EL HC
				(select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO')as aprobador,
				recordProveedorCXP.branch_code::VARCHAR as banco,
				recordProveedorCXP.bank_account_no::VARCHAR as sucursal,
				'PES'::VARCHAR as moneda,
				0::numeric as vlr_neto,
				1.0000000000::numeric as tasa;
			IF(FOUND)THEN
                               IF(_unidad_negocio = 1) THEN
                                     SELECT INTO numCxP get_lcod_fianza(codigo_cxp_fianza_def);
                               ELSE
                                      SELECT INTO numCxP get_lcod_fianza_libranza(codigo_cxp_fianza_def);
                               END IF;

				--3.1)CABECERA CXP DEFINITIVA
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
				        VALUES ('', 'FINV', recordCabecera.proveedor, recordCabecera.tipo_doc, numCxP, recordCabecera.descripcion,
					    recordCabecera.agencia, recordCabecera.handle_code, '', '', '',
					    '0099-01-01 00:00:00'::timestamp, recordCabecera.aprobador, '', recordCabecera.banco, recordCabecera.sucursal,
					    'PES', recordCabecera.vlr_neto, 0,  recordCabecera.vlr_neto, recordCabecera.vlr_neto, 0,
					     recordCabecera.vlr_neto,  1, '', '0099-01-01 00:00:00'::timestamp,
					    '',  '0099-01-01 00:00:00'::timestamp,  '0099-01-01 00:00:00'::timestamp,
					    '', 0, 0, 0,
					    '0099-01-01 00:00:00'::timestamp, '', NOW(), usuario, 'COL',
					    '', '', '', '0099-01-01 00:00:00'::timestamp, '0099-01-01 00:00:00'::timestamp,
					    '0099-01-01 00:00:00'::timestamp, '', '', '',
					    '', 0, 0, '4',
					    0, recordCabecera.moneda, NOW()::date,(NOW() + '8 day')::date,
					     '0099-01-01 00:00:00'::timestamp, 'S', 0, 'N', '4',
					    '', '','','',
					    '','', 'N', 'N',
					    'N');


				        --4) DETALLE CXP DEFINITIVA
                                        items :=1;
					FOR recordDetalleCXP in (SELECT
									''::VARCHAR AS planilla,
									'FINV'::VARCHAR as distrito,
									empresaFianza as proveedor,
									'FAP'::VARCHAR as tipo_doc,
									'' as descripcion,
									'OP'::VARCHAR as agencia,
									(select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO')as aprobador,
									recordProveedorCXP.branch_code::VARCHAR as banco,
									recordProveedorCXP.bank_account_no::VARCHAR as sucursal,
									'PES'::VARCHAR as moneda,
									valor_fianza::numeric as vlr_neto,
									1.0000000000::numeric as tasa,
									'FAP'::VARCHAR as tipo_referencia_1,
									cp.documento::VARCHAR as referencia_1,
									'NEG'::VARCHAR as tipo_referencia_2,
									df.negocio::VARCHAR as referencia_2,
									''::VARCHAR as tipo_referencia_3,
									''::VARCHAR as referencia_3
								FROM administrativo.historico_deducciones_fianza df
								LEFT JOIN fin.cxp_doc cp ON (cp.documento=df.documento_relacionado and cp.reg_status='' and cp.proveedor=df.nit_cliente and cp.dstrct='FINV' and cp.tipo_documento='FAP')
								WHERE id = ANY (items_cxp::int[]))

					LOOP
					        raise notice 'recordDetalleCXP.referencia_1: %',recordDetalleCXP.referencia_1;
					       --4.1) INSERTAMOS EN DETALLE DE CXP
						INSERT INTO fin.cxp_items_doc(
						    reg_status, dstrct, proveedor, tipo_documento, documento, item,
						    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
						    last_update, user_update, creation_date, creation_user, base,
						    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
						    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
						    referencia_3)
						VALUES('', 'FINV', recordDetalleCXP.proveedor, recordDetalleCXP.tipo_doc, numCxP,lpad(items, 3, '0'),
						    'CXP A '||recordProveedorCXP.payment_name,  recordDetalleCXP.vlr_neto,  recordDetalleCXP.vlr_neto, vectorCuentas[2], '','',
						    '0099-01-01 00:00:00'::timestamp, '', NOW(), usuario, 'COL',
						    '','','', '', recordDetalleCXP.tipo_referencia_1,
						    recordDetalleCXP.referencia_1, recordDetalleCXP.tipo_referencia_2,recordDetalleCXP.referencia_2,'', '');

						total_factura :=  total_factura + recordDetalleCXP.vlr_neto;
						items := items+1;
					END LOOP;

			        --5.) ACTUALIZAMOS TOTAL CABECERA CXP DEFINITIVA

					UPDATE fin.cxp_doc
					   SET
					    vlr_neto=(SELECT sum(vlr) FROM fin.cxp_items_doc  where documento=numCxP and tipo_documento='FAP'), --total_factura,
					    vlr_saldo=(SELECT sum(vlr) FROM fin.cxp_items_doc  where documento=numCxP and tipo_documento='FAP'),--total_factura,
					    vlr_neto_me=(SELECT sum(vlr) FROM fin.cxp_items_doc  where documento=numCxP and tipo_documento='FAP'),--total_factura,
					    vlr_saldo_me=(SELECT sum(vlr) FROM fin.cxp_items_doc  where documento=numCxP and tipo_documento='FAP')--total_factura
					 WHERE
					 documento = numCxP;

				--6.) ACTUALIZAMOS ITEMS TABLA DE CONTROL

					UPDATE administrativo.historico_deducciones_fianza
					   SET
					   last_update=NOW(),
					   user_update=usuario,
					   documento_cxp=numCxP,
					   estado_proceso = 'P'
					 WHERE
					 id = ANY (items_cxp::int[]);


			ELSE
			  rs:='ERROR';
			END IF;
	ELSE
	  rs:='ERROR';
	END IF;

ELSE
	  rs:='ERROR';
END IF;

	RETURN 	 rs||';'||numCxP||';'||vlr_cxp;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.cxp_fianza_definitiva(integer, character varying, character varying, text[], numeric, character varying, character varying)
  OWNER TO postgres;
