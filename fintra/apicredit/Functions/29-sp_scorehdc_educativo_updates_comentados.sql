-- Function: apicredit.sp_scorehdc_educativo_updates_comentados(integer, character varying)

-- DROP FUNCTION apicredit.sp_scorehdc_educativo_updates_comentados(integer, character varying);

CREATE OR REPLACE FUNCTION apicredit.sp_scorehdc_educativo_updates_comentados(_numero_solicitud integer, _huella character varying)
  RETURNS text AS
$BODY$

DECLARE

	--respuesta varchar := 'R';
	respuesta varchar := '{"respuesta":"R","valor":"0"}';
	NitEmpresaConsultora varchar := '';
	_RtAccion varchar := '';
	_Comentario varchar := '';

	vble_mercado_buro record;
	RsPuntajes record;
	RsPresolicitudes record;
	RsCalificacion record;
	RsCalcUtilizacion record;
	EndeudamientoHDC record;
	RsReliquidacion record;
	QuantoValor record;
	ConfirmarHDC record; --Descomentado por egonzalez 15-07-2018 habilitar tipo record

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
	EndeudamMasCuotaActualSinFintra numeric := 0;
	EndeudamSinCuotaActualMasFintra numeric := 0;
	Endeudamiar numeric := 0;
	MontoEndeudamiento numeric := 0;
	MontoSugerido numeric := 0;
	CuotaSugerida numeric := 0;
	PercEquivalencia numeric := 0;
	GastGeneral numeric := 0.40;
	PercPolitica numeric := 89.99;
	TotalCtaFintra numeric := 0;

	IngresoSolicitante numeric := 0;
	myarray integer[]:='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}';
	scoreTotal numeric := 0;

	--ConfirmarHDC integer; --Comentado por egonzalez 15-07-2018 para cambiar a record la variable


