-- Function: sp_seguimientocarteraxclientehcg(numeric, character varying, character varying, character varying)

-- DROP FUNCTION sp_seguimientocarteraxclientehcg(numeric, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_seguimientocarteraxclientehcg(periodoasignacion numeric, unidadnegocio character varying, agenteext character varying, nitcliente character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraTotales record;
	CarteraGeneral record;
	CarteraWtramoAnterior record;
	ClienteRec record;
	BankPay record;
	FchLastPay record;
	_unidadnegocio record;

	NegocioAvales record;
	NegocioSeguros record;
	NegocioGps record;

	NegocioSegurosGps record;
	NegocioVencimientoSeguro record;
	NegocioVencimientoGps record;

	SumaDeAval record;
	Rs_ResultPay record;

	PercValorAsignado numeric;
	PercCantAsignado numeric;
	_TramoAnterior numeric;
	PeriodoTramo numeric;
	PeriodoTramoAnterior numeric;
	_SumDebidoCobrar numeric;
	Ingresoxcuota_fiducia numeric;
	Ingresoxcuota_fenalco numeric;
	IngresoxCuota numeric;

	CadAgentes varchar;
	periodo_corte varchar;
	FechaCortePeriodo varchar;
	FechaCortePeriodoAnt varchar;
	StatusVcto varchar;
	UltimoPago varchar;
	NegocioArray record;
	FirstTime varchar;

	miHoy date;

BEGIN

	IF ( unidadnegocio != 29 ) THEN
	raise notice 'unidadnegocio : %',unidadnegocio;
		if ( substring(periodoasignacion,5) = '01' ) then
			PeriodoTramo = substring(periodoasignacion,1,4)::numeric-1||'12';
			_TramoAnterior = substring(periodoasignacion,1,4)::numeric-1||'12';
		else
			PeriodoTramo = periodoasignacion::numeric - 1;
			_TramoAnterior = periodoasignacion::numeric - 1;
		end if;

		--PeriodoTramo = PeriodoAsignacion::numeric - 1;
		PeriodoTramoAnterior = PeriodoTramo::numeric - 1;

		--_TramoAnterior = PeriodoAsignacion::numeric - 1;

		select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
		select into FechaCortePeriodoAnt to_char(to_timestamp(substring(PeriodoTramoAnterior,1,4)::numeric || '-' || to_char(substring(PeriodoTramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
		raise notice 'FechaCortePeriodo : %',FechaCortePeriodo;
		miHoy = now()::date;

		DELETE FROM tem.tabla_array WHERE creation_date::date < now()::date and modulo_cartera = 'SEGUIMIENTO';
		DELETE FROM tem.tabla_array WHERE useruse = AgenteExt and modulo_cartera = 'SEGUIMIENTO';

		--NegocioArray = '';
		FirstTime = 'First';

		FOR CarteraGeneral IN

			select
				nit::varchar as cedula,
				''::varchar as nombre_cliente,
				''::varchar as direccion,
				''::varchar as ciudad,
				''::varchar as telefono,
				''::varchar as telcontacto,
				negasoc::varchar as negocio,
				id_convenio::varchar,
				''::varchar as pagaduria,
				''::varchar as nm_convenio,
				num_doc_fen::varchar as cuota,
				sum(valor_saldo)::numeric as valor_asignado,
				fecha_vencimiento::date,
				replace(substring(fecha_vencimiento,1,7),'-','')::numeric as periodo_vcto,
				(
				SELECT
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
					 SELECT max(FechaCortePeriodo::date-(fecha_vencimiento)) as maxdia
					 FROM con.foto_cartera fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = con.foto_cartera.negasoc
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
						  AND fra.periodo_lote = PeriodoAsignacion
					 GROUP BY negasoc

				) tabla2
				)::varchar as vencimiento_mayor,
				(FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
				''::varchar as status,
				''::varchar as status_vencimiento,
				0::numeric as debido_cobrar,
				0::numeric as recaudosxcuota_fiducia,
				0::numeric as recaudosxcuota_fenalco,
				0::numeric as recaudosxcuota,
				agente::varchar

			from con.foto_cartera
			where periodo_lote = PeriodoAsignacion
				and valor_saldo > 0
				and reg_status = ''
				and dstrct = 'FINV'
				and tipo_documento in ('FAC','NDC')
				and substring(documento,1,2) not in ('CP','FF','DF')
				--and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
				and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
				and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_seguro = '') > 0
				and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_gps = '') > 0
				and nit=nitCliente
				--and negasoc = 'MC02895'
			group by cedula, nombre_cliente, direccion, ciudad, telefono, negasoc, id_convenio, num_doc_fen, vencimiento_mayor, fecha_vencimiento, periodo_vcto, agente
			order by negasoc LOOP

			_SumDebidoCobrar = 0;
			Ingresoxcuota_fiducia = 0;
			Ingresoxcuota_fenalco = 0;
			IngresoxCuota = 0;

			--STATUS Y DEBIDO COBRAR
			if (CarteraGeneral.periodo_vcto = PeriodoAsignacion ) then

				SELECT INTO _SumDebidoCobrar coalesce(valor,0) from documentos_neg_aceptado where cod_neg = CarteraGeneral.negocio and item = CarteraGeneral.cuota;

				CarteraGeneral.status = 'A Vencer';
				CarteraGeneral.debido_cobrar = coalesce(_SumDebidoCobrar,0);

			else
				if ( CarteraGeneral.dias_vencidos > 0 ) then

					CarteraGeneral.status = 'Vencido';
					CarteraGeneral.debido_cobrar = coalesce(CarteraGeneral.valor_asignado,0);

				else
					SELECT INTO _SumDebidoCobrar coalesce(valor,0) from documentos_neg_aceptado where cod_neg = CarteraGeneral.negocio and item = CarteraGeneral.cuota;
					CarteraGeneral.status = 'Al Dia';
					CarteraGeneral.debido_cobrar = coalesce(_SumDebidoCobrar,0);
				end if;
			end if;

			if ( CarteraGeneral.fecha_vencimiento < miHoy ) then
				CarteraGeneral.status_vencimiento = 'VENCIO';
			else
				CarteraGeneral.status_vencimiento = 'AL DIA';
			end if;

			--RECAUDO Y ENTIDAD DEL PAGO
			select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, CarteraGeneral.negocio, CarteraGeneral.cuota);

			CarteraGeneral.recaudosxcuota_fiducia = Rs_ResultPay.rs_ingresoxcuota_fiducia;
			CarteraGeneral.recaudosxcuota_fenalco = Rs_ResultPay.rs_ingresoxcuota_fenalco;
			CarteraGeneral.recaudosxcuota = Rs_ResultPay.rs_ingresoxCuota;

			if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
				CarteraGeneral.recaudosxcuota = Rs_ResultPay.rs_ingresoxCuota;
			else
				CarteraGeneral.recaudosxcuota = 0;
			end if;


			select into _unidadnegocio * from SP_NombreUnidadNegocio(CarteraGeneral.negocio) as un(id_unid_negocio integer, nombre_unid_negocio varchar, id_convenio integer);
			CarteraGeneral.id_convenio = _unidadnegocio.id_unid_negocio;
			CarteraGeneral.nm_convenio = _unidadnegocio.nombre_unid_negocio;



			--VALIDADOR
			--if ( UnidadNegocio not in (1,6,7) ) then
			if ( _unidadnegocio.id_unid_negocio not in (1,6,7) ) then

				select into NegocioArray campo_compara from tem.tabla_array where useruse = AgenteExt and campo_compara = CarteraGeneral.negocio and modulo_cartera = 'SEGUIMIENTO';

				--.::PRIMER CASO::.--
				if ( FirstTime = 'First' ) then

					insert into tem.tabla_array (useruse, dstrct, modulo_cartera, creation_date, campo_compara) values(AgenteExt, 'FINV', 'SEGUIMIENTO', now(), CarteraGeneral.negocio);
					FirstTime = 'NoMore';

					--/NEGOCIO DE AVAL\
					SELECT INTO NegocioAvales cod_neg from negocios where negocio_rel = CarteraGeneral.negocio;

					IF FOUND THEN

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
						and fc.valor_saldo > 0
						and fc.reg_status = ''
						and fc.dstrct = 'FINV'
						and fc.tipo_documento in ('FAC','NDC')
						and substring(fc.documento,1,2) not in ('CP','FF','DF')
						and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						and fc.negasoc = NegocioAvales.cod_neg;

						--_SumDebidoCobrar = _SumDebidoCobrar + SumaDeAval.valor_asignado;
						--CarteraGeneral.debido_cobrar = _SumDebidoCobrar;
						CarteraGeneral.debido_cobrar = COALESCE(CarteraGeneral.debido_cobrar,0) + COALESCE(SumaDeAval.valor_asignado,0);
						CarteraGeneral.valor_asignado = COALESCE(CarteraGeneral.valor_asignado,0) + COALESCE(SumaDeAval.valor_asignado,0);

						--RECAUDO Y ENTIDAD DEL PAGO
						select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, NegocioAvales.cod_neg, '');

						if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
							CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
						end if;

					END IF;

					--/NEGOCIO DE SEGURO\
					raise notice 'NegocioSeguro: %', CarteraGeneral.negocio;
					FOR NegocioSeguros IN SELECT cod_neg from negocios where negocio_rel_seguro = CarteraGeneral.negocio LOOP

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
						and fc.valor_saldo > 0
						and fc.reg_status = ''
						and fc.dstrct = 'FINV'
						and fc.tipo_documento in ('FAC','NDC')
						and substring(fc.documento,1,2) not in ('CP','FF','DF')
						and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						and fc.negasoc = NegocioSeguros.cod_neg;

						CarteraGeneral.debido_cobrar = COALESCE(CarteraGeneral.debido_cobrar,0) + COALESCE(SumaDeAval.valor_asignado,0);
						CarteraGeneral.valor_asignado = COALESCE(CarteraGeneral.valor_asignado,0) + COALESCE(SumaDeAval.valor_asignado,0);

						--RECAUDO Y ENTIDAD DEL PAGO
						select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, NegocioSeguros.cod_neg, '');
						--raise notice 'EL PAGO DEL AVAL ES DE: %, PeriodoAsignacion: %, cod_neg: %',Rs_ResultPay.rs_ingresoxCuota, PeriodoAsignacion::varchar, NegocioAvales.cod_neg;
						if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
							CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
						end if;


						---|vencimiento|---
						/*
						SELECT INTO NegocioVencimientoSeguro
							maxdia as dias_vencidos,
							CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
							     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
							     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
							     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
							     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
							     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
							     WHEN maxdia >= 1 THEN '2- 1 A 30'
							     WHEN maxdia <= 0 THEN '1- CORRIENTE'
							ELSE '0' END AS vencimiento_mayor
						FROM (

							SELECT
							(FechaCortePeriodo::date-min(fra.fecha_vencimiento))::numeric AS maxdia
							FROM con.foto_cartera fra
							WHERE fra.valor_saldo > 0
							      AND fra.reg_status = ''
							      AND fra.tipo_documento in ('FAC','NDC')
							      AND fra.periodo_lote = PeriodoAsignacion
							      AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
							      AND substring(fra.documento,1,2) not in ('CP','FF','DF')
							      AND fra.negasoc = NegocioSeguros.cod_neg
						) c;

						IF FOUND THEN

							if ( NegocioVencimientoSeguro.dias_vencidos > CarteraGeneral.dias_vencidos ) then
								CarteraGeneral.dias_vencidos = NegocioVencimientoSeguro.dias_vencidos;
								CarteraGeneral.vencimiento_mayor = NegocioVencimientoSeguro.vencimiento_mayor;
								RAISE NOTICE 'Primero: %', NegocioVencimientoSeguro.dias_vencidos;
							end if;

						END IF;
						*/
						---|vencimiento|---


					END LOOP;

					--/NEGOCIO DE GPS\
					raise notice 'NegocioGps: %', CarteraGeneral.negocio;
					SELECT INTO NegocioGps cod_neg from negocios where negocio_rel_gps = CarteraGeneral.negocio;

					IF FOUND THEN

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
						and fc.valor_saldo > 0
						and fc.reg_status = ''
						and fc.dstrct = 'FINV'
						and fc.tipo_documento in ('FAC','NDC')
						and substring(fc.documento,1,2) not in ('CP','FF','DF')
						and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						and fc.negasoc = NegocioGps.cod_neg;

						CarteraGeneral.debido_cobrar = COALESCE(CarteraGeneral.debido_cobrar,0) + COALESCE(SumaDeAval.valor_asignado,0);
						CarteraGeneral.valor_asignado = COALESCE(CarteraGeneral.valor_asignado,0) + COALESCE(SumaDeAval.valor_asignado,0);

						--RECAUDO Y ENTIDAD DEL PAGO
						select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, NegocioGps.cod_neg, '');
						--raise notice 'EL PAGO DEL AVAL ES DE: %, PeriodoAsignacion: %, cod_neg: %',Rs_ResultPay.rs_ingresoxCuota, PeriodoAsignacion::varchar, NegocioAvales.cod_neg;
						if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
							CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
						end if;

					END IF;

				--.::SEGUNDO CASO::.--
				elsif ( NOT FOUND ) then

					insert into tem.tabla_array (useruse, dstrct, modulo_cartera, creation_date, campo_compara) values(AgenteExt, 'FINV', 'SEGUIMIENTO', now(), CarteraGeneral.negocio);

					--/NEGOCIO DE AVAL\
					SELECT INTO NegocioAvales cod_neg from negocios where negocio_rel = CarteraGeneral.negocio;

					IF FOUND THEN

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
						and fc.valor_saldo > 0
						and fc.reg_status = ''
						and fc.dstrct = 'FINV'
						and fc.tipo_documento in ('FAC','NDC')
						and substring(fc.documento,1,2) not in ('CP','FF','DF')
						and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						and fc.negasoc = NegocioAvales.cod_neg;

						--_SumDebidoCobrar = _SumDebidoCobrar + SumaDeAval.valor_asignado;
						--CarteraGeneral.debido_cobrar = _SumDebidoCobrar;
						CarteraGeneral.debido_cobrar = COALESCE(CarteraGeneral.debido_cobrar,0) + COALESCE(SumaDeAval.valor_asignado,0);
						CarteraGeneral.valor_asignado = COALESCE(CarteraGeneral.valor_asignado,0) + COALESCE(SumaDeAval.valor_asignado,0);

						--RECAUDO Y ENTIDAD DEL PAGO
						select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, NegocioAvales.cod_neg, '');

						if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
							CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
						end if;

					END IF;

					--/NEGOCIO DE SEGURO\
					raise notice 'NegocioSeguro: %', CarteraGeneral.negocio;
					FOR NegocioSeguros IN SELECT cod_neg from negocios where negocio_rel_seguro = CarteraGeneral.negocio LOOP

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
						and fc.valor_saldo > 0
						and fc.reg_status = ''
						and fc.dstrct = 'FINV'
						and fc.tipo_documento in ('FAC','NDC')
						and substring(fc.documento,1,2) not in ('CP','FF','DF')
						and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						and fc.negasoc = NegocioSeguros.cod_neg;

						CarteraGeneral.debido_cobrar = COALESCE(CarteraGeneral.debido_cobrar,0) + COALESCE(SumaDeAval.valor_asignado,0);
						CarteraGeneral.valor_asignado = COALESCE(CarteraGeneral.valor_asignado,0) + COALESCE(SumaDeAval.valor_asignado,0);

						--RECAUDO Y ENTIDAD DEL PAGO
						select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, NegocioSeguros.cod_neg, '');
						--raise notice 'EL PAGO DEL AVAL ES DE: %, PeriodoAsignacion: %, cod_neg: %',Rs_ResultPay.rs_ingresoxCuota, PeriodoAsignacion::varchar, NegocioAvales.cod_neg;
						if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
							CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
						end if;


						---|vencimiento|---
						SELECT INTO NegocioVencimientoSeguro
							maxdia as dias_vencidos,
							CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
							     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
							     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
							     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
							     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
							     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
							     WHEN maxdia >= 1 THEN '2- 1 A 30'
							     WHEN maxdia <= 0 THEN '1- CORRIENTE'
							ELSE '0' END AS vencimiento_mayor
						FROM (

							SELECT
							(FechaCortePeriodo::date-min(fra.fecha_vencimiento))::numeric AS maxdia
							FROM con.foto_cartera fra
							WHERE fra.valor_saldo > 0
							      AND fra.reg_status = ''
							      AND fra.tipo_documento in ('FAC','NDC')
							      AND fra.periodo_lote = PeriodoAsignacion
							      AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
							      AND substring(fra.documento,1,2) not in ('CP','FF','DF')
							      AND fra.negasoc = NegocioSeguros.cod_neg
						) c;

						IF FOUND THEN

							if ( NegocioVencimientoSeguro.dias_vencidos > CarteraGeneral.dias_vencidos ) then
								--CarteraGeneral.dias_vencidos = NegocioVencimientoSeguro.dias_vencidos;
								--CarteraGeneral.vencimiento_mayor = NegocioVencimientoSeguro.vencimiento_mayor;
								RAISE NOTICE 'Primero: %', NegocioVencimientoSeguro.dias_vencidos;
							end if;

						END IF;
						---|vencimiento|---

					END LOOP;

					--/NEGOCIO DE GPS\
					raise notice 'NegocioGps: %', CarteraGeneral.negocio;
					SELECT INTO NegocioGps cod_neg from negocios where negocio_rel_gps = CarteraGeneral.negocio;

					IF FOUND THEN

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
						and fc.valor_saldo > 0
						and fc.reg_status = ''
						and fc.dstrct = 'FINV'
						and fc.tipo_documento in ('FAC','NDC')
						and substring(fc.documento,1,2) not in ('CP','FF','DF')
						and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						and fc.negasoc = NegocioGps.cod_neg;

						CarteraGeneral.debido_cobrar = COALESCE(CarteraGeneral.debido_cobrar,0) + COALESCE(SumaDeAval.valor_asignado,0);
						CarteraGeneral.valor_asignado = COALESCE(CarteraGeneral.valor_asignado,0) + COALESCE(SumaDeAval.valor_asignado,0);

						--RECAUDO Y ENTIDAD DEL PAGO
						select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, NegocioGps.cod_neg, '');
						--raise notice 'EL PAGO DEL AVAL ES DE: %, PeriodoAsignacion: %, cod_neg: %',Rs_ResultPay.rs_ingresoxCuota, PeriodoAsignacion::varchar, NegocioAvales.cod_neg;
						if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
							CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
						end if;

					END IF;


				--.::TERCER CASO::.--
				else

					---//---

					raise notice 'NegocioSeguro: %', CarteraGeneral.negocio;
					SELECT INTO NegocioSeguros cod_neg from negocios where negocio_rel_seguro = CarteraGeneral.negocio;

					---|vencimiento|---
					SELECT INTO NegocioVencimientoSeguro
						maxdia as dias_vencidos,
						CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
						     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
						     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
						     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
						     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
						     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
						     WHEN maxdia >= 1 THEN '2- 1 A 30'
						     WHEN maxdia <= 0 THEN '1- CORRIENTE'
						ELSE '0' END AS vencimiento_mayor
					FROM (

						SELECT
						(FechaCortePeriodo::date-min(fra.fecha_vencimiento))::numeric AS maxdia
						FROM con.foto_cartera fra
						WHERE fra.valor_saldo > 0
						      AND fra.reg_status = ''
						      AND fra.tipo_documento in ('FAC','NDC')
						      AND fra.periodo_lote = PeriodoAsignacion
						      AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						      AND substring(fra.documento,1,2) not in ('CP','FF','DF')
						      AND fra.negasoc = NegocioSeguros.cod_neg
					) c;

					IF FOUND THEN

						if ( NegocioVencimientoSeguro.dias_vencidos > CarteraGeneral.dias_vencidos ) then
							--CarteraGeneral.dias_vencidos = NegocioVencimientoSeguro.dias_vencidos;
							--CarteraGeneral.vencimiento_mayor = NegocioVencimientoSeguro.vencimiento_mayor;
							RAISE NOTICE 'Primero: %', NegocioVencimientoSeguro.dias_vencidos;
						end if;

					ELSE

						raise notice 'NegocioGps: %', CarteraGeneral.negocio;
						SELECT INTO NegocioGps cod_neg from negocios where negocio_rel_gps = CarteraGeneral.negocio;

						SELECT INTO NegocioVencimientoGps
							maxdia as dias_vencidos,
							CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
							     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
							     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
							     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
							     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
							     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
							     WHEN maxdia >= 1 THEN '2- 1 A 30'
							     WHEN maxdia <= 0 THEN '1- CORRIENTE'
							ELSE '0' END AS vencimiento_mayor
						FROM (

							SELECT
							(FechaCortePeriodo::date-min(fra.fecha_vencimiento))::numeric AS maxdia
							FROM con.foto_cartera fra
							WHERE fra.valor_saldo > 0
							      AND fra.reg_status = ''
							      AND fra.tipo_documento in ('FAC','NDC')
							      AND fra.periodo_lote = PeriodoAsignacion
							      AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
							      AND substring(fra.documento,1,2) not in ('CP','FF','DF')
							      AND fra.negasoc = NegocioGps.cod_neg
						) c;

						IF FOUND THEN

							if ( NegocioVencimientoGps.dias_vencidos > CarteraGeneral.dias_vencidos ) then
								--CarteraGeneral.dias_vencidos = NegocioVencimientoGps.dias_vencidos;
								--CarteraGeneral.vencimiento_mayor = NegocioVencimientoGps.vencimiento_mayor;
								RAISE NOTICE 'Primero: %', NegocioVencimientoGps.dias_vencidos;
							end if;

						END IF;

					END IF;
					---|vencimiento|---

					---//---

				end if;
			end if;


			SELECT INTO ClienteRec nomcli,direccion,ciudad,case when telefono is null then '0' else telefono end as telefono,telcontacto FROM cliente WHERE nit = CarteraGeneral.cedula;
			CarteraGeneral.nombre_cliente = ClienteRec.nomcli;
			CarteraGeneral.direccion = ClienteRec.direccion;
			CarteraGeneral.ciudad = ClienteRec.ciudad;
			CarteraGeneral.telefono = ClienteRec.telefono;
			CarteraGeneral.telcontacto = ClienteRec.telcontacto;

			IF ( unidadnegocio = 22 ) THEN
				SELECT INTO CarteraGeneral.pagaduria coalesce(razon_social,'') from pagadurias p
				INNER JOIN  negocios neg ON neg.nit_tercero = p.documento
				where neg.cod_neg = CarteraGeneral.negocio;
			END IF;

			RETURN NEXT CarteraGeneral;

		END LOOP;

	ELSE

		FOR CarteraGeneral IN

			select
				fca.tercero::varchar as cedula,
				fca.nombre_tercero::varchar as nombre_cliente,
				fca.direccion_contacto::varchar as direccion,
				'BARRANQUILLA'::varchar as ciudad,
				''::varchar as telefono,
				fca.telcontacto::varchar as telcontacto,
				negasoc::varchar as negocio,
				id_convenio::varchar,
				''::varchar as pagaduria,
				''::varchar as nm_convenio,
				num_doc_fen::varchar as cuota,
				fcg.valor_factura::numeric as valor_asignado,
				fecha_vencimiento::date,
				replace(substring(fecha_vencimiento,1,7),'-','')::numeric as periodo_vcto,
				(
				CASE WHEN diasvencidos_corte >= 365 THEN '8- MAYOR A 1 ANIO'
				     WHEN diasvencidos_corte >= 181 THEN '7- ENTRE 180 Y 360'
				     WHEN diasvencidos_corte >= 121 THEN '6- ENTRE 121 Y 180'
				     WHEN diasvencidos_corte >= 91 THEN '5- ENTRE 91 Y 120'
				     WHEN diasvencidos_corte >= 61 THEN '4- ENTRE 61 Y 90'
				     WHEN diasvencidos_corte >= 31 THEN '3- ENTRE 31 Y 60'
				     WHEN diasvencidos_corte >= 1 THEN '2- 1 A 30'
				     WHEN diasvencidos_corte <= 0 THEN '1- CORRIENTE'
					ELSE '0' END
				)::varchar as vencimiento_mayor,
				(fecha_corte_pg::date-fecha_vencimiento)::numeric AS dias_vencidos,
				''::varchar as status,
				''::varchar as status_vencimiento,
				fcg.valor_factura::numeric as debido_cobrar,
				0::numeric as recaudosxcuota_fiducia,
				0::numeric as recaudosxcuota_fenalco,
				fcg.valor_abono::numeric as recaudosxcuota,
				agente::varchar
			--select *
			from con.foto_cartera_geotech fcg, con.foto_cartera_apoteosys fca
			where fca.factura_geotech = fcg.documento
				and periodo_lote = PeriodoAsignacion
				--and valor_saldo > 0
				and fcg.reg_status = ''
				and fcg.dstrct = 'GEOT'
				and fcg.tipo_documento = 'FACN'
				and fca.tercero=nitCliente
				and fcg.id_convenio = (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
			order by negasoc
		LOOP

			RETURN NEXT CarteraGeneral;

		END LOOP;

	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_seguimientocarteraxclientehcg(numeric, character varying, character varying, character varying)
  OWNER TO postgres;
