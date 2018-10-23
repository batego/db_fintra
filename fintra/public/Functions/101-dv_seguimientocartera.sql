-- Function: dv_seguimientocartera(numeric, character varying)

-- DROP FUNCTION dv_seguimientocartera(numeric, character varying);

CREATE OR REPLACE FUNCTION dv_seguimientocartera(periodoasignacion numeric, agenteext character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraTotales record;
	CarteraGeneral record;
	CarteraWtramoAnterior record;
	ClienteRec record;
	BankPay record;
	FchLastPay record;

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

	MaxVel integer := 0;

	CadAgentes varchar;
	periodo_corte varchar;
	FechaCortePeriodo varchar;
	FechaCortePeriodoAnt varchar;
	StatusVcto varchar;
	UltimoPago varchar;
	NegocioArray record;
	FirstTime varchar;


	ReturnTabla varchar := '';

	miHoy date;

	UnidadNegocio varchar;

BEGIN

	if ( substring(PeriodoAsignacion,5) = '01' ) then
		PeriodoTramo = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
		_TramoAnterior = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
		_TramoAnterior = PeriodoAsignacion::numeric - 1;
	end if;

	--PeriodoTramo = PeriodoAsignacion::numeric - 1;
	PeriodoTramoAnterior = PeriodoTramo::numeric - 1;

	--_TramoAnterior = PeriodoAsignacion::numeric - 1;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	select into FechaCortePeriodoAnt to_char(to_timestamp(substring(PeriodoTramoAnterior,1,4)::numeric || '-' || to_char(substring(PeriodoTramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	raise notice 'PeriodoTramo: %,FechaCortePeriodo: %',PeriodoTramo,FechaCortePeriodo;

	miHoy = now()::date;

	--DELETE FROM tem.tabla_array WHERE useruse = AgenteExt RETURNING * INTO ReturnTabla;
	--SELECT * FROM tem.tabla_array;
	--raise notice 'ReturnTabla: %',ReturnTabla;

	DELETE FROM tem.tabla_array WHERE creation_date::date < now()::date and modulo_cartera = 'SEGUIMIENTO';
	DELETE FROM tem.tabla_array WHERE useruse = AgenteExt and modulo_cartera = 'SEGUIMIENTO';

	select into MaxVel min(id)
	from con.foto_cartera
	where periodo_lote = PeriodoAsignacion
		--and valor_saldo > 0
		and reg_status = ''
		and dstrct = 'FINV'
		and tipo_documento in ('FAC','NDC')
		and substring(documento,1,2) not in ('CP','FF','DF');
		--and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio));


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
			(select sp_uneg_negocio_name(negasoc)) as unidad_negocio,
			id_convenio::varchar,
			''::varchar as pagaduria,
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
					  AND fra.id >= MaxVel
				 GROUP BY negasoc

			) tabla2
			)::varchar as vencimiento_mayor,
			(FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,

			(SELECT substring(max(fecha_vencimiento),9)::numeric
			FROM con.foto_cartera fra
			WHERE fra.dstrct = 'FINV'
			  --AND fra.valor_saldo > 0
			  AND fra.reg_status = ''
			  AND fra.negasoc = con.foto_cartera.negasoc
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF','CA','MI')
			  AND fra.periodo_lote = PeriodoAsignacion
			  AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
			  AND fra.id >= MaxVel
			GROUP BY negasoc) as dia_pago,

			''::varchar as status,
			''::varchar as status_vencimiento,
			0::numeric as debido_cobrar,
			0::numeric as recaudosxcuota_fiducia,
			0::numeric as recaudosxcuota_fenalco,
			0::numeric as recaudosxcuota,
			agente::varchar,
			agente_campo::varchar

		from con.foto_cartera
		where periodo_lote = PeriodoAsignacion
			and id >= MaxVel
			and valor_saldo > 0
			and reg_status = ''
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('CP','FF','DF')
			--and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_seguro = '') > 0
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_gps = '') > 0
			--and negasoc in ('LB00083') --('FA00350','FA04420')
		group by id_convenio, cedula, nombre_cliente, direccion, ciudad, telefono, negasoc, num_doc_fen, vencimiento_mayor, fecha_vencimiento, periodo_vcto, agente, agente_campo
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
		raise notice 'PeriodoAsignacion: %, negocio: %, cuota: %', PeriodoAsignacion::varchar, CarteraGeneral.negocio, CarteraGeneral.cuota;
		select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, CarteraGeneral.negocio, CarteraGeneral.cuota);

		CarteraGeneral.recaudosxcuota_fiducia = Rs_ResultPay.rs_ingresoxcuota_fiducia;
		CarteraGeneral.recaudosxcuota_fenalco = Rs_ResultPay.rs_ingresoxcuota_fenalco;
		CarteraGeneral.recaudosxcuota = Rs_ResultPay.rs_ingresoxCuota;

		raise notice 'recaudosxcuota_fiducia: %, recaudosxcuota_fenalco: %, recaudosxcuota: %', CarteraGeneral.recaudosxcuota_fiducia, CarteraGeneral.recaudosxcuota_fenalco, CarteraGeneral.recaudosxcuota;

		if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
			CarteraGeneral.recaudosxcuota = Rs_ResultPay.rs_ingresoxCuota;
		else
			CarteraGeneral.recaudosxcuota = 0;
		end if;


		select into UnidadNegocio sp_uneg_negocio(CarteraGeneral.negocio);
		raise notice 'UnidadNegocio: %', UnidadNegocio;
		raise notice 'CarteraGeneral.negocio: %', CarteraGeneral.negocio;

 		--VALIDADOR
 		if ( UnidadNegocio not in ('1', '6', '7', '21', '22') ) then

			select into NegocioArray campo_compara from tem.tabla_array where useruse = AgenteExt and campo_compara = CarteraGeneral.negocio and modulo_cartera = 'SEGUIMIENTO';

			--.::PRIMER CASO::.--
			if ( FirstTime = 'First' ) then

				raise notice 'Entra First';
				insert into tem.tabla_array (useruse, dstrct, modulo_cartera, creation_date, campo_compara) values(AgenteExt, 'FINV', 'SEGUIMIENTO', now(), CarteraGeneral.negocio);

                                FirstTime = 'NoMore';

				--/NEGOCIO DE AVAL\
				raise notice 'NegocioAval: %', CarteraGeneral.negocio;
				SELECT INTO NegocioAvales cod_neg from negocios where negocio_rel = CarteraGeneral.negocio;

				IF FOUND THEN

					SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
					FROM con.foto_cartera fc
					WHERE fc.periodo_lote = PeriodoAsignacion
						--and fc.id >= MaxVel
						and fc.valor_saldo > 0
						and fc.reg_status = ''
						and fc.dstrct = 'FINV'
						and fc.tipo_documento in ('FAC','NDC')
						and substring(fc.documento,1,2) not in ('CP','FF','DF')
						and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						and fc.negasoc = NegocioAvales.cod_neg;

					CarteraGeneral.debido_cobrar = COALESCE(CarteraGeneral.debido_cobrar,0) + COALESCE(SumaDeAval.valor_asignado,0);
					CarteraGeneral.valor_asignado = COALESCE(CarteraGeneral.valor_asignado,0) + COALESCE(SumaDeAval.valor_asignado,0);

					--RECAUDO Y ENTIDAD DEL PAGO
					select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, NegocioAvales.cod_neg, '');
					--raise notice 'EL PAGO DEL AVAL ES DE: %, PeriodoAsignacion: %, cod_neg: %',Rs_ResultPay.rs_ingresoxCuota, PeriodoAsignacion::varchar, NegocioAvales.cod_neg;
					if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
						CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
					end if;

				END IF;

				IF ( UnidadNegocio = '3' ) THEN

					--/NEGOCIO DE SEGURO\
					raise notice 'NegocioSeguro: %', CarteraGeneral.negocio;
					FOR NegocioSeguros IN SELECT cod_neg from negocios where negocio_rel_seguro = CarteraGeneral.negocio LOOP

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
							and fc.id >= MaxVel
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

					END LOOP;

					--/NEGOCIO DE GPS\
					raise notice 'NegocioGps: %', CarteraGeneral.negocio;
					SELECT INTO NegocioGps cod_neg from negocios where negocio_rel_gps = CarteraGeneral.negocio;

					IF FOUND THEN

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
							and fc.id >= MaxVel
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
				END IF;

			--.::SEGUNDO CASO::.--
			elsif ( NOT FOUND ) then

				raise notice 'NOT FOUND';
				insert into tem.tabla_array (useruse, dstrct, modulo_cartera, creation_date, campo_compara) values(AgenteExt, 'FINV', 'SEGUIMIENTO', now(), CarteraGeneral.negocio);

				--NEGOCIO DE AVAL
				raise notice 'NegocioAval: %', CarteraGeneral.negocio;
				SELECT INTO NegocioAvales cod_neg from negocios where negocio_rel = CarteraGeneral.negocio;

				IF FOUND THEN

					SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
					from con.foto_cartera fc
					where fc.periodo_lote = PeriodoAsignacion
						and fc.id >= MaxVel
						and fc.valor_saldo > 0
						and fc.reg_status = ''
						and fc.dstrct = 'FINV'
						and fc.tipo_documento in ('FAC','NDC')
						and substring(fc.documento,1,2) not in ('CP','FF','DF')
						and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						and fc.negasoc = NegocioAvales.cod_neg;

					CarteraGeneral.debido_cobrar = COALESCE(CarteraGeneral.debido_cobrar,0) + COALESCE(SumaDeAval.valor_asignado,0);
					CarteraGeneral.valor_asignado = COALESCE(CarteraGeneral.valor_asignado,0) + COALESCE(SumaDeAval.valor_asignado,0);

					--RECAUDO Y ENTIDAD DEL PAGO
					select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, NegocioAvales.cod_neg, '');

					if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
						CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
					end if;

				END IF;

				IF ( UnidadNegocio = '3' ) THEN

					--/NEGOCIO DE SEGURO\
					raise notice 'NegocioSeguro: %', CarteraGeneral.negocio;
					FOR NegocioSeguros IN SELECT cod_neg from negocios where negocio_rel_seguro = CarteraGeneral.negocio LOOP

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
							and fc.id >= MaxVel
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


					END LOOP;

					--/NEGOCIO DE GPS\
					raise notice 'NegocioGps: %', CarteraGeneral.negocio;
					SELECT INTO NegocioGps cod_neg from negocios where negocio_rel_gps = CarteraGeneral.negocio;

					IF FOUND THEN

						SELECT INTO SumaDeAval sum(valor_saldo)::numeric as valor_asignado
						from con.foto_cartera fc
						where fc.periodo_lote = PeriodoAsignacion
							and fc.id >= MaxVel
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

				END IF;

			end if;

		end if;

		SELECT INTO ClienteRec nomcli,direccion,ciudad,case when telefono is null then '0' else telefono end as telefono,telcontacto FROM cliente WHERE nit = CarteraGeneral.cedula;
		CarteraGeneral.nombre_cliente = ClienteRec.nomcli;
		CarteraGeneral.direccion = ClienteRec.direccion;
		CarteraGeneral.ciudad = ClienteRec.ciudad;
		CarteraGeneral.telefono = ClienteRec.telefono;
		CarteraGeneral.telcontacto = ClienteRec.telcontacto;

	       IF ( UnidadNegocio = '22' ) THEN
			SELECT INTO CarteraGeneral.pagaduria coalesce(razon_social,'') from pagadurias p
			INNER JOIN  negocios neg ON neg.nit_tercero = p.documento
			where neg.cod_neg = CarteraGeneral.negocio;
	       END IF;

		RETURN NEXT CarteraGeneral;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_seguimientocartera(numeric, character varying)
  OWNER TO postgres;
