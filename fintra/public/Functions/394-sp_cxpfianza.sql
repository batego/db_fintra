-- Function: sp_cxpfianza(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION sp_cxpfianza(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_cxpfianza(_tipo_cxp character varying, _tipodoc character varying, _user character varying, _numcxp character varying, _numnc_cxp character varying, _cod_cli character varying, _nombre character varying, _cod_neg character varying, _vlrdesembolsowdesc numeric, _item character varying, _cuenta_cab character varying, _cuenta_detalle character varying, _descripcioncabecera character varying, _descripciondetalle character varying)
  RETURNS text AS
$BODY$

DECLARE

	cxp_tercero_find record;
	_respuesta varchar := '';
	tipo_ref2  varchar := '';
	ref2  varchar := '';

	grupoTransaccion integer := 0;

BEGIN

	IF ( _TipoDoc = 'FAP' ) THEN

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
			    'NEG', _cod_neg, '','',
			    '', '', 'N', 'N');

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
			    '','','', 'AR-'||_cod_cli,'NEG',
			    _cod_neg, '', '', '',
			    '');

			_respuesta = _numCxP;

		END IF;

	END IF;

	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cxpfianza(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
