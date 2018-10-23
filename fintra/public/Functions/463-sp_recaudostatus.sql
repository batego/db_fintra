-- Function: sp_recaudostatus(numeric, character varying, character varying)

-- DROP FUNCTION sp_recaudostatus(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_recaudostatus(periodoasignacion numeric, unidadnegocio character varying, agenteext character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraTotales record;
	CarteraGeneral record;
	CarteraWtramoAnterior record;
	BankPay record;

	SumaDeAval record;
	Rs_ResultPay record;
	NegocioSeguros record;
	NegocioGps record;
	NegocioArray record;

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
	FirstTime varchar;

BEGIN

	if ( substring(PeriodoAsignacion,5) = '01' ) then
		PeriodoTramo = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
	end if;

	--PeriodoTramo = PeriodoAsignacion::numeric - 1;
	PeriodoTramoAnterior = PeriodoTramo::numeric - 1;

	_TramoAnterior = PeriodoAsignacion::numeric - 1;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	select into FechaCortePeriodoAnt to_char(to_timestamp(substring(PeriodoTramoAnterior,1,4)::numeric || '-' || to_char(substring(PeriodoTramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');

	raise notice 'fecha corte %',FechaCortePeriodo;

	DELETE FROM tem.tabla_array WHERE creation_date::date < now()::date and modulo_cartera = 'RECAUDO';
	DELETE FROM tem.tabla_array WHERE useruse = AgenteExt and modulo_cartera = 'RECAUDO';

	--NegocioArray = '';
	FirstTime = 'First';

	FOR CarteraGeneral IN

		select
			negasoc::varchar as negocio,
			num_doc_fen::varchar as cuota,
			SUM(valor_saldo)::numeric as valor_asignado,
			fecha_vencimiento::date,
			replace(substring(fecha_vencimiento,1,7),'-','')::numeric as periodo_vcto,
			(
			SELECT
				CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
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
			0::numeric as debido_cobrar,
			0::numeric as recaudosxcuota_fiducia,
			0::numeric as recaudosxcuota_fenalco,
			0::numeric as recaudosxcuota

		from con.foto_cartera
		where periodo_lote = PeriodoAsignacion
			and valor_saldo > 0
			and reg_status = ''
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('CP','FF','DF')
			and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_seguro = '') > 0
			and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel_gps = '') > 0
			--and negasoc = 'FA10382'
		group by negasoc, num_doc_fen,  fecha_vencimiento, periodo_vcto
		order by negasoc LOOP

		_SumDebidoCobrar = 0;
		Ingresoxcuota_fiducia = 0;
		Ingresoxcuota_fenalco = 0;
		IngresoxCuota = 0;

		--STATUS Y DEBIDO COBRAR
		if (CarteraGeneral.periodo_vcto = PeriodoAsignacion ) then

			SELECT INTO _SumDebidoCobrar valor from documentos_neg_aceptado where cod_neg = CarteraGeneral.negocio and item = CarteraGeneral.cuota;

			CarteraGeneral.status = 'A Vencer';
			CarteraGeneral.debido_cobrar = _SumDebidoCobrar;

		else
			if ( CarteraGeneral.dias_vencidos > 0 ) then

				CarteraGeneral.status = 'Vencido';
				CarteraGeneral.debido_cobrar = CarteraGeneral.valor_asignado;

			else
				SELECT INTO _SumDebidoCobrar valor from documentos_neg_aceptado where cod_neg = CarteraGeneral.negocio and item = CarteraGeneral.cuota;
				CarteraGeneral.status = 'Al Dia';
				CarteraGeneral.debido_cobrar = _SumDebidoCobrar;
			end if;
		end if;

		--RECAUDO Y ENTIDAD DEL PAGO
		select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, CarteraGeneral.negocio, CarteraGeneral.cuota);

		if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
			CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
		else
			CarteraGeneral.recaudosxcuota = 0;
		end if;

 		--VALIDADOR
 		if ( UnidadNegocio = 3 ) then

			select into NegocioArray campo_compara from tem.tabla_array where useruse = AgenteExt and campo_compara = CarteraGeneral.negocio and modulo_cartera = 'RECAUDO';

			--.::PRIMER CASO::.--
			if ( FirstTime = 'First' ) then

				insert into tem.tabla_array (useruse, dstrct, modulo_cartera, creation_date, campo_compara) values(AgenteExt, 'FINV', 'RECAUDO', now(), CarteraGeneral.negocio);
				FirstTime = 'NoMore';

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
					and fc.valor_saldo > 0
					and fc.reg_status = ''
					and fc.dstrct = 'FINV'
					and fc.tipo_documento in ('FAC','NDC')
					and substring(fc.documento,1,2) not in ('CP','FF','DF')
					and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
					and fc.negasoc = NegocioSeguros.cod_neg;

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

				insert into tem.tabla_array (useruse, dstrct, modulo_cartera, creation_date, campo_compara) values(AgenteExt, 'FINV', 'RECAUDO', now(), CarteraGeneral.negocio);

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
					and fc.valor_saldo > 0
					and fc.reg_status = ''
					and fc.dstrct = 'FINV'
					and fc.tipo_documento in ('FAC','NDC')
					and substring(fc.documento,1,2) not in ('CP','FF','DF')
					and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
					and fc.negasoc = NegocioSeguros.cod_neg;

					CarteraGeneral.valor_asignado = COALESCE(CarteraGeneral.valor_asignado,0) + COALESCE(SumaDeAval.valor_asignado,0);

					--RECAUDO Y ENTIDAD DEL PAGO
					select into Rs_ResultPay * from SP_PagoNegociosSeguimiento(PeriodoAsignacion::varchar, NegocioGps.cod_neg, '');
					--raise notice 'EL PAGO DEL AVAL ES DE: %, PeriodoAsignacion: %, cod_neg: %',Rs_ResultPay.rs_ingresoxCuota, PeriodoAsignacion::varchar, NegocioAvales.cod_neg;
					if ( Rs_ResultPay.rs_ingresoxCuota > 0 ) then
						CarteraGeneral.recaudosxcuota = COALESCE(CarteraGeneral.recaudosxcuota,0) + COALESCE(Rs_ResultPay.rs_ingresoxCuota,0);
					end if;

				END IF;

			end if;

		end if;

		RETURN NEXT CarteraGeneral;

	END LOOP;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_recaudostatus(numeric, character varying, character varying)
  OWNER TO postgres;
