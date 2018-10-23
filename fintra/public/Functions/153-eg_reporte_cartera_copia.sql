-- Function: eg_reporte_cartera_copia(numeric, character varying, character varying)

-- DROP FUNCTION eg_reporte_cartera_copia(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_reporte_cartera_copia(periodoasignacion numeric, unidadnegocio character varying, agenteext character varying)
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
	NegocioSegurosGps record;
	SumaDeAval record;

	PercValorAsignado numeric;
	PercCantAsignado numeric;
	_TramoAnterior numeric;
	PeriodoTramo numeric;
	PeriodoTramoAnterior numeric;
	_SumDebidoCobrar numeric;
	Ingresoxcuota_fiducia numeric;
	Ingresoxcuota_fenalco numeric;
	IngresoxCuota numeric;

        _valor_capital numeric;
        _valor_interes numeric;
        _valor_cat numeric;

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

	DELETE FROM tem.tabla_array WHERE useruse = AgenteExt;

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
                        documento::varchar as documento,
			con.foto_cartera.id_convenio::varchar,
                        neg.nro_docs::varchar,
			neg.vr_desembolso::numeric as vr_desembolso,
			0::numeric as valor_capital,
			0::numeric as valor_interes,
                        0::numeric as saldo_cat,
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
			GROUP BY negasoc) as dia_pago,

			''::varchar as status,
			''::varchar as status_vencimiento,
			0::numeric as debido_cobrar,
			0::numeric as recaudosxcuota_fiducia,
			0::numeric as recaudosxcuota_fenalco,
			0::numeric as recaudosxcuota,
			agente::varchar

		from con.foto_cartera
                INNER JOIN negocios as neg on (neg.cod_neg=con.foto_cartera.negasoc)
		where periodo_lote = PeriodoAsignacion
		and valor_saldo > 0
		and reg_status = ''
		and dstrct = 'FINV'
		and tipo_documento in ('FAC','NDC')
		and substring(documento,1,2) not in ('CP','FF','DF')
		and con.foto_cartera.id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
		and (SELECT count(0) from negocios where cod_neg = con.foto_cartera.negasoc and negocio_rel = '') > 0
		and (SELECT count(0) FROM tem.seguros_vehiculos WHERE ciclo_fecha = '2014-07-29' AND negocio_seguro = con.foto_cartera.negasoc) = 0
		--and negasoc = 'MC00001'
		group by con.foto_cartera.id_convenio,neg.nro_docs, neg.vr_desembolso, cedula, nombre_cliente, direccion, ciudad, telefono, negasoc,documento, num_doc_fen, vencimiento_mayor, fecha_vencimiento, periodo_vcto, agente
		order by negasoc LOOP

		--aqui buscamos el capital e interes actual micro.
		IF(unidadnegocio='1')THEN
			/*
			SELECT INTO _valor_capital sum(valor_saldo) FROM con.factura  where negasoc=CarteraGeneral.negocio and documento like 'MC%'
                        and valor_saldo > 0 and reg_status = '' and dstrct = 'FINV' 	and tipo_documento in ('FAC','NDC') and substring(documento,1,2) not in ('CP','FF','DF') ;
			SELECT INTO _valor_interes sum(valor_saldo) FROM con.factura  where negasoc=CarteraGeneral.negocio and documento like 'MI%'
                        and valor_saldo > 0 and reg_status = '' and dstrct = 'FINV' 	and tipo_documento in ('FAC','NDC') and substring(documento,1,2) not in ('CP','FF','DF') ;
                        SELECT INTO _valor_cat sum(valor_saldo) FROM con.factura  where negasoc=CarteraGeneral.negocio and documento like 'CA%'
                        and valor_saldo > 0 and reg_status = '' and dstrct = 'FINV' 	and tipo_documento in ('FAC','NDC') and substring(documento,1,2) not in ('CP','FF','DF') ;

			CarteraGeneral.valor_capital:=_valor_capital;
			CarteraGeneral.valor_interes:=_valor_interes;
                        CarteraGeneral.saldo_cat:=_valor_cat;
			*/
                        SELECT INTO _valor_capital sum(valor_saldo) FROM con.factura  where negasoc=CarteraGeneral.negocio and documento =CarteraGeneral.documento
                         and valor_saldo > 0 and reg_status = '' and dstrct = 'FINV' 	and tipo_documento in ('FAC','NDC') and substring(documento,1,2) not in ('CP','FF','DF') ;
			CarteraGeneral.valor_capital:=_valor_capital;

		END IF;

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
		FOR BankPay IN
			select i.num_ingreso, id.factura, branch_code, bank_account_no, i.cuenta, sum(id.valor_ingreso) as mingreso
			from con.ingreso_detalle id, con.ingreso i
			where id.num_ingreso = i.num_ingreso
			and id.dstrct = i.dstrct
			and id.tipo_documento = i.tipo_documento
			and id.dstrct = 'FINV'
			and id.tipo_documento in ('ING','ICA')
			and i.reg_status = ''
			and id.documento in (SELECT documento from con.factura where negasoc = CarteraGeneral.negocio and num_doc_fen = CarteraGeneral.cuota and tipo_documento in ('FAC','NDC') and reg_status = '' and devuelta != 'S' and corficolombiana != 'S')
			and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodoAsignacion::varchar
			group by i.num_ingreso, id.factura, branch_code, bank_account_no, i.cuenta LOOP

			if ( substring(BankPay.num_ingreso,1,2) = 'IA' ) then

				if ( substring(BankPay.factura,1,2) in ('FC','FG','FI') ) then

					--Ingresoxcuota_fiducia = Ingresoxcuota_fiducia + BankPay.mingreso;

					if ( (BankPay.branch_code != '' and BankPay.bank_account_no != '') or BankPay.cuenta in ('11050501','13809501') ) then
						IngresoxCuota = IngresoxCuota + BankPay.mingreso;
					else
						Ingresoxcuota_fiducia = Ingresoxcuota_fiducia + BankPay.mingreso;
					end if;


				elsif ( substring(BankPay.factura,1,2) in ('CC','CG','CI') ) then

					if ( (BankPay.branch_code != '' and BankPay.bank_account_no != '') or BankPay.cuenta in ('11050501','13809501') ) then
						IngresoxCuota = IngresoxCuota + BankPay.mingreso;
					else
						Ingresoxcuota_fenalco = Ingresoxcuota_fenalco + BankPay.mingreso;
					end if;

				elsif ( substring(BankPay.factura,1,2) in ('AP','MC','MI','CA') ) then

					IngresoxCuota = IngresoxCuota + BankPay.mingreso;

				end if;

			elsif ( substring(BankPay.num_ingreso,1,2) = 'IC' ) then

				IngresoxCuota = IngresoxCuota + BankPay.mingreso;

			end if;

			CarteraGeneral.recaudosxcuota_fiducia = Ingresoxcuota_fiducia;
			CarteraGeneral.recaudosxcuota_fenalco = Ingresoxcuota_fenalco;
			CarteraGeneral.recaudosxcuota = IngresoxCuota;

		END LOOP;

		if ( IngresoxCuota > 0 ) then
			CarteraGeneral.recaudosxcuota = IngresoxCuota;
		   else
			CarteraGeneral.recaudosxcuota = 0;
		end if;

 		--VALIDADOR

 		if ( UnidadNegocio not in (1,6,7) ) then

			select into NegocioArray campo_compara from tem.tabla_array where useruse = AgenteExt and campo_compara = CarteraGeneral.negocio;

			if ( FirstTime = 'First' ) then

				insert into tem.tabla_array (useruse, campo_compara) values(AgenteExt, CarteraGeneral.negocio);
				FirstTime = 'NoMore';

				--NEGOCIO DE AVAL
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

					---//---

					SELECT INTO NegocioSegurosGps
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
						FROM tem.seguros_vehiculos s, con.foto_cartera fra
						WHERE s.negocio_seguro = fra.negasoc--s.negocio_seguro = fra.negasoc
						      AND ciclo_fecha = '2014-07-29'
						      AND fra.valor_saldo > 0
						      AND fra.reg_status = ''
						      AND fra.tipo_documento in ('FAC','NDC')
						      AND fra.periodo_lote = PeriodoAsignacion
						      AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						      AND substring(fra.documento,1,2) not in ('CP','FF','DF') --Se cambio?
						      AND negocio_vehiculo = CarteraGeneral.negocio
						GROUP BY s.negocio_vehiculo
					) c;

					IF FOUND THEN

						if ( NegocioSegurosGps.dias_vencidos > CarteraGeneral.dias_vencidos ) then
							CarteraGeneral.dias_vencidos = NegocioSegurosGps.dias_vencidos;
							CarteraGeneral.vencimiento_mayor = NegocioSegurosGps.vencimiento_mayor;
							RAISE NOTICE 'Primero: %', NegocioSegurosGps.dias_vencidos;
						end if;


					END IF;

					---//---


				END IF;

			elsif ( NOT FOUND ) then

				insert into tem.tabla_array (useruse, campo_compara) values(AgenteExt, CarteraGeneral.negocio);

				--NEGOCIO DE AVAL
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

					---//---

					SELECT INTO NegocioSegurosGps
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
						FROM tem.seguros_vehiculos s, con.foto_cartera fra
						WHERE s.negocio_seguro = fra.negasoc--s.negocio_seguro = fra.negasoc
						      AND ciclo_fecha = '2014-07-29'
						      AND fra.valor_saldo > 0
						      AND fra.reg_status = ''
						      AND fra.tipo_documento in ('FAC','NDC')
						      AND fra.periodo_lote = PeriodoAsignacion
						      AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
						      AND substring(fra.documento,1,2) not in ('CP','FF','DF') --Se cambio?
						      AND negocio_vehiculo = CarteraGeneral.negocio
						GROUP BY s.negocio_vehiculo
					) c;

					IF FOUND THEN

						if ( NegocioSegurosGps.dias_vencidos > CarteraGeneral.dias_vencidos ) then
							CarteraGeneral.dias_vencidos = NegocioSegurosGps.dias_vencidos;
							CarteraGeneral.vencimiento_mayor = NegocioSegurosGps.vencimiento_mayor;
							RAISE NOTICE 'Segundo: %', NegocioSegurosGps.dias_vencidos;
						end if;

					END IF;

					---//---

				END IF;

			else

				---//---

				SELECT INTO NegocioSegurosGps
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
					FROM tem.seguros_vehiculos s, con.foto_cartera fra
					WHERE s.negocio_seguro = fra.negasoc--s.negocio_seguro = fra.negasoc
					      AND ciclo_fecha = '2014-07-29'
					      AND fra.valor_saldo > 0
					      AND fra.reg_status = ''
					      AND fra.tipo_documento in ('FAC','NDC')
					      AND fra.periodo_lote = PeriodoAsignacion
					      AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
					      AND substring(fra.documento,1,2) not in ('CP','FF','DF') --Se cambio?
					      AND negocio_vehiculo = CarteraGeneral.negocio
					GROUP BY s.negocio_vehiculo
				) c;

				IF FOUND THEN

					if ( NegocioSegurosGps.dias_vencidos > CarteraGeneral.dias_vencidos ) then
						CarteraGeneral.dias_vencidos = NegocioSegurosGps.dias_vencidos;
						CarteraGeneral.vencimiento_mayor = NegocioSegurosGps.vencimiento_mayor;
						RAISE NOTICE 'Segundo: %', NegocioSegurosGps.dias_vencidos;
					end if;

				END IF;

				---//---

			end if;
		end if;


		SELECT INTO ClienteRec nomcli,direccion,ciudad,case when telefono is null then '0' else telefono end as telefono,telcontacto FROM cliente WHERE nit = CarteraGeneral.cedula;
		CarteraGeneral.nombre_cliente = ClienteRec.nomcli;
		CarteraGeneral.direccion = ClienteRec.direccion;
		CarteraGeneral.ciudad = (select nomciu from ciudad where codciu=ClienteRec.ciudad);
		CarteraGeneral.telefono = ClienteRec.telefono;
		CarteraGeneral.telcontacto = ClienteRec.telcontacto;

		RETURN NEXT CarteraGeneral;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_reporte_cartera_copia(numeric, character varying, character varying)
  OWNER TO postgres;
