-- Function: fn_liquidacion_libranza(character varying, numeric, integer, character varying, character varying, date, date)

-- DROP FUNCTION fn_liquidacion_libranza(character varying, numeric, integer, character varying, character varying, date, date);

CREATE OR REPLACE FUNCTION fn_liquidacion_libranza(_tipo_liquidacion character varying, _valor_desembolso numeric, _numero_cuotas integer, _idconvenio character varying, _tipo_cuota character varying, _fecha_calculo date, _fecha_primera_cuota date)
  RETURNS SETOF documentos_neg_aceptado AS
$BODY$
DECLARE
	_retorno documentos_neg_aceptado;
	_convenio RECORD;

	_dias INTEGER := 0;
	_dias_acomulados INTEGER = 0;

	_fecha_item DATE;
	_fecha_auxiliar DATE;

	_valor_auxiliar NUMERIC;
	_valor_total NUMERIC;

	_valor_inicial NUMERIC = _valor_desembolso;
	_capital NUMERIC;

	_fecha_calculo2 DATE;
	_fecha_primera_cuota2 DATE;

BEGIN

	--_fecha_calculo2 = '2016-03-31'::DATE;
	--_fecha_primera_cuota2 = '2016-05-10'::DATE;

	SELECT INTO _convenio
		--(tasa_interes / 100)::numeric(6,5) AS tasa_interes,
		--(POW(1 + (tasa_interes / 100), 12) - 1)::NUMERIC AS interes_efectivo_anual,
		seguro,
		--valor_seguro,
		(select prima from administrativo.temporary_seguro where _valor_desembolso between cobertura_rango_ini and cobertura_rango_fin) as valor_seguro,
		cuota_manejo,
		valor_cuota_manejo,
		(tasa/100)::NUMERIC AS interes_efectivo_anual,
		(tasa_mensual/100)::numeric(6,5) AS tasa_interes 
	FROM convenios
	inner join configuracion_libranza on (convenios.id_convenio = configuracion_libranza.id_convenio)
	WHERE convenios.id_convenio = _idconvenio;

	IF _tipo_liquidacion != 'PRINCIPAL' THEN
		_convenio.seguro = FALSE;
		_convenio.cuota_manejo = FALSE;
	END IF;

	IF _convenio.seguro = FALSE THEN
		_convenio.valor_seguro = 0;
	END IF;

	IF _convenio.cuota_manejo = FALSE THEN
		_convenio.valor_cuota_manejo = 0;
	END IF;

	RAISE NOTICE 'convenio: %', _convenio;

	IF _tipo_cuota = 'CTFCPV' THEN
		/* ** Valores Globales ** */
		--saldoinicial := capital;
		_valor_total = 0;

		FOR i IN 1 .. _numero_cuotas LOOP

			IF i = 1 THEN
				_fecha_item = _fecha_primera_cuota;
			ELSE
				_fecha_item = _fecha_item + INTERVAL '1 month';
			END IF;

			_dias = _fecha_item - _fecha_calculo;
			_valor_total = _valor_total + POW(1 + _convenio.interes_efectivo_anual, (-_dias / 360 ::numeric));

		END LOOP;

		/* ** periodo cero ** */
		_retorno.tipo = _tipo_liquidacion;
		_retorno.item = '0';
		_retorno.saldo_final = _valor_inicial;
		_retorno.fecha = _fecha_calculo;
		_retorno.seguro = 0;
		_retorno.capital = 0;
		_retorno.saldo_inicial = 0;
		_retorno.interes = 0;
		_retorno.cuota_manejo = 0;
		_retorno.dias = 0;
		_retorno.valor = 0;
		_retorno.capacitacion = 0;
		_retorno.cat = 0;

		RETURN NEXT _retorno;

		/* ** Calculos de las cuotas ** */
		_fecha_auxiliar = _fecha_calculo;

		FOR i IN 1 .. _numero_cuotas LOOP

			_retorno.tipo = _tipo_liquidacion;
			_retorno.item = i;

			_retorno.seguro = _convenio.valor_seguro;
			_retorno.cuota_manejo = _convenio.valor_cuota_manejo;

			IF i = 1 THEN
				_fecha_item = _fecha_primera_cuota;
			ELSE
				_fecha_item = _fecha_item + INTERVAL '1 month';
			END IF;

			_dias = _fecha_item - _fecha_auxiliar;
			_dias_acomulados = _dias_acomulados + _dias;
			_fecha_auxiliar = _fecha_item;

			_retorno.fecha = _fecha_item;
			_retorno.dias = _dias_acomulados;

			_retorno.saldo_inicial = _valor_inicial;
			_retorno.interes = ROUND(_valor_inicial * POW(1 + _convenio.interes_efectivo_anual, ( _dias / 360 ::numeric) ) - _valor_inicial);

			IF i = _numero_cuotas AND i != 1 THEN
				_retorno.capital = _valor_inicial;
			ELSE
				_retorno.capital = ROUND((_valor_desembolso / _valor_total) - _retorno.interes);
			END IF;

			_retorno.valor = (_valor_desembolso / _valor_total) + _retorno.seguro + _retorno.cuota_manejo;

			_retorno.saldo_final = _valor_inicial - _retorno.capital;
			_valor_inicial = _retorno.saldo_final;

			_retorno.capacitacion = 0;
			_retorno.cat = 0;

			RETURN NEXT _retorno;

		END LOOP;

	END IF;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fn_liquidacion_libranza(character varying, numeric, integer, character varying, character varying, date, date)
  OWNER TO postgres;
