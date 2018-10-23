-- Function: apicredit.sp_scorehdc2(integer, character varying)

-- DROP FUNCTION apicredit.sp_scorehdc2(integer, character varying);

CREATE OR REPLACE FUNCTION apicredit.sp_scorehdc2(_numero_solicitud integer, _huella character varying)
  RETURNS text AS
$BODY$

DECLARE

	--respuesta varchar := 'R';
	respuesta varchar := '{"respuesta":"R","valor":"0"}';
	NitEmpresaConsultora varchar := '';
	_RtAccion varchar := '';

	vble_mercado_buro record;
	RsPuntajes record;
	RsPresolicitudes record;
	RsCalificacion record;
	RsCalcUtilizacion record;
	EndeudamientoHDC record;
	RsReliquidacion record;
	--ConfirmarHDC record;

	CtasAhorro numeric := 0;
	PuntajeMax numeric := 0;
	TiempoTranscurrido numeric := 0;
	MoraMaxGen numeric := 0;
	MoraMaxTDC numeric := 0;
	AntiguedadTDC numeric := 0;
	TotalSaldoMora numeric := 0;
	CalculoUtilizacion numeric := 0;
	ObligacionesAldia numeric := 0;
	MaxObligaciones numeric := 0;
	MorasAldia numeric := 0;
	ObligacionesRecuperadas numeric := 0;
	MoraMax6 numeric := 0;
	MoraMax12 numeric := 0;
	CuentaMaxMora numeric := 0;
	PorcEndeudamiento numeric := 0;
	GastosPersonales numeric := 0;
	EndeudamMasCuota numeric := 0;
	Endeudamiar numeric := 0;
	EndeudamSinCuota numeric := 0;
	MontoEndeudamiento numeric := 0;
	MontoSugerido numeric := 0;
	CuotaSugerida numeric := 0;
	PercEquivalencia numeric := 0;
	GastGeneral numeric := 0.40;
	PercPolitica numeric := 89.99;
	TotalCtaFintra numeric := 0;

	ConfirmarHDC integer;


