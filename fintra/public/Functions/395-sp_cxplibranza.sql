-- Function: sp_cxplibranza(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION sp_cxplibranza(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_cxplibranza(_tipo_cxp character varying, _tipodoc character varying, _user character varying, _numcxp character varying, _numnc_cxp character varying, _cod_cli character varying, _nombre character varying, _cod_neg character varying, _vlrdesembolsowdesc numeric, _item character varying, _cuenta_cab character varying, _cuenta_detalle character varying, _descripcioncabecera character varying, _descripciondetalle character varying)
  RETURNS text AS
$BODY$

DECLARE

	cxp_tercero_find record;
	_respuesta varchar := '';
	tipo_ref2  varchar := '';
	ref2  varchar := '';

	grupoTransaccion integer := 0;

BEGIN

	if ( _tipo_cxp = 'CHEQUE' ) then tipo_ref2 = 'REL'; ref2 = _numNC_CxP; end if;

	IF ( _TipoDoc = 'FAP' ) THEN

		raise notice 'FAP ES: si entra %',_numCxP;

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
		    VALUES ('', 'FINV', _cod_cli,  _TipoDoc, _numCxP, _descripcionCabecera||_nombre,
			    'OP', _cuenta_cab, '', 'NEG', _cod_neg,
			    '0099-01-01 00:00:00'::timestamp, 'JGOMEZ', '', 'BANCOLOMBIA', 'CA',
			    'PES', _VlrDesembolsoWdesc, 0,  _VlrDesembolsoWdesc,  _VlrDesembolsoWdesc, 0,
			     _VlrDesembolsoWdesc,  1, '', '0099-01-01 00:00:00'::timestamp,
			    '',  '0099-01-01 00:00:00'::timestamp,  '0099-01-01 00:00:00'::timestamp,
			    '', 0, 0, 0,
			    '0099-01-01 00:00:00'::timestamp, '', NOW(), _User, 'COL',
			    '', '', '', '0099-01-01 00:00:00'::timestamp, '0099-01-01 00:00:00'::timestamp,
			    '0099-01-01 00:00:00'::timestamp, '', '', '',
			    '', 0, 0, '',
			    0, 'PES', NOW()::date,NOW()::date,
			     '0099-01-01 00:00:00'::timestamp, 'S', 0, 'N', 'NEG',
			    '', '',tipo_ref2,ref2,
			    'DESEM', _tipo_cxp, 'N', 'N');

		IF FOUND THEN

			INSERT INTO fin.cxp_items_doc(
			    reg_status, dstrct, proveedor, tipo_documento, documento, item,
			    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
			    last_update, user_update, creation_date, creation_user, base,
			    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
			    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
			    referencia_3)
			VALUES ('', 'FINV', _cod_cli, _TipoDoc, _numCxP, _item,
			    _descripcionDetalle||_cod_cli,  _VlrDesembolsoWdesc,  _VlrDesembolsoWdesc, _cuenta_detalle, '', _cod_neg,
			    '0099-01-01 00:00:00'::timestamp, '', NOW(), _User, 'COL',
			    '','','', 'AR-'||_cod_cli,'',
			    '', '', '', '',
			    '');

			/*-------------------------------
			--CONTABILIZAR CXP TRANFERENCIA--
			-------------------------------*/
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
				replace(substring(now(),1,7),'-','') as periodo,
				now()::date as fechadoc,
				'CONTABILIZACION CXP TRANSFERENCIA'::text as detalle,
				proveedor as tercero,
				vlr_neto as valor_debito,
				vlr_neto as valor_credito,
				(SELECT (COUNT(0)+1)::INTEGER FROM fin.cxp_items_doc WHERE documento = fin.cxp_doc.documento) as total_items,
				moneda_banco as moneda,
				'0099-01-01 00:00:00'::timestamp as fecha_aplicacion,
				_User::text as aprobador,
				'0099-01-01 00:00:00'::timestamp as last_update,
				''::text as user_update,
				now() as creation_date,
				_User as creation_user,
				'COL'::text as base,
				_User as usuario_aplicacion,
				'002'::text as tipo_operacion,
				''::text as moneda_foranea,
				0.00::numeric as vlr_for,
				''::text as ref_1,
				''::text as ref_2
			FROM fin.cxp_doc
			WHERE documento = _numCxP AND tipo_documento='FAP';

			--1) DETALLE CREDITO DE LA CXP

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
				'23050941' as codigo_cuenta,
				'AR-'||proveedor::text as auxiliar,
				'CONTABILIZACION CXP TRANSFERENCIA'::text as detalle,
				0.0::numeric as valor_debito,
				sum(vlr) as valor_credito,
				proveedor as tercero,
				documento as documento_interno,
				'0099-01-01 00:00:00'::timestamp as last_update,
				''::text as user_update,
				now() as creation_date,
				_User as creation_user,
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
			FROM fin.cxp_items_doc  WHERE  documento = _numCxP AND tipo_documento='FAP'
			GROUP BY reg_status,
				dstrct,
				documento,
				codigo_cuenta,
				proveedor,
				tipo_documento;

			--2) DETALLE DEBITO DE LA CXP

			SELECT INTO cxp_tercero_find * FROM fin.cxp_doc WHERE documento_relacionado = _cod_neg and referencia_3 = 'TRANSFERENCIA';

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
				'CONTABILIZACION CXP TRANSFERENCIA'::text as detalle,
				vlr as valor_debito,
				0.0::numeric as valor_credito,
				cxp_tercero_find.proveedor as tercero, --proveedor as tercero,
				documento as documento_interno,
				'0099-01-01 00:00:00'::timestamp as last_update,
				''::text as user_update,
				now() as creation_date,
				_User as creation_user,
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
			FROM fin.cxp_items_doc  WHERE documento = _numCxP AND tipo_documento='FAP';

			--3) MARCAMOS LA CXP COMO CONTABILIZADA
			UPDATE fin.cxp_doc
			SET fecha_contabilizacion = now(),
				usuario_contabilizo = _User,
				transaccion = grupoTransaccion,
				periodo = replace(substring(now(),1,7),'-',''),
				last_update = now(),
				user_update = _User
			WHERE documento = _numCxP and tipo_documento='FAP' ;

			_respuesta = _numCxP;

		END IF;

	END IF;
