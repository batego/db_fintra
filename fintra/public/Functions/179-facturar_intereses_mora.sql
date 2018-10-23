-- Function: facturar_intereses_mora(text, character varying)

-- DROP FUNCTION facturar_intereses_mora(text, character varying);

CREATE OR REPLACE FUNCTION facturar_intereses_mora(text, character varying)
  RETURNS text AS
$BODY$DECLARE
	_ints ALIAS FOR $1;
	_usuario ALIAS FOR $2;
	_respuesta 	TEXT;
	_consulta	TEXT;
	_consulta2	TEXT;
	_regs		RECORD;
	_regs2		RECORD;
	_numero_ing	CHARACTER VARYING;
	_cant_items	NUMERIC;
	_documento	TEXT;
	_nit		TEXT;
	_codcli		TEXT;
	_total		NUMERIC;
BEGIN
	_consulta:=    'SELECT fc.ref1 as multiservicio
			FROM intereses_mora_eca intm
				INNER JOIN con.factura fc ON(fc.documento=intm.documento)
			where interes_mora!=0 and id_int in ('||_ints||')
			group by ref1';
	_respuesta:='';
	FOR _regs IN EXECUTE (_consulta) LOOP
		_consulta2:=  'SELECT fc.nit,intm.id_int,intm.documento,intm.num_ingreso,intm.interes_mora,fc.codcli
			      FROM intereses_mora_eca intm
				INNER JOIN con.factura fc ON(fc.documento=intm.documento)
			      where interes_mora!=0 and ref1='''||_regs.multiservicio||'''and id_int in ('||_ints||')';
		select into _documento get_lcod('IMC');
		_cant_items:=0;
		_total:=0;
		FOR _regs2 IN EXECUTE (_consulta2) LOOP
			_cant_items:=_cant_items+1;
			_nit:=_regs2.nit;
			_codcli:=_regs2.codcli;
			_total:=_total+round(_regs2.interes_mora);
			INSERT INTO con.factura_detalle(
				    reg_status, dstrct, tipo_documento, documento, item, nit, concepto,
				    numero_remesa, descripcion, codigo_cuenta_contable, cantidad,
				    valor_unitario, valor_unitariome, valor_item, valor_itemme, valor_tasa,
				    moneda, last_update, user_update, creation_date, creation_user,
				    base, auxiliar, valor_ingreso, tipo_documento_rel, transaccion,
				    documento_relacionado, tipo_referencia_1, referencia_1, tipo_referencia_2,
				    referencia_2, tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV', 'FAC', _documento, _cant_items, _regs2.nit, 'IM',
				    '', 'INTERES POR MORA GENERADO POR LA CANCELACION DE LA FACTURA '||_regs2.documento||' CON LA NOTA '||_regs2.num_ingreso, '16252092', 1.0000,
				    round(_regs2.interes_mora), round(_regs2.interes_mora), round(_regs2.interes_mora), round(_regs2.interes_mora), '1.000000',
				    'PES', '0099-01-01 00:00:00', '', NOW(), _usuario,
				    '', '', 0.00, '', 0,
				    '', '', '', '',
				    '', '', '');
			UPDATE intereses_mora_eca intm set pagada='SI', last_update=NOW(), user_update=_usuario, factura_generada=_documento
			WHERE intm.id_int=_regs2.id_int;
		END LOOP;
		IF _cant_items>0 THEN
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
				    tipo_nc, numero_nc, factura_traslado)
			    VALUES ('', 'FINV', 'FAC', _documento, _nit, _codcli, 'IM',
				    NOW(), NOW()+'90 days'::interval, '0099-01-01 00:00:00', '0099-01-01 00:00:00',
				    'FACTURA DE INTERES DE MORA GENERADA POR PAGO DE EL MULTISERVICIO '||_regs.multiservicio, '', _total, 0, _total,
				    _total, 0, _total, 1.000000, 'PES',
				    _cant_items, 'CREDITO', 'OP', 'OP',
				    '', '', '', '', 0,
				    0, '0099-01-01 00:00:00', '0099-01-01 00:00:00',
				    '0099-01-01 00:00:00', 'COL', '0099-01-01 00:00:00', '',
				    NOW(), _usuario, '0099-01-01', 'S', '',
				    'IM', '', '', '', '', 0.000000,
				    '', 0, 0, '', '', '',
				    '', '', '', '', '',
				    '', 0, '0099-01-01 00:00:00',
				    '', '', '', '',
				    '', '', '', '', '0099-01-01 00:00:00',
				    '', '', '');
			_respuesta:=_respuesta||'Se genero la factura '||_documento||' por un valor de '||_total||e'\n';
		END IF;
	END LOOP;
RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION facturar_intereses_mora(text, character varying)
  OWNER TO postgres;
