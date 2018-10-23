-- Function: sp_seguimientocarteraagente(numeric, character varying, character varying)

-- DROP FUNCTION sp_seguimientocarteraagente(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_seguimientocarteraagente(periodoasignacion numeric, unidadnegocio character varying, agenteext character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraTotales record;
	CarteraGeneral record;
	CarteraWtramoAnterior record;
	ClienteRec record;
	BankPay record;

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

	miHoy = now()::date;

	FOR CarteraGeneral IN

		select
			nit::varchar as cedula,
			''::varchar as nombre_cliente,
			''::varchar as direccion,
			''::varchar as ciudad,
			''::varchar as telefono,
			''::varchar as telcontacto,
			negasoc::varchar as negocio,
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
					  AND fra.tipo_documento = 'FAC'
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
		and tipo_documento = 'FAC'
		and substring(documento,1,2) not in ('CP','FF','DF')
		and id_convenio in (select id_convenio from rel_unidadnegocio_convenios where id_unid_negocio in (select id from unidad_negocio where id = UnidadNegocio))
		group by cedula, nombre_cliente, direccion, ciudad, telefono, negasoc, num_doc_fen, vencimiento_mayor, fecha_vencimiento, periodo_vcto, agente
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

		if ( CarteraGeneral.fecha_vencimiento < miHoy ) then
			CarteraGeneral.status_vencimiento = 'VENCIO';
		else
			CarteraGeneral.status_vencimiento = 'AL DIA';
		end if;

		--RECAUDO Y ENTIDAD DEL PAGO
		FOR BankPay IN
			select i.num_ingreso, id.factura, sum(id.valor_ingreso) as mingreso
			from con.ingreso_detalle id, con.ingreso i
			where id.num_ingreso = i.num_ingreso
			and id.dstrct = i.dstrct
			and id.tipo_documento = i.tipo_documento
			and id.dstrct = 'FINV'
			and id.tipo_documento in ('ING','ICA')
			and i.reg_status = ''
			and id.documento in (SELECT documento from con.factura where negasoc = CarteraGeneral.negocio and num_doc_fen = CarteraGeneral.cuota and tipo_documento = 'FAC' and reg_status = '' )
			and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodoAsignacion::varchar
			group by i.num_ingreso, id.factura LOOP

			if ( substring(BankPay.num_ingreso,1,2) = 'IA' ) then

				if ( substring(BankPay.factura,1,2) in ('FC','FG','FI') ) then

					Ingresoxcuota_fiducia = Ingresoxcuota_fiducia + BankPay.mingreso;

				elsif ( substring(BankPay.factura,1,2) in ('CC','CG','CI') ) then

					Ingresoxcuota_fenalco = Ingresoxcuota_fenalco + BankPay.mingreso;

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


		SELECT INTO ClienteRec nomcli,direccion,ciudad,case when telefono is null then '0' else telefono end as telefono,telcontacto FROM cliente WHERE nit = CarteraGeneral.cedula;
		CarteraGeneral.nombre_cliente = ClienteRec.nomcli;
		CarteraGeneral.direccion = ClienteRec.direccion;
		CarteraGeneral.ciudad = ClienteRec.ciudad;
		CarteraGeneral.telefono = ClienteRec.telefono;
		CarteraGeneral.telcontacto = ClienteRec.telcontacto;

		RETURN NEXT CarteraGeneral;

	END LOOP;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_seguimientocarteraagente(numeric, character varying, character varying)
  OWNER TO postgres;