BEGIN

	/*
	select * from apicredit.pre_solicitudes_creditos order by creation_date --where numero_solicitud = 81815 identificacion = '72252911'
	select * from apicredit.harold where identificacion = '72252911' and id != 16

	INSERT INTO apicredit.pre_solicitudes_creditos(
		    dstrct, reg_status, numero_solicitud, producto, entidad,
		    afiliado, valor_cuota, valor_aval, fecha_credito, monto_credito,
		    numero_cuotas, fecha_pago, tipo_identificacion, identificacion,
		    fecha_expedicion, primer_nombre, primer_apellido, fecha_nacimiento,
		    email, ingresos_usuario, id_convenio, estado_sol, codigorespuesta,
		    score, clasificacion, comentario, empresa, etapa, creation_date,
		    creation_user, last_update, user_update)
	select
		dstrct, reg_status, numero_solicitud, producto, entidad,
		afiliado, valor_cuota, valor_aval, fecha_credito, monto_credito,
		numero_cuotas, fecha_pago, tipo_identificacion, identificacion,
		fecha_expedicion, primer_nombre, primer_apellido, fecha_nacimiento,
		email, ingresos_usuario, id_convenio, estado_sol, codigorespuesta,
		score, clasificacion, comentario, empresa, etapa, creation_date,
		creation_user, last_update, user_update
	from apicredit.harold where identificacion = '72252911'
	*/

	IF ( _huella = 'FENALCO_BOL' ) THEN
		NitEmpresaConsultora = '8904800244';
	ELSIF ( _huella = 'FENALCO_ATL' ) THEN
		NitEmpresaConsultora = '8901009858';
	ELSE
		NitEmpresaConsultora = '8020220161';
	END IF;

	select into RsPuntajes un.puntaje_maximo_buro, un.minimo_buro, un.maximo_buro, un.cutoff_buro
	from rel_unidadnegocio_convenios ruc
	inner join unidad_negocio un on ruc.id_unid_negocio = un.id
	where ruc.id_convenio = (select id_convenio from apicredit.pre_solicitudes_creditos where numero_solicitud = _numero_solicitud)
	and ref_4 != '';

	if ( RsPuntajes is not null ) then

		PuntajeMax = RsPuntajes.puntaje_maximo_buro;
		raise notice 'CONSTANTE: %', PuntajeMax;

		select into RsPresolicitudes *
		from apicredit.pre_solicitudes_creditos
		where numero_solicitud = _numero_solicitud;
		raise notice 'ingresos_usuario: %', RsPresolicitudes.ingresos_usuario;

		if ( RsPresolicitudes is not null ) then

			select into ConfirmarHDC count(0)
			from wsdc.persona
			where identificacion = RsPresolicitudes.identificacion and  tipo_identificacion = 1 and nit_empresa in (NitEmpresaConsultora);

			raise notice 'ConfirmarHDC: %, identificacion: %', ConfirmarHDC, RsPresolicitudes.identificacion;

			--if ( ConfirmarHDC is not null) then
			if ( ConfirmarHDC > 0 ) then

				FOR vble_mercado_buro IN

					select * from administrativo.variable_mercado_buro order by id
				LOOP

					--
					if ( vble_mercado_buro.id = 1 ) then

						select into CtasAhorro count(0)
						from wsdc.cuenta_ahorro ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado_aho_ccb' and c1.codigo=ca.estado
						left join wsdc.codigo c2 on c2.web_service='H' and c2.tabla='tipo_cuenta_cartera' and c2.codigo='AHO'
						where
						identificacion= RsPresolicitudes.identificacion
						and tipo_identificacion=1
						and nit_empresa in (NitEmpresaConsultora)
						and c1.descripcion = 'Vigente';

						if ( CtasAhorro > 1 ) then

							PuntajeMax = PuntajeMax + 15;
							--raise notice 'identificacion: %', ConfirmarHDC;
							raise notice 'vble_mercado_buro: %, Suma:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 2 ) then

						select into TiempoTranscurrido round((now()::date - MIN(fecha_apertura::date))::numeric/30) as TimeLiveCredit from (
							select fecha_apertura FROM wsdc.cuenta_cartera where identificacion= RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
							select fecha_apertura FROM wsdc.cuenta_ahorro where identificacion= RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
							select fecha_apertura FROM wsdc.cuenta_corriente where identificacion= RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
							select fecha_apertura FROM wsdc.tarjeta_credito where identificacion= RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) c;

						if ( TiempoTranscurrido > 60 ) then

							PuntajeMax = PuntajeMax + 25;
							raise notice 'vble_mercado_buro: %, Suma:25, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 3 ) then

						TiempoTranscurrido = 0;
						select into TiempoTranscurrido round((now()::date - MAX(fecha_apertura::date))::numeric/30) as TimeLiveCredit from (
							select fecha_apertura FROM wsdc.cuenta_cartera where identificacion= RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
							select fecha_apertura FROM wsdc.cuenta_ahorro where identificacion = RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
							select fecha_apertura FROM wsdc.cuenta_corriente where identificacion = RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
							select fecha_apertura FROM wsdc.tarjeta_credito where identificacion = RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) c;

						if ( TiempoTranscurrido > 12 ) then

							PuntajeMax = PuntajeMax + 30;
							raise notice 'vble_mercado_buro: %, , Suma:30, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 4 ) then

						select into MoraMax6 MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 6, 'MAX', ''))
						from (
							/*
							select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
							select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							*/

							select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento
							FROM wsdc.cuenta_cartera ca
							left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
							where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							and c1.descripcion = 'Vigente'
							union all
							select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento
							FROM wsdc.tarjeta_credito ca
							left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
							where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							and c1.descripcion = 'Vigente'
						) ca;

						if ( MoraMax6 > 0 and MoraMax6 <= 2 ) then

							PuntajeMax = PuntajeMax - 10;
							raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

						if ( MoraMax6 > 0 and MoraMax6 > 2 ) then

							PuntajeMax = PuntajeMax - 30;
							raise notice 'vble_mercado_buro: %, Resta:30, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;


					end if;

					--
					if ( vble_mercado_buro.id = 5 ) then

						select into MoraMax12 MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'MAX', ''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento
						FROM wsdc.cuenta_cartera ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
						where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						and c1.descripcion = 'Vigente'
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento
						FROM wsdc.tarjeta_credito ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
						where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						and c1.descripcion = 'Vigente'
						) ca;

						if ( MoraMax12 > 0 and MoraMax12 <= 2 ) then

							PuntajeMax = PuntajeMax - 10;
							raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

						if ( MoraMax12 > 0 and MoraMax12 > 2 ) then

							PuntajeMax = PuntajeMax - 30;
							raise notice 'vble_mercado_buro: %, Resta:30, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 6 ) then

						select into MoraMaxGen coalesce(max(maxima_mora)) from wsdc.valor where id_padre in (
								select id
								FROM wsdc.cuenta_cartera ca
								left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
								where identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
								select id
								FROM wsdc.cuenta_ahorro ch
								left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ch.estado
								where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
								select id
								FROM wsdc.cuenta_corriente cc
								left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=cc.estado
								where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
								select id
								FROM wsdc.tarjeta_credito tc
								left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=tc.estado
								where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) and identificacion= RsPresolicitudes.identificacion;

						if ( MoraMaxGen > 0 and MoraMaxGen < 61 ) then

							PuntajeMax = PuntajeMax - 40;
							raise notice 'vble_mercado_buro: %, Resta:40, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

						if ( MoraMaxGen > 0 and MoraMaxGen > 60 ) then

							PuntajeMax = PuntajeMax - 60;
							raise notice 'vble_mercado_buro: %, Resta:60, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;


					end if;

					--
					if ( vble_mercado_buro.id = 7 ) then

						select into MoraMaxTDC coalesce(max(maxima_mora),0) from wsdc.valor where id_padre in (select id FROM wsdc.tarjeta_credito where  identificacion = RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora));

						if ( MoraMaxTDC > 0 and MoraMaxTDC > 30 ) then

							PuntajeMax = PuntajeMax - 20;
							raise notice 'vble_mercado_buro: %, Resta:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 8 ) then

						select into ObligacionesRecuperadas coalesce(count(0),0) from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on (c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado)
						where c1.codigo in ('09','10','11','12','46');

						if ( ObligacionesRecuperadas > 1 ) then

							PuntajeMax = PuntajeMax - 45;
							raise notice 'vble_mercado_buro: %, Resta:45, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 9 ) then

						select into MaxObligaciones coalesce(count(0),0) from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on (c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado)
						where c1.descripcion = 'Vigente';

						select into ObligacionesAldia coalesce(count(0),0) from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on (c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado)
						where c1.codigo = '01';

						if ( MaxObligaciones > 0 ) then

							MorasAldia = ((ObligacionesAldia/MaxObligaciones::numeric)*100)::numeric(11,0);

							if ( MorasAldia > 80 ) then

								PuntajeMax = PuntajeMax + 30;
								raise notice 'vble_mercado_buro: %, Suma:30, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

							end if;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 10 ) then

						select into RsCalificacion * --select *
						from wsdc.endeudamiento_global
						where id = (select max(id)
							    from wsdc.endeudamiento_global
							    where
							    identificacion = RsPresolicitudes.identificacion
							    and tipo_identificacion=1
							    and nit_empresa in (NitEmpresaConsultora)
							    );
						--raise notice 'calificacion: %',RsCalificacion.calificacion;
						if ( RsCalificacion.calificacion = 'B' ) then

							PuntajeMax = PuntajeMax - 40;
							raise notice 'vble_mercado_buro: %, Resta:40, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

						if ( RsCalificacion.calificacion in ('C','D','E') ) then

							PuntajeMax = PuntajeMax - 55;
							raise notice 'vble_mercado_buro: %, Resta:55, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 11 ) then

						select into AntiguedadTDC round((now()::date - fecha_apertura::date)::numeric/30) as antigTDC from (
							select min(fecha_apertura) as fecha_apertura
							from wsdc.tarjeta_credito ca
							left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
							where identificacion = RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							and c1.descripcion = 'Vigente'
						) c;

						if ( AntiguedadTDC < 13 ) then

							PuntajeMax = PuntajeMax - 15;
							raise notice 'vble_mercado_buro: %, Resta:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 12 ) then

						select into TotalSaldoMora coalesce(sum(saldo_mora),0) as saldo_mora from wsdc.valor where id_padre in (
						select id FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id FROM wsdc.cuenta_ahorro where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id FROM wsdc.cuenta_corriente where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) and identificacion= RsPresolicitudes.identificacion;

						if ( TotalSaldoMora > 200000 ) then

							PuntajeMax = PuntajeMax - 15;
							raise notice 'vble_mercado_buro: %, Resta:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 13 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 6, 'CON', '''2'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						inner join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.tipo_cuenta
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 1 ) then

							PuntajeMax = PuntajeMax - 10;
							raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					if ( vble_mercado_buro.id = 14 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 6, 'CON', '''3'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						inner join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.tipo_cuenta
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 15;
							raise notice 'vble_mercado_buro: %, Resta:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					if ( vble_mercado_buro.id = 15 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 6, 'CON', '''1'',''2'',''3'',''4'',''5'',''6'',''7'',''C'',''D'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						inner join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.tipo_cuenta
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 20;
							raise notice 'vble_mercado_buro: %, Resta:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					if ( vble_mercado_buro.id = 16 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''1'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						inner join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.tipo_cuenta
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 2 ) then

							PuntajeMax = PuntajeMax - 5;
							raise notice 'vble_mercado_buro: %, Resta:5, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					if ( vble_mercado_buro.id = 17 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''2'',''3'',''4'',''5'',''6'',''7'',''C'',''D'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						inner join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.tipo_cuenta
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 1 ) then

							PuntajeMax = PuntajeMax - 10;
							raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--Contador de Mora 31-60 últimos 12 meses
					if ( vble_mercado_buro.id = 18 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''1'',''2'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
						and c1.descripcion = 'Vigente';

						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 5;
							raise notice 'vble_mercado_buro: %, Resta:5, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--Contador de Mora 61-90 últimos 12 meses
					if ( vble_mercado_buro.id = 19 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''3'',''4'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
						and c1.descripcion = 'Vigente';


						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 10;
							raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--Contador de Mora 91-120 últimos 12 meses
					if ( vble_mercado_buro.id = 20 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''5'',''6'',''C'',''D'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
						and c1.descripcion = 'Vigente';


						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 15;
							raise notice 'vble_mercado_buro: %, Resta:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						end if;

					end if;

					--Porcentaje de utilización de la tarjeta de crédito
					if ( vble_mercado_buro.id = 21 ) then

						select into RsCalcUtilizacion coalesce(sum(cupo),0) as cupo, coalesce(sum(saldo_actual),0) as saldo_actual from wsdc.valor where id_padre in (
							select ca.id
							from wsdc.tarjeta_credito ca
							left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado
							where identificacion = RsPresolicitudes.identificacion and tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							and c1.descripcion = 'Vigente'
						) and identificacion = RsPresolicitudes.identificacion;

						if ( RsCalcUtilizacion.cupo != 0 and RsCalcUtilizacion.saldo_actual > RsCalcUtilizacion.cupo ) then

							PuntajeMax = PuntajeMax - 20;
							raise notice 'vble_mercado_buro: %, Resta:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

						elsif ( RsCalcUtilizacion.cupo != 0 and RsCalcUtilizacion.saldo_actual < RsCalcUtilizacion.cupo ) then

							CalculoUtilizacion = RsCalcUtilizacion.saldo_actual / RsCalcUtilizacion.cupo;

							if ( CalculoUtilizacion <= 30 ) then
								PuntajeMax = PuntajeMax + 20;
								raise notice 'vble_mercado_buro: %, Suma:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							end if;

							if ( CalculoUtilizacion > 90 ) then
								PuntajeMax = PuntajeMax - 20;
								raise notice 'vble_mercado_buro: %, Resta:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							end if;


						end if;

					end if;

				END LOOP;

				--ACTUALIZAR LA TABLA apicredit.pre_solicitudes_creditos. los campos: estado_sol: P/R, score: puntaje, causal: F02, comentarios: blabla blabla
				raise notice 'PuntajeMax: %, cutoff_buro: %', PuntajeMax, RsPuntajes.cutoff_buro;

				if ( PuntajeMax < RsPuntajes.cutoff_buro ) then

					--update apicredit.pre_solicitudes_creditos set estado_sol = 'R', score = PuntajeMax, comentario = 'RECHAZADO POR NO CUMPLIR CON PUNTAJE MÍNIMO BURÓ', last_update = now(), user_update = 'APIFINCREDIT' where numero_solicitud = _numero_solicitud;
					respuesta = '{"respuesta":"R","valor":"0"}';
					_RtAccion = 'RECHAZADO';
				else
					_RtAccion = 'ACEPTADO';
				end if;

				--CALCULAR ENDEUDAMIENTO
				IF ( _RtAccion = 'ACEPTADO' ) THEN
					raise notice 'teta1';
					SELECT INTO EndeudamientoHDC
						sum(cupo_valor_inicial) as endeudamiento_total,
						sum(saldo_actual) as endeudamiento_actual,
						sum(saldo_mora) as saldo_mora,
						sum(cuota) as valor_cuota
					FROM (
						(
						select
							coalesce(sum(vcc.valor_inicial),0) as cupo_valor_inicial,
							coalesce(sum(vcc.saldo_actual),0) as saldo_actual,
							coalesce(sum(vcc.saldo_mora),0) as saldo_mora,
							coalesce(sum(vcc.cuota),0) as cuota
						from  wsdc.cuenta_cartera cca
						left join wsdc.codigo ce on ce.web_service='H' and ce.tabla='cod_estado' and ce.codigo=cca.estado
						left join wsdc.codigo cg on cg.web_service='H' and cg.tabla='garante_cartera' and cg.codigo=cca.garante
						left join wsdc.codigo ct on ct.web_service='H' and ct.tabla='tipo_cuenta_cartera' and ct.codigo=cca.tipo_cuenta
						left join  wsdc.valor vcc on vcc.id_padre = cca.id and vcc.tipo_padre='CCA'
						where
						    ce.descripcion='Vigente' and
						    cca.tipo_identificacion=1 and
						    cca.garante = '00' and
						    cca.identificacion = RsPresolicitudes.identificacion
						    and cca.nit_empresa=NitEmpresaConsultora
						)
						union all
						(
						select
							coalesce(sum(vtc.cupo),0) as cupo_valor_inicial,
							coalesce(sum(vtc.saldo_actual),0) as saldo_actual,
							coalesce(sum(vtc.saldo_mora),0) as saldo_mora,
							coalesce(sum(vtc.cuota),0) as cuota
						from wsdc.tarjeta_credito tc
						left join wsdc.codigo c on c.web_service='H' and c.tabla='cod_estado' and c.codigo=tc.estado
						left join  wsdc.valor vtc on vtc.id_padre = tc.id and vtc.tipo_padre='TCR'
						where
						c.descripcion = 'Vigente' and
						tc.amparada='f' and
						tc.tipo_identificacion=1 and
						tc.identificacion = RsPresolicitudes.identificacion and tc.nit_empresa=NitEmpresaConsultora
						)
					) c;

					raise notice 'endeudamiento_actual: %, ingresos_usuario: %', EndeudamientoHDC.valor_cuota, RsPresolicitudes.ingresos_usuario;

					GastosPersonales = round(RsPresolicitudes.ingresos_usuario::numeric * GastGeneral);
					raise notice 'GastosPersonales: %, ValorCuota: %', GastosPersonales, RsPresolicitudes.valor_cuota;

					select into TotalCtaFintra coalesce(sum(cuota),0)::numeric as total_cuota_fintra
					from wsdc.valor
					where id_padre in (
							select ca.id
							from wsdc.cuenta_cartera ca
							left join wsdc.codigo c1 on (c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado)
							where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							and c1.descripcion = 'Vigente' and entidad = 'FINTRA S.A'
					);

					/*
					if ( TotalCtaFintra > 0 ) then

						select into * from solicitud_persona where identificacion = RsPresolicitudes.identificacion

						DiasMoraDeudorActual = eg_altura_mora_periodo(RsPresolicitudes.identificacion,201412,4,0);

						SELECT INTO AlturaMoraDeudorActual
							CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
							     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
							     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
							     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
							     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
							     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
							     WHEN maxdia >= 1 THEN '2- 1 A 30'
							     WHEN maxdia <= 0 THEN '1- CORRIENTE'
								ELSE '0' END AS rango
						FROM (
							 select eg_altura_mora_periodo(RsPresolicitudes.identificacion,201412,4,0)::numeric as maxdia

						) tabla2;

						ResultadoDeudorActual = AlturaMoraDeudorActual || ' ('||DiasMoraDeudorActual||')';
						raise notice 'Identificacion: %, ResultadoDeudorActual: %', RsPresolicitudes.identificacion, ResultadoDeudorActual;

						--select * from solicitud_aval where numero_solicitud = 83213
						--update solicitud_aval set cuotas_pendientes = '4/6', altura_mora_actual_titular = '2- 1 A 30 (9)', altura_mora_history_titular='1- CORRIENTE (18)', altura_mora_actual_codeudor='PRIMERA VEZ', altura_mora_history_codeudor='PRIMERA VEZ' where numero_solicitud = 83213

						--AlturaMoraCodeudorActual = eg_altura_mora_periodo(RsPresolicitudes.identificacion,201412,4,0);
					end if;
					*/

					EndeudamMasCuota = EndeudamientoHDC.valor_cuota::numeric + RsPresolicitudes.valor_cuota::numeric + GastosPersonales - TotalCtaFintra;
					EndeudamSinCuota = EndeudamientoHDC.valor_cuota::numeric + GastosPersonales;

					EndeuDamiar = EndeudamientoHDC.valor_cuota::numeric;

					if ( RsPresolicitudes.ingresos_usuario > EndeudamMasCuota ) then

						PorcEndeudamiento = round((EndeudamMasCuota::numeric / RsPresolicitudes.ingresos_usuario::numeric) * 100);
						raise notice 'EndeudamMasCuota: %, PorcEndeudamiento: %', EndeudamMasCuota, PorcEndeudamiento;

						if ( PorcEndeudamiento > 90 ) then

							--CALCULAR MONTO SUGERIDO
							MontoEndeudamiento = (EndeudamMasCuota * PercPolitica) / PorcEndeudamiento;
							CuotaSugerida = EndeudamMasCuota - MontoEndeudamiento;
							MontoSugerido = ROUND(CuotaSugerida * RsPresolicitudes.numero_cuotas);
							raise notice 'MontoEndeudamiento: %, CuotaSugerida: %, MontoSugerido: %', MontoEndeudamiento, CuotaSugerida, MontoSugerido;

							PercEquivalencia = ROUND((MontoSugerido / RsPresolicitudes.monto_credito)*100);
							raise notice 'PercEquivalencia: %', PercEquivalencia;

							if ( PercEquivalencia > 70 ) then

								--RELIQUIDAR CON VALOR SUGERIDO
								SELECT into RsReliquidacion round(retorno.valor) as valor_cuota, round(sum(retorno.no_aval)) as valor_aval FROM eg_liquidador_api (MontoSugerido::numeric, RsPresolicitudes.numero_cuotas::integer, RsPresolicitudes.fecha_pago::date, RsPresolicitudes.id_convenio::integer, RsPresolicitudes.afiliado::varchar) as retorno group by valor;
								raise notice 'RsReliquidacion: %', RsReliquidacion;
								/*
								update apicredit.pre_solicitudes_creditos
								set
									estado_sol = 'S',
									score = PuntajeMax,
									comentario = 'APROBADO CON MONTO SUGERIDO',
									valor_cuota = RsReliquidacion.valor_cuota,
									valor_aval = RsReliquidacion.valor_aval,
									monto_credito = MontoSugerido,
									last_update = now(),
									user_update = 'APIFINCREDIT'
								where numero_solicitud = _numero_solicitud;
								*/
								respuesta = '{"respuesta":"S","valor":"'||MontoSugerido||'"}';
							else
								/*
								update apicredit.pre_solicitudes_creditos
								set
									estado_sol = 'R',
									score = PuntajeMax,
									comentario = 'RECHAZADO POR NO CUMPLIR CON EL 70% DEL MONTO SUGERIDO',
									last_update = now(),
									user_update = 'APIFINCREDIT'
								where numero_solicitud = _numero_solicitud;
								*/
								respuesta = '{"respuesta":"R","valor":"0"}';
							end if;


						elsif ( PorcEndeudamiento <= 90 ) then
							--update apicredit.pre_solicitudes_creditos set estado_sol = 'P', score = PuntajeMax, comentario = 'APROBADO DE ACUERDO CON EL MODELO BURÓ', last_update = now(), user_update = 'APIFINCREDIT' where numero_solicitud = _numero_solicitud;
							respuesta = '{"respuesta":"P","valor":"'||RsPresolicitudes.monto_credito||'"}';
						end if;

					else

						raise notice 'LA DEUDA SUPERA LOS INGRESOS';
						/*
						update apicredit.pre_solicitudes_creditos
						set
							estado_sol = 'R',
							score = PuntajeMax,
							comentario = 'EL ENDEUDAMIENTO SUPERA LOS INGRESOS',
							last_update = now(),
							user_update = 'APIFINCREDIT'
						where numero_solicitud = _numero_solicitud;
						*/
						respuesta = '{"respuesta":"R","valor":"0"}';
					end if;

				END IF;
				--

				--update apicredit.pre_solicitudes_creditos set total_obligaciones_financieras = EndeuDamiar, total_gastos_familiares = GastosPersonales where numero_solicitud = _numero_solicitud;

			end if;

		end if;

	end if;

	--respuesta = PuntajeMax;
	return respuesta;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_scorehdc2(integer, character varying)
  OWNER TO postgres;