BEGIN
	raise notice '_numero_solicitud: %', _numero_solicitud;
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


	IF ( _huella = 'FENALCO_BOL' ) THEN
		NitEmpresaConsultora = '8904800244';
		update apicredit.pre_solicitudes_creditos set estado_sol = 'P', score = 750, comentario = 'PRE APROBADO BUREAU', last_update = now(), user_update = 'APIFINCREDIT' where numero_solicitud = _numero_solicitud;
		respuesta = '{"respuesta":"P","valor":"750"}';
		return respuesta;
	ELSIF ( _huella = 'FENALCO_ATL' ) THEN
		NitEmpresaConsultora = '8901009858';
	ELSE
		NitEmpresaConsultora = '8020220161';
	END IF;*/


	--SE QUITA POR CONVENIO FINTRA - LA EMPANADA
	NitEmpresaConsultora = '8020220161';

	select into RsPuntajes un.puntaje_maximo_buro, un.minimo_buro, un.maximo_buro, un.cutoff_buro
	from rel_unidadnegocio_convenios ruc
	inner join unidad_negocio un on ruc.id_unid_negocio = un.id
	where ruc.id_convenio = (select id_convenio from apicredit.pre_solicitudes_creditos where numero_solicitud = _numero_solicitud)
	and ref_4 != '';

	if ( RsPuntajes is not null ) then

		PuntajeMax = RsPuntajes.puntaje_maximo_buro;
		--raise notice 'CONSTANTE: %', PuntajeMax;

		select into RsPresolicitudes *
		from apicredit.pre_solicitudes_creditos
		where numero_solicitud = _numero_solicitud;
		--raise notice 'ingresos_usuario: %', RsPresolicitudes.ingresos_usuario;

		if ( RsPresolicitudes is not null ) then

			select into ConfirmarHDC count(0) as confirmar_hdc, trim(tipo_cliente)  as tipo_cliente
			from wsdc.persona
			where identificacion = RsPresolicitudes.identificacion and  tipo_identificacion = 1 and nit_empresa in (NitEmpresaConsultora)
			group by tipo_cliente ;

			--raise notice 'ConfirmarHDC: %', ConfirmarHDC;
			--raise notice 'identificacion: %', RsPresolicitudes.identificacion;



			--if ( ConfirmarHDC is not null) then
			if ( ConfirmarHDC.confirmar_hdc > 0  and ConfirmarHDC.tipo_cliente != '09') then --se validad el tipo de cliente para evitar fraude egonzalez 15-07-2018

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
							--raise notice 'vble_mercado_buro: %, Suma:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

							--Se setea el valor al array en la posicion [1]
							myarray[1] :=15;

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
							--raise notice 'vble_mercado_buro: %, Suma:25, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

							--Se setea el valor al array en la posicion [2]
							myarray[2] :=25;


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
							--raise notice 'vble_mercado_buro: %, , Suma:30, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;

							--Se setea el valor al array en la posicion [3]
							myarray[3] :=30;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 4 ) then

						select into MoraMax6 MAX(apicredit.SP_VectorComportamiento(trim(xa.comportamiento), _numero_solicitud, 6, 'MAX', '')) from (
							select *
							from (
							select id, entidad, estado, fecha_apertura, fecha_vencimiento, ultima_actualizacion, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
							select id, entidad, estado, fecha_apertura, fecha_vencimiento, ultima_actualizacion, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							) ca
							left join wsdc.codigo c1 on (c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado)
							where case when c1.descripcion ='Cerrada' then (now()::date-ultima_actualizacion::date) <=180  else true end
						) xa;

						if ( MoraMax6 > 0 and MoraMax6 <= 2 ) then

							PuntajeMax = PuntajeMax - 10;
							--raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [4]
							myarray[4] :=-10;

						end if;

						if ( MoraMax6 > 0 and MoraMax6 > 2 ) then

							PuntajeMax = PuntajeMax - 30;
							--raise notice 'vble_mercado_buro: %, Resta:30, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [4]
							myarray[1] :=-30;

						end if;


					end if;

					--
					if ( vble_mercado_buro.id = 5 ) then

						select into MoraMax12 MAX(apicredit.SP_VectorComportamiento(trim(xa.comportamiento), _numero_solicitud, 12, 'MAX', '')) from (
							select *
							from (
							select id, entidad, estado, fecha_apertura, fecha_vencimiento, ultima_actualizacion, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							union all
							select id, entidad, estado, fecha_apertura, fecha_vencimiento, ultima_actualizacion, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							) ca
							left join wsdc.codigo c1 on (c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado)
							where case when c1.descripcion ='Cerrada' then (now()::date-ultima_actualizacion::date) <=360  else true end
						) xa;


						if ( MoraMax6 > 0 and MoraMax12 <= 2 ) then

							PuntajeMax = PuntajeMax - 10;
							--raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [5]
							myarray[5] :=-10;

						end if;

						if ( MoraMax6 > 0 and MoraMax12 > 2 ) then

							PuntajeMax = PuntajeMax - 30;
							--raise notice 'vble_mercado_buro: %, Resta:30, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [5]
							myarray[5] :=-30;

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
							--raise notice 'vble_mercado_buro: %, Resta:40, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [6]
							myarray[6] :=-40;

						end if;

						if ( MoraMaxGen > 0 and MoraMaxGen > 60 ) then

							PuntajeMax = PuntajeMax - 60;
							--raise notice 'vble_mercado_buro: %, Resta:60, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [6]
							myarray[6] :=-60;

						end if;


					end if;

					--
					if ( vble_mercado_buro.id = 7 ) then

						select into MoraMaxTDC coalesce(max(maxima_mora),0) from wsdc.valor where id_padre in (select id FROM wsdc.tarjeta_credito where  identificacion = RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora));

						if ( MoraMaxTDC > 0 and MoraMaxTDC > 30 ) then

							PuntajeMax = PuntajeMax - 20;
							--raise notice 'vble_mercado_buro: %, Resta:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [7]
							myarray[7] :=-20;

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
							--raise notice 'vble_mercado_buro: %, Resta:45, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [8]
							myarray[8] :=-45;

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
								--raise notice 'vble_mercado_buro: %, Suma:30, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
								--Se setea el valor al array en la posicion [9]
								myarray[9] :=30;

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
							--raise notice 'vble_mercado_buro: %, Resta:40, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [10]
							myarray[10] :=-40;

						end if;

						if ( RsCalificacion.calificacion in ('C','D','E') ) then

							PuntajeMax = PuntajeMax - 55;
							--raise notice 'vble_mercado_buro: %, Resta:55, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [10]
							myarray[10] :=-55;

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
							--raise notice 'vble_mercado_buro: %, Resta:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [11]
							myarray[11] :=-15;

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
							--raise notice 'vble_mercado_buro: %, Resta:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [12]
							myarray[12] :=-15;

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
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.estado
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 1 ) then

							PuntajeMax = PuntajeMax - 10;
							--raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [13]
							myarray[13] :=-10;

						end if;

					end if;

					if ( vble_mercado_buro.id = 14 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 6, 'CON', '''3'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.estado
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 15;
							--raise notice 'vble_mercado_buro: %, Resta:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [14]
							myarray[14] :=-15;

						end if;

					end if;

					if ( vble_mercado_buro.id = 15 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 6, 'CON', '''1'',''2'',''3'',''4'',''5'',''6'',''7'',''C'',''D'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.estado
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 20;
							--raise notice 'vble_mercado_buro: %, Resta:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [15]
							myarray[15] :=-20;

						end if;

					end if;

					if ( vble_mercado_buro.id = 16 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''1'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.estado
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 2 ) then

							PuntajeMax = PuntajeMax - 5;
							--raise notice 'vble_mercado_buro: %, Resta:5, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [16]
							myarray[16] :=-5;

						end if;

					end if;

					if ( vble_mercado_buro.id = 17 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''2'',''3'',''4'',''5'',''6'',''7'',''C'',''D'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca
						left join wsdc.codigo c1 on c1.web_service='H' and c1.tabla='tipo_cuenta_cartera' and c1.codigo=ca.estado
						and c1.codigo in ('CDC','CTC');

						if ( CuentaMaxMora > 1 ) then

							PuntajeMax = PuntajeMax - 10;
							--raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [17]
							myarray[17] :=-10;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 18 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''1'',''2'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca;

						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 5;
							--raise notice 'vble_mercado_buro: %, Resta:5, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [18]
							myarray[18] :=-5;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 19 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''3'',''4'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca;

						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 10;
							--raise notice 'vble_mercado_buro: %, Resta:10, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [19]
							myarray[19] :=-10;

						end if;

					end if;

					--
					if ( vble_mercado_buro.id = 20 ) then

						select into CuentaMaxMora MAX(apicredit.SP_VectorComportamiento(trim(ca.comportamiento), _numero_solicitud, 12, 'CON', '''5'',''6'',''C'',''D'''))
						from (
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, tipo_obligacion, tipo_cuenta, garante, forma_pago, comportamiento FROM wsdc.cuenta_cartera where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						union all
						select id, entidad, estado, fecha_apertura, fecha_vencimiento, '' as tipo_obligacion, '' as tipo_cuenta, '' as garante, '' as forma_pago, comportamiento FROM wsdc.tarjeta_credito where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
						) ca;

						if ( CuentaMaxMora > 0 ) then

							PuntajeMax = PuntajeMax - 15;
							--raise notice 'vble_mercado_buro: %, Resta:15, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [20]
							myarray[20] :=-15;

						end if;

					end if;

					--
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
							--raise notice 'vble_mercado_buro: %, Resta:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
							--Se setea el valor al array en la posicion [21]
							myarray[21] :=-20;


						elsif ( RsCalcUtilizacion.cupo != 0 and RsCalcUtilizacion.saldo_actual < RsCalcUtilizacion.cupo ) then

							CalculoUtilizacion = (RsCalcUtilizacion.saldo_actual / RsCalcUtilizacion.cupo)*100;

							if ( CalculoUtilizacion <= 30 ) then
								PuntajeMax = PuntajeMax + 20;
							--	raise notice 'vble_mercado_buro: %, Suma:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
								--Se setea el valor al array en la posicion [21]
								myarray[1] :=20;
							end if;

							if ( CalculoUtilizacion > 90 ) then
								PuntajeMax = PuntajeMax - 20;
							--	raise notice 'vble_mercado_buro: %, Resta:20, PuntajeMax: %', vble_mercado_buro.id, PuntajeMax;
								--Se setea el valor al array en la posicion [21]
								myarray[1] :=-20;
							end if;


						end if;

					end if;

				END LOOP;

				--INSERT
				INSERT INTO apicredit.historico_score_educativo(reg_status, s_numero_solicitud, s_identificacion, puntaje_maximo_buro, s_cant_cta_ahorros_abiertas, s_tiemp_primer_product_sect_financ,
										s_tiemp_ultim_product_sect_financ, s_mora_max_semestre, s_mora_max_anio, s_mora_max_actual, s_mora_max_tdc, s_cant_carteras_recup,
										s_porc_oblig_titular_aldia, s_ultim_peor_calif, s_antig_meses_tdc, s_total_saldo_mora, s_cont_mora_sesenta_semestre_telcos,
										s_cont_mora_noventa_semestre_telcos, s_cont_mora_mayor_noventa_semestre_telcos, s_cont_mora_treinta_anio_telcos, s_cont_mora_mayor_treinta_anio_telcos,
										s_cont_mora_treinta_sesenta_anio, s_cont_mora_sesenta_noventa_anio, s_cont_mora_mayor_noventa_anio, s_porc_uso_tarjeta_credit, s_score_total,
										creation_date, creation_user)
				VALUES ( '', _numero_solicitud, RsPresolicitudes.identificacion, RsPuntajes.puntaje_maximo_buro, myarray[1], myarray[2], myarray[3], myarray[4], myarray[5], myarray[6], myarray[7], myarray[8], myarray[9],
					myarray[10], myarray[11], myarray[12], myarray[13], myarray[14], myarray[15], myarray[16], myarray[17], myarray[18], myarray[19], myarray[20], myarray[21], PuntajeMax, now(), 'ADMIN' );

				--ACTUALIZAR LA TABLA apicredit.pre_solicitudes_creditos. los campos: estado_sol: P/R, score: puntaje, causal: F02, comentarios: blabla blabla
				--raise notice 'PuntajeMax: %, cutoff_buro: %', PuntajeMax, RsPuntajes.cutoff_buro;

				-- if ( PuntajeMax < RsPuntajes.cutoff_buro ) then
--
-- 					update apicredit.pre_solicitudes_creditos
-- 						set estado_sol = 'R',
-- 						score = PuntajeMax,
-- 						comentario = 'RECHAZADO SOBRE BUREAU',
-- 						last_update = now(),
-- 						user_update = 'APIFINCREDIT',
-- 						etapa=-1
-- 						where numero_solicitud = _numero_solicitud;
--
-- 					respuesta = '{"respuesta":"R","valor":"0"}';
-- 					_RtAccion = 'RECHAZADO';
-- 				else
-- 					_RtAccion = 'ACEPTADO';
-- 				end if;

				--CALCULAR ENDEUDAMIENTO
				--IF ( _RtAccion = 'ACEPTADO' ) THEN

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

					--VALOR QUANTO
					--select * from wsdc.productos_valores where nit_empresa = '8020220161' and identificacion = '29703540'; | 29703540
					select into QuantoValor * from wsdc.productos_valores where nit_empresa = NitEmpresaConsultora and identificacion = RsPresolicitudes.identificacion;
					IF FOUND  THEN

						--raise notice 'QUANTO';
						/*****************************************************************************************************************
						* Validacion: se agrega control con el campo de razon del quanto para validar clientes fallecido con codigo 073  *
						*	      , Persona juridica 0070										    *
						* autor: egonzalez												    *
						* fecha: 2018-06-5												    *
						****************************************************************************************************************/
						--Cliente Fallecido.
						IF(QuantoValor.razon1 in ('0073'))THEN

							-- update apicredit.pre_solicitudes_creditos
-- 									set estado_sol = 'R',
-- 									score = PuntajeMax,
-- 									comentario = 'CLIENTE FALLECIDO',
-- 									last_update = now(),
-- 									user_update = 'APIFINCREDIT',
-- 									etapa=-1
-- 							where numero_solicitud = _numero_solicitud;
--
-- 							respuesta = '{"respuesta":"F","valor":"0"}';
--
-- 							RETURN respuesta;

						END IF;

						--Persona Juridica
						IF(QuantoValor.razon1 in ('0070'))THEN

							-- update apicredit.pre_solicitudes_creditos
-- 									set estado_sol = 'R',
-- 									score = PuntajeMax,
-- 									comentario = 'CLIENTE PERSONA JURIDICA',
-- 									last_update = now(),
-- 									user_update = 'APIFINCREDIT',
-- 									etapa=-1
-- 							where numero_solicitud = _numero_solicitud;

							respuesta = '{"respuesta":"R","valor":"0"}';

							RETURN respuesta;

						END IF;

						--Validar valor en cero
						IF(QuantoValor.valor1 <= 0)THEN
							IngresoSolicitante:=RsPresolicitudes.ingresos_usuario;
						ELSE
							IngresoSolicitante = coalesce(QuantoValor.valor1::numeric*1000,RsPresolicitudes.ingresos_usuario);
						END IF;

					ELSE
						--raise notice 'FORMULARIO';
						IngresoSolicitante = RsPresolicitudes.ingresos_usuario;
					END IF;

					--raise notice 'endeudamiento_actual: %, ingresos_usuario: %', EndeudamientoHDC.valor_cuota, IngresoSolicitante;

					GastosPersonales = round(IngresoSolicitante::numeric * GastGeneral);
					--raise notice 'GastosPersonales: %, ValorCuota: %', GastosPersonales, RsPresolicitudes.valor_cuota;

					select into TotalCtaFintra coalesce(sum(cuota),0)::numeric as total_cuota_fintra
					from wsdc.valor
					where id_padre in (
							select ca.id
							from wsdc.cuenta_cartera ca
							left join wsdc.codigo c1 on (c1.web_service='H' and c1.tabla='cod_estado' and c1.codigo=ca.estado)
							where  identificacion= RsPresolicitudes.identificacion and  tipo_identificacion=1 and nit_empresa in (NitEmpresaConsultora)
							and c1.descripcion = 'Vigente' and entidad = 'FINTRA S.A'
					);

					EndeudamMasCuotaActualSinFintra = EndeudamientoHDC.valor_cuota::numeric + RsPresolicitudes.valor_cuota::numeric + GastosPersonales - TotalCtaFintra;
					EndeudamSinCuotaActualMasFintra = EndeudamientoHDC.valor_cuota::numeric + GastosPersonales;

					--raise notice 'valor_cuotaHDC: %, valor_cuotaSolicitud: %, GastosPersonales: %, TotalCtaFintra: %', EndeudamientoHDC.valor_cuota::numeric, RsPresolicitudes.valor_cuota::numeric, GastosPersonales, TotalCtaFintra;

					--raise notice 'EndeudamMasCuotaActualSinFintra: %', EndeudamMasCuotaActualSinFintra;
					--raise notice 'EndeudamSinCuotaActualMasFintra: %', EndeudamSinCuotaActualMasFintra;

					EndeuDamiar = EndeudamientoHDC.valor_cuota::numeric;

					PorcEndeudamiento = round((EndeudamMasCuotaActualSinFintra::numeric / IngresoSolicitante::numeric) * 100,2);
					--raise notice 'EndeudamMasCuotaActualSinFintra: %, PorcEndeudamiento: %', EndeudamMasCuotaActualSinFintra, PorcEndeudamiento;

					--if ( IngresoSolicitante > EndeudamMasCuotaActualSinFintra ) then

						if ( PorcEndeudamiento > 90 ) then

							--CALCULAR MONTO SUGERIDO
							/*
							MontoEndeudamiento = (EndeudamMasCuotaActualSinFintra * PercPolitica) / PorcEndeudamiento;
							CuotaSugerida = EndeudamMasCuotaActualSinFintra - MontoEndeudamiento;
							MontoSugerido = ROUND(CuotaSugerida * RsPresolicitudes.numero_cuotas);
							raise notice 'MontoEndeudamiento: %, CuotaSugerida: %, MontoSugerido: %', MontoEndeudamiento, CuotaSugerida, MontoSugerido;

							PercEquivalencia = ROUND((MontoSugerido / RsPresolicitudes.monto_credito)*100);
							raise notice 'PercEquivalencia: %', PercEquivalencia;

							if ( PercEquivalencia > 70 ) then

								--RELIQUIDAR CON VALOR SUGERIDO - Tener en cuenta el nuevo liquidador de crédito (EGONZALEZ)
								IF ( _RtAccion = 'ACEPTADO' ) THEN
									update apicredit.pre_solicitudes_creditos
									set
										estado_sol = 'R',
										score = PuntajeMax,
										comentario = 'CAP PAGO SIN OPC',
										last_update = now(),
										user_update = 'APIFINCREDIT',
										etapa=-1
									where numero_solicitud = _numero_solicitud;
								END IF;

								respuesta = '{"respuesta":"R","valor":"0"}';

							else
								IF ( _RtAccion = 'ACEPTADO' ) THEN
									update apicredit.pre_solicitudes_creditos
									set
										estado_sol = 'R',
										score = PuntajeMax,
										comentario = 'CAP PAGO SIN OPC',
										last_update = now(),
										user_update = 'APIFINCREDIT',
										etapa=-1
									where numero_solicitud = _numero_solicitud;
								END IF;
								respuesta = '{"respuesta":"R","valor":"0"}';
							end if;
							*/

							---SE APRUEBA CON CONDICION
							--raise notice 'validar_cp: %', RsPresolicitudes.validar_cp;
							if ( RsPresolicitudes.validar_cp = 'N' and _RtAccion = 'ACEPTADO' ) then

								-- update apicredit.pre_solicitudes_creditos
-- 									set estado_sol = 'P',
-- 									    score = PuntajeMax,
-- 									    comentario = 'APROBADO CON CONDICION',
-- 									    last_update = now(),
-- 									    user_update = 'APIFINCREDIT'
-- 								where numero_solicitud = _numero_solicitud;

								respuesta = '{"respuesta":"P","valor":"'||RsPresolicitudes.monto_credito||'"}';
							else

								if ( _RtAccion = 'ACEPTADO' ) then
									_Comentario = 'CAP PAGO SIN OPC';
								elsif ( _RtAccion = 'RECHAZADO' ) then
									_Comentario = 'RECHAZADO SOBRE BUREAU';
								end if;

							--	raise notice 'LA DEUDA SUPERA LOS INGRESOS';
								-- update apicredit.pre_solicitudes_creditos
-- 								set
-- 									estado_sol = 'R',
-- 									score = PuntajeMax,
-- 									comentario = _Comentario,
-- 									last_update = now(),
-- 									user_update = 'APIFINCREDIT',
-- 									etapa=-1
-- 								where numero_solicitud = _numero_solicitud;

								respuesta = '{"respuesta":"R","valor":"0"}';
							end if;

						elsif ( PorcEndeudamiento <= 90 and  _RtAccion = 'ACEPTADO' ) then

							-- update apicredit.pre_solicitudes_creditos
-- 								set estado_sol = 'P',
-- 								    score = PuntajeMax,
-- 								    comentario = 'PRE APROBADO BUREAU',
-- 								    last_update = now(),
-- 								    user_update = 'APIFINCREDIT'
-- 						        where numero_solicitud = _numero_solicitud;

							respuesta = '{"respuesta":"P","valor":"'||RsPresolicitudes.monto_credito||'"}';

						end if;
					/*
					else

						raise notice 'LA DEUDA SUPERA LOS INGRESOS';
						update apicredit.pre_solicitudes_creditos
						set
							estado_sol = 'R',
							score = PuntajeMax,
							comentario = 'CAP PAGO SIN OPC',
							last_update = now(),
							user_update = 'APIFINCREDIT',
							etapa=-1
						where numero_solicitud = _numero_solicitud;

						respuesta = '{"respuesta":"R","valor":"0"}';

					end if;
					*/
					--raise notice 'PorcEndeudamientoDESPUES: %', PorcEndeudamiento;

					-- update apicredit.pre_solicitudes_creditos
-- 					set
-- 						total_obligaciones_financieras = EndeuDamiar,
-- 						total_gastos_familiares = GastosPersonales
-- 						,qb = QuantoValor.valor2::numeric*1000
-- 						,qm = QuantoValor.valor1::numeric*1000
-- 						,qa = QuantoValor.valor3::numeric*1000
-- 						,porc_endeudamiento = PorcEndeudamiento::numeric
-- 					where numero_solicitud = _numero_solicitud;

				--Fin del Aceptado
				--END IF;
				--
			elsif(ConfirmarHDC.tipo_cliente = '09') THEN  --si es tipo 7 el cliente

				-- update apicredit.pre_solicitudes_creditos
-- 					set estado_sol = 'R',
-- 					    score = 0.0,
-- 					    comentario = 'RECHAZO CLIENTE TIPO 7',
-- 					    tipo_cliente='TIPO 7',
-- 					    last_update = now(),
-- 					    user_update = 'APIFINCREDIT',
-- 					    etapa=-1
-- 				where numero_solicitud = _numero_solicitud;

			end if;

		end if;

	end if;

	--respuesta = PuntajeMax;
	return respuesta;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.sp_scorehdc_educativo_updates_comentados(integer, character varying)
  OWNER TO postgres;