/*||*/
	IF ( _TipoDoc = 'NC' ) THEN
raise notice 'NC ES: %',_numNC_CxP;

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
		     SELECT reg_status, dstrct, _cod_cli, _TipoDoc::varchar AS tipo_documento, _numNC_CxP, _descripcionCabecera::varchar as descripcion,
			       agencia, handle_code, id_mims, tipo_documento as tipo_documento_rel, documento as documento_relacionado,
			       now() as fecha_aprobacion, (select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO') AS aprobador, (select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO') AS usuario_aprobacion, banco, sucursal,
			       moneda, _VlrDesembolsoWdesc::NUMERIC AS vlr_neto, 0.00 AS vlr_total_abonos, _VlrDesembolsoWdesc::NUMERIC AS vlr_saldo, _VlrDesembolsoWdesc::NUMERIC AS vlr_neto_me, 0.00 AS vlr_total_abonos_me,
			       _VlrDesembolsoWdesc::NUMERIC AS vlr_saldo_me, tasa,''::VARCHAR AS usuario_contabilizo, '0099-01-01 00:00:00'::timestamp AS fecha_contabilizacion,
			       ''::VARCHAR AS usuario_anulo, '0099-01-01 00:00:00'::timestamp AS fecha_anulacion, '0099-01-01 00:00:00'::timestamp AS fecha_contabilizacion_anulacion,
			       observacion, num_obs_autorizador, num_obs_pagador, num_obs_registra,
			       '0099-01-01 00:00:00'::timestamp AS last_update,''::VARCHAR AS user_update, NOW() AS  creation_date,creation_user, base,
			       ''::varchar as corrida, ''::varchar as cheque, ''::varchar as periodo, fecha_procesado, fecha_contabilizacion_ajc,
			       fecha_contabilizacion_ajv, periodo_ajc, periodo_ajv, usuario_contabilizo_ajc,
			       usuario_contabilizo_ajv, transaccion_ajc, transaccion_ajv, clase_documento,
			       0 as transaccion, moneda_banco, NOW()::date as fecha_documento,NOW()::date as fecha_vencimiento,
			       '0099-01-01'::date as ultima_fecha_pago, flujo, 0::integer as transaccion_anulacion, ret_pago, clase_documento_rel,
			       tipo_documento as tipo_referencia_1,documento as referencia_1, tipo_referencia_2, referencia_2,
			       tipo_referencia_3, referencia_3, indicador_traslado_fintra, factoring_formula_aplicada,
			       factura_tipo_nomina
		   FROM fin.cxp_doc
		   where documento = _numCxP and dstrct='FINV' And tipo_documento='FAP';
		   --

		IF FOUND THEN
		--raise notice 'NC ES: %',_numNC_CxP;
			--NC -> Detalle nota credito.
			INSERT INTO fin.cxp_items_doc(
				    reg_status, dstrct, proveedor, tipo_documento, documento, item,
				    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
				    last_update, user_update, creation_date, creation_user, base,
				    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
				    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
				    referencia_3)
			    select  reg_status, dstrct, _cod_cli, 'NC'::VARCHAR AS tipo_documento, _numNC_CxP as documento, _item::VARCHAR AS item,
					_descripcionDetalle::varchar AS descripcion, _VlrDesembolsoWdesc::NUMERIC AS vlr, _VlrDesembolsoWdesc::NUMERIC AS vlr_me, _cuenta_detalle::VARCHAR AS codigo_cuenta, codigo_abc, ''::VARCHAR AS planilla,
					'0099-01-01 00:00:00'::timestamp AS last_update, ''::VARCHAR AS user_update, NOW() AS creation_date, creation_user, base,
					codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
					referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
					referencia_3
				from fin.cxp_items_doc
				where documento = _numCxP and dstrct='FINV' And tipo_documento='FAP'
				GROUP BY
				reg_status, dstrct, _cod_cli,documento,codigo_abc,creation_user, base,
				codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
				referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
				referencia_3;

			/*-------------------------------
			--CONTABILIZAR CXP NOTA CREDITO--
			-------------------------------*/
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
				replace(substring(now(),1,7),'-','') as periodo,
				now()::date as fechadoc,
				'CONTABILIZACION CXP NOTA CREDITO'::text as detalle,
				proveedor as tercero,
				vlr_neto as valor_debito,
				vlr_neto as valor_credito,
				(SELECT (COUNT(0)+1)::INTEGER FROM fin.cxp_items_doc WHERE documento = fin.cxp_doc.documento) as total_items,
				moneda_banco as moneda,
				'0099-01-01 00:00:00'::timestamp as fecha_aplicacion,
				_User::text as aprobador,
				'0099-01-01 00:00:00'::timestamp as last_update,
				''::text as user_update,
				now() as creation_date,
				_User as creation_user,
				'COL'::text as base,
				_User as usuario_aplicacion,
				'002'::text as tipo_operacion,
				''::text as moneda_foranea,
				0.00::numeric as vlr_for,
				''::text as ref_1,
				''::text as ref_2
			FROM fin.cxp_doc
			WHERE documento = _numNC_CxP AND tipo_documento='NC';

			--1)DETALLE CREDITO DE LA CXP

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
				'23050941' as codigo_cuenta,
				'AR-'||proveedor::text as auxiliar,
				'CONTABILIZACION CXP NOTA CREDITO'::text as detalle,
				sum(vlr) as valor_debito,
				0.0::numeric as valor_credito,
				proveedor as tercero,
				documento as documento_interno,
				'0099-01-01 00:00:00'::timestamp as last_update,
				''::text as user_update,
				now() as creation_date,
				_User as creation_user,
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
			FROM fin.cxp_items_doc  WHERE  documento = _numNC_CxP AND tipo_documento='NC'
			GROUP BY reg_status,
				dstrct,
				documento,
				codigo_cuenta,
				proveedor,
				tipo_documento ;

			--2)DETALLE DEBITO DE LA CXP

			--SELECT INTO cxp_tercero_find * FROM fin.cxp_doc WHERE documento = _numCxP; | cxp_tercero_find.documento as tercero,

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
				'CONTABILIZACION CXP NOTA CREDITO'::text as detalle,
				0.0::numeric as valor_debito,
				vlr as valor_credito,
				proveedor as tercero,
				documento as documento_interno,
				'0099-01-01 00:00:00'::timestamp as last_update,
				''::text as user_update,
				now() as creation_date,
				_User as creation_user,
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
			FROM fin.cxp_items_doc  WHERE documento = _numNC_CxP AND tipo_documento='NC' ;

			--3 MARCAMOS LA CXP COMO CONTABILIZADA
			UPDATE fin.cxp_doc
			SET fecha_contabilizacion = now(),
				usuario_contabilizo = _User,
				transaccion = grupoTransaccion,
				periodo = replace(substring(now(),1,7),'-',''),
				last_update = now(),
				user_update = _User
			WHERE documento = _numNC_CxP and tipo_documento='NC' ;

			_respuesta = _numCxP;

		END IF;

	END IF;

	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cxplibranza(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
