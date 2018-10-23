-- Function: dv_desembolsodeduccionesreliquidacion(character varying, integer, numeric, numeric, numeric, numeric)

-- DROP FUNCTION dv_desembolsodeduccionesreliquidacion(character varying, integer, numeric, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION dv_desembolsodeduccionesreliquidacion(_compracartera character varying, _ocupacion integer, _desembolsocliente numeric, _vlrobligacionescompradas numeric, _cantdeducciones numeric, _plazo numeric)
  RETURNS text AS
$BODY$

DECLARE

	_Decision TEXT := 'OK';

	TipoOperacionLibranza record;
	OperacionLibranza record;
	Deducciones record;

	_NewSaldoCliente numeric := 0;
	_SaldoConDeducciones numeric := 0;
	RsValoresFianza record;


BEGIN

	-- select * from tipo_operacion_libranza
	-- select * from operaciones_libranza
	-- select * from deducciones_libranza;


	SELECT INTO RsValoresFianza id_unidad_negocio,CASE WHEN porcentaje_comision > 0 THEN round((_desembolsocliente*porcentaje_comision/100)*(1+porcentaje_iva/100))
		    ELSE round((_plazo::int*_desembolsocliente*valor_comision/1000000)*(1+porcentaje_iva/100)) END AS valor_fianza,
		    CASE WHEN porcentaje_comision > 0 THEN round((_desembolsocliente*porcentaje_comision/100)*(porcentaje_iva/100))
		    ELSE round((_plazo::int*_desembolsocliente*valor_comision/1000000)*(porcentaje_iva/100)) END AS valor_iva_fianza
		    FROM configuracion_factor_por_millon cf
		    WHERE id_unidad_negocio = 22
		    AND _plazo::int BETWEEN plazo_inicial AND plazo_final;

	_NewSaldoCliente = _DesembolsoCliente - RsValoresFianza.valor_fianza;

	--DEDUCCION GENERAL
	FOR OperacionLibranza IN

		select * from operaciones_libranza

	LOOP

		if ( OperacionLibranza.id_tipo_operacion_libranza = 2) then

			raise notice 'Ocupacion: %, OperacionLibranza: %', _Ocupacion, OperacionLibranza.id;

			FOR Deducciones IN

				select *
				from deducciones_libranza
				where _DesembolsoCliente between desembolso_inicial and desembolso_final
				      --1000000 between desembolso_inicial and desembolso_final
				      --and id_ocupacion_laboral = 1 and id_operacion_libranza = 3;
				      and id_ocupacion_laboral = _Ocupacion
				      and id_operacion_libranza = OperacionLibranza.id

			LOOP

				if ( Deducciones.valor_cobrar != 0 ) then
					_NewSaldoCliente = _NewSaldoCliente - Deducciones.valor_cobrar;
					raise notice '_Desembolso: %, valor_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.valor_cobrar, Deducciones.valor_cobrar;
				end if;

				if ( Deducciones.perc_cobrar != 0 ) then
					_NewSaldoCliente = _NewSaldoCliente - (_DesembolsoCliente * (Deducciones.perc_cobrar/100));
					raise notice '_Desembolso: %, perc_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.perc_cobrar, (_DesembolsoCliente * (Deducciones.perc_cobrar/100));
				end if;

				if ( Deducciones.n_xmil != 0 ) then
					_NewSaldoCliente = _NewSaldoCliente - ((_DesembolsoCliente/1000)*Deducciones.n_xmil);
					raise notice '_Desembolso: %, n_xmil: %, Resultado: %', _DesembolsoCliente, Deducciones.n_xmil, ((_DesembolsoCliente/1000)*Deducciones.n_xmil);
				end if;

				_SaldoConDeducciones = _NewSaldoCliente;
				raise notice '_NewSaldoCliente: %', _NewSaldoCliente;

			END LOOP;

		end if;

	END LOOP;

	FOR Deducciones IN

			select *
			from deducciones_libranza
			where _DesembolsoCliente between desembolso_inicial and desembolso_final
			      and id_ocupacion_laboral = _Ocupacion
			      and id_operacion_libranza in (1,2)

		LOOP

			if ( Deducciones.valor_cobrar != 0 ) then
				_NewSaldoCliente = _NewSaldoCliente - Deducciones.valor_cobrar;
				raise notice '_Desembolso: %, valor_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.valor_cobrar, Deducciones.valor_cobrar;
			end if;

			if ( Deducciones.perc_cobrar != 0 ) then
				_NewSaldoCliente = _NewSaldoCliente - (_DesembolsoCliente * (Deducciones.perc_cobrar/100));
				raise notice '_Desembolso: %, perc_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.perc_cobrar, (_DesembolsoCliente * (Deducciones.perc_cobrar/100));
			end if;

			if ( Deducciones.n_xmil != 0 ) then
				_NewSaldoCliente = _NewSaldoCliente - ((_DesembolsoCliente/1000)*Deducciones.n_xmil);
				raise notice '_Desembolso: %, n_xmil: %, Resultado: %', _DesembolsoCliente, Deducciones.n_xmil, ((_DesembolsoCliente/1000)*Deducciones.n_xmil);
			end if;

			_SaldoConDeducciones = _NewSaldoCliente;
			raise notice '_NewSaldoCliente: %', _NewSaldoCliente;

	END LOOP;


	--OBLIGACIONES
	if ( _CantDeducciones > 0 ) then

		FOR i IN 1.._CantDeducciones LOOP

			FOR Deducciones IN

				select *
				from deducciones_libranza
				where _DesembolsoCliente between desembolso_inicial and desembolso_final
				      and id_ocupacion_laboral = _Ocupacion
				      and id_operacion_libranza = 2

			LOOP

				if ( Deducciones.valor_cobrar != 0 ) then
					_NewSaldoCliente = _NewSaldoCliente - Deducciones.valor_cobrar;
					raise notice '_Desembolso: %, valor_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.valor_cobrar, Deducciones.valor_cobrar;
				end if;

				if ( Deducciones.perc_cobrar != 0 ) then
					_NewSaldoCliente = _NewSaldoCliente - (_DesembolsoCliente * (Deducciones.perc_cobrar/100));
					raise notice '_Desembolso: %, perc_cobrar: %, Resultado: %', _DesembolsoCliente, Deducciones.perc_cobrar, (_DesembolsoCliente * (Deducciones.perc_cobrar/100));
				end if;

				if ( Deducciones.n_xmil != 0 ) then
					_NewSaldoCliente = _NewSaldoCliente - ((_DesembolsoCliente/1000)*Deducciones.n_xmil);
					raise notice '_Desembolso: %, n_xmil: %, Resultado: %', _DesembolsoCliente, Deducciones.n_xmil, ((_DesembolsoCliente/1000)*Deducciones.n_xmil);
				end if;

				_SaldoConDeducciones = _NewSaldoCliente;
				raise notice '_NewSaldoCliente: %', _NewSaldoCliente;

			END LOOP;

		END LOOP;

	end if;

	if ( _SaldoConDeducciones < _VlrObligacionesCompradas ) then
		_Decision = (_DesembolsoCliente - (_DesembolsoCliente - _SaldoConDeducciones))::numeric(11,0);
	end if;

	RETURN _Decision::varchar;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_desembolsodeduccionesreliquidacion(character varying, integer, numeric, numeric, numeric, numeric)
  OWNER TO postgres;
