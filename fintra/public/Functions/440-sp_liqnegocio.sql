-- Function: sp_liqnegocio(character varying, character varying)

-- DROP FUNCTION sp_liqnegocio(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_liqnegocio(_negocio character varying, usuario character varying)
  RETURNS SETOF documentos_neg_aceptado AS
$BODY$
DECLARE
	_retorno documentos_neg_aceptado;
	_BaseObligaciones RECORD;
	RsCliente record;

	_dias INTEGER := 0;
	_dias_acomulados INTEGER = 0;
	_numero_cuotas INTEGER = 0;

	_fecha_item DATE;
	_fecha_auxiliar DATE;
	miHoy date;

	_valor_auxiliar NUMERIC;
	_valor_total NUMERIC;

	_valor_inicial NUMERIC := 0;
	_capital NUMERIC;

	CXC_CompraCartera varchar := '';
	_PeriodoCte varchar := '';

BEGIN

	miHoy = now()::date;
	_PeriodoCte = replace(substring(miHoy,1,7),'-','')::varchar;

	SELECT INTO _BaseObligaciones nxl.*
	,(nxl.tasa / 100)::NUMERIC as tasa_interes
	,((1 - POW(1 + (nxl.tasa / 100), - nxl.plazo::int))/(nxl.tasa / 100))::NUMERIC AS interes_efectivo
	FROM administrativo.negocios_xliquidacion nxl
	WHERE cod_neg = _Negocio;

	IF FOUND THEN

		_valor_inicial = _BaseObligaciones.valor_aprobado::numeric;
		_numero_cuotas = _BaseObligaciones.plazo::int;

		/**  PERIODO CERO **/
		--_retorno.tipo = 'DESAPARECER'; --_tipo_liquidacion;
		_retorno.item = '0';
		_retorno.saldo_final = _valor_inicial;
		_retorno.fecha = _BaseObligaciones.fecha_consulta; --_fecha_calculo;
		_retorno.seguro = 0;
		_retorno.capital = 0;
		_retorno.saldo_inicial = 0;
		_retorno.interes = 0;
		--_retorno.cuota_manejo = 0;
		_retorno.dias = 0;
		_retorno.valor = 0;

		--RETURN NEXT _retorno;

		/** CALCULO DE CUOTAS **/
		_fecha_auxiliar =  _BaseObligaciones.fecha_consulta;

		FOR i IN 1 .. _numero_cuotas LOOP

			--_retorno.tipo = 'DESAPARECE';
			_retorno.item = i;

			_retorno.seguro = 0;
			--_retorno.cuota_manejo = 0;

			IF i = 1 THEN
				_fecha_item = _BaseObligaciones.fecha_primera_cuota::date;
			ELSE
				_fecha_item = _fecha_item + INTERVAL '1 month';
			END IF;

			_dias = _fecha_item - _fecha_auxiliar;
			_dias_acomulados = _dias_acomulados + _dias;
			_fecha_auxiliar = _fecha_item;

			_retorno.fecha = _fecha_item;
			_retorno.dias = _dias_acomulados;

			RAISE NOTICE 'valor: %', ROUND((_BaseObligaciones.valor_aprobado / _BaseObligaciones.interes_efectivo),2);
			_retorno.valor = ROUND((_BaseObligaciones.valor_aprobado / _BaseObligaciones.interes_efectivo),2);

			_retorno.saldo_inicial = _valor_inicial;

			RAISE NOTICE 'interes: %', ROUND((_BaseObligaciones.tasa_interes * _valor_inicial),2);
			_retorno.interes = ROUND((_BaseObligaciones.tasa_interes * _valor_inicial),2);

			IF i = _numero_cuotas AND i != 1 THEN
				_retorno.capital = _valor_inicial;
			ELSE
				_retorno.capital = ROUND((_retorno.valor - _retorno.interes),2);
			END IF;

			_retorno.valor = _retorno.valor;

			_retorno.saldo_final = _valor_inicial - _retorno.capital;
			_valor_inicial = _retorno.saldo_final;

			---------------------

			INSERT INTO documentos_neg_aceptado(
				    cod_neg, item, fecha, dias, saldo_inicial, capital, interes,
				    valor, saldo_final)
			    VALUES (_Negocio, _retorno.item, _retorno.fecha, _retorno.dias, _retorno.saldo_inicial, _retorno.capital, _retorno.interes,
				    _retorno.valor, _retorno.saldo_final);


			--Codigo Cliente
			SELECT INTO RsCliente * FROM cliente WHERE nit = (select identificacion::numeric from solicitud_persona where numero_solicitud = _BaseObligaciones.numero_solicitud and tipo = 'S');
			RAISE NOTICE 'cod_proveedor: %, RsCliente: %', RsCliente.codcli, RsCliente.codcli;

			IF FOUND THEN

				SELECT INTO CXC_CompraCartera administrativo.serie_cxc_compra_cartera();
				RAISE NOTICE 'CXC_CompraCartera: %', CXC_CompraCartera;

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
					    cmc, usuario_anulo, formato, agencia_impresion, periodo, valor_tasa_remesa, --1
					    negasoc, num_doc_fen, obs, pagado_fenalco, corficolombiana, tipo_ref1, --2
					    ref1, tipo_ref2, ref2, dstrct_ultimo_ingreso, tipo_documento_ultimo_ingreso, --3
					    num_ingreso_ultimo_ingreso, item_ultimo_ingreso, fec_envio_fiducia, --4
					    nit_enviado_fiducia, tipo_referencia_1, referencia_1, tipo_referencia_2, --5
					    referencia_2, tipo_referencia_3, referencia_3, nc_traslado, fecha_nc_traslado,
					    tipo_nc, numero_nc, factura_traslado, factoring_formula_aplicada,
					    nit_endoso, devuelta, fc_eca, fc_bonificacion, indicador_bonificacion,
					    fi_bonificacion, endoso_fenalco)
				    VALUES ('', 'FINV', 'FAC', CXC_CompraCartera, RsCliente.nit, RsCliente.codcli, 'CXC',
					    now()::date, _retorno.fecha::date, '0099-01-01', '0099-01-01 00:00:00',
					    'Estudiante UAC', '', _retorno.valor, 0.00, _retorno.valor,
					    _retorno.valor, 0.00, _retorno.valor, 1.000000, 'PES',
					    1, 'CREDITO', 'OP', 'OP',
					    '', '', '', '', 0,
					    0, '0099-01-01 00:00:00', '0099-01-01 00:00:00',
					    '0099-01-01 00:00:00', 'COL', '0099-01-01 00:00:00', '',
					    now(), Usuario, '0099-01-01', 'S', '',
					    'AU', '', '', 'OP', _PeriodoCte, 0.000000, --1
					    _Negocio, '0', '0', NULL, '', 'UAC', --2
					    '890103572', '', '', 'FINV', '', --3
					    '',1, '0099-01-01 00:00:00', --4
					    NULL, '', '', '', --5
					    '', '', '', 'N', '0099-01-01 00:00:00',
					    '', '', '', 'N',
					    '', '', '', '', '',
					    '', 'N');

				IF FOUND THEN

					--CAPITAL
					INSERT INTO con.factura_detalle(
						    reg_status, dstrct, tipo_documento, documento, item, nit, concepto,
						    numero_remesa, descripcion, codigo_cuenta_contable, cantidad,
						    valor_unitario, valor_unitariome, valor_item, valor_itemme, valor_tasa,
						    moneda, last_update, user_update, creation_date, creation_user,
						    base, auxiliar, valor_ingreso, tipo_documento_rel, transaccion,
						    documento_relacionado, tipo_referencia_1, referencia_1, tipo_referencia_2,
						    referencia_2, tipo_referencia_3, referencia_3)
					    VALUES ('', 'FINV', 'FAC', CXC_CompraCartera, 1, RsCliente.nit, '097',
						    '', 'CAPITAL', '13050920', 1.0000,
						    _retorno.capital, _retorno.capital, _retorno.capital, _retorno.capital, 1.000000,
						    'PES', '0099-01-01 00:00:00', '', now(), Usuario,
						    'COL', '890103572', _retorno.capital, '', 0,
						    '', '', '', '',
						    '', '', '');

					--INTERES
					INSERT INTO con.factura_detalle(
						    reg_status, dstrct, tipo_documento, documento, item, nit, concepto,
						    numero_remesa, descripcion, codigo_cuenta_contable, cantidad,
						    valor_unitario, valor_unitariome, valor_item, valor_itemme, valor_tasa,
						    moneda, last_update, user_update, creation_date, creation_user,
						    base, auxiliar, valor_ingreso, tipo_documento_rel, transaccion,
						    documento_relacionado, tipo_referencia_1, referencia_1, tipo_referencia_2,
						    referencia_2, tipo_referencia_3, referencia_3)
					    VALUES ('', 'FINV', 'FAC', CXC_CompraCartera, 2, RsCliente.nit, '097',
						    '', 'INTERES', '13050920', 1.0000,
						    _retorno.interes, _retorno.interes, _retorno.interes, _retorno.interes, 1.000000,
						    'PES', '0099-01-01 00:00:00', '', now(), Usuario,
						    'COL', '890103572', _retorno.interes, '', 0,
						    '', '', '', '',
						    '', '', '');

				END IF;

			END IF;

			--RETURN NEXT _retorno;


		END LOOP;

	END IF;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_liqnegocio(character varying, character varying)
  OWNER TO postgres;
