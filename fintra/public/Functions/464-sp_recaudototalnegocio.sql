-- Function: sp_recaudototalnegocio(character varying, character varying)

-- DROP FUNCTION sp_recaudototalnegocio(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_recaudototalnegocio(negocio character varying, periodoasignacion character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	TotalPagos record;
	BankPay record;
	Ingresoxcuota_fiducia numeric;
	Ingresoxcuota_fenalco numeric;
	IngresoxCuota numeric;
	IngresoxSanciones numeric;
	total_pagos numeric;
	total_sanciones numeric;
	FechaCortePeriodo varchar;
	FechaCortePeriodoAnt varchar;
	PeriodoTramo varchar;
	TramoAnterior varchar;

BEGIN

	SELECT INTO TotalPagos 0::numeric as valor_pagos, 0::numeric as valor_sanciones;

	if ( substring(PeriodoAsignacion,5) = '01' ) then
		PeriodoTramo = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
		TramoAnterior = substring(PeriodoAsignacion,1,4)::numeric-1||'11';
	elsif ( substring(PeriodoAsignacion,5) = '02' ) then
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
		TramoAnterior = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
		TramoAnterior = PeriodoAsignacion::numeric - 1;
	end if;

	RAISE NOTICE 'PeriodoTramo: % TramoAnterior: %',PeriodoTramo,TramoAnterior;

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	select into FechaCortePeriodoAnt to_char(to_timestamp(substring(TramoAnterior,1,4)::numeric || '-' || to_char(substring(TramoAnterior,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	raise notice 'FechaCortePeriodo: % FechaCortePeriodoAnt: %',FechaCortePeriodo,FechaCortePeriodoAnt;

	IngresoxCuota = 0;
	IngresoxSanciones = 0;
	--RECAUDO Y ENTIDAD DEL PAGO
	FOR BankPay IN
		SELECT i.num_ingreso, id.factura, id.cuenta, sum(id.valor_ingreso) as mingreso
			FROM con.ingreso_detalle id
			INNER JOIN con.ingreso i ON (id.num_ingreso = i.num_ingreso and id.dstrct = i.dstrct and i.nitcli=id.nitcli )
			WHERE id.dstrct = 'FINV'
				and id.tipo_documento in ('ING','ICA')
				and i.reg_status = ''
				and i.branch_code != ''
				and i.bank_account_no != ''
				--and i.nitcli= CarteraxCliente.nit
				and id.reg_status = ''
				and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodoTramo
				and id.num_ingreso in (
							select distinct num_ingreso
							from con.ingreso_detalle id, con.factura f
							where id.factura = f.documento
							and f.negasoc = negocio
							and f.tipo_documento in ('FAC','NDC')
							and f.reg_status = ''
							and f.devuelta != 'S'
							and f.corficolombiana != 'S'
							and f.endoso_fenalco !='S'
							and id.documento != ''
						     )
			GROUP BY i.num_ingreso, id.factura, id.cuenta
	LOOP

		raise notice 'num_ingreso: %, cuenta: %, valor: %',BankPay.num_ingreso,BankPay.cuenta, BankPay.mingreso;

		if ( substring(BankPay.num_ingreso,1,2) = 'IA' ) then

			if ( substring(BankPay.factura,1,2) in ('FC','FG','FI') ) then

				if (BankPay.cuenta in ('16252145','94350302','I010010014205','16252147','94350301','I010010014170') ) then
					IngresoxSanciones = IngresoxSanciones + BankPay.mingreso;
				elsif (BankPay.cuenta in ('11050501','13809501')) then
					IngresoxCuota = IngresoxCuota + BankPay.mingreso;
				end if;

			elsif ( substring(BankPay.factura,1,2) in ('CC','CG','CI') ) then

				if (BankPay.cuenta in ('16252145','94350302','I010010014205','16252147','94350301','I010010014170') ) then
					IngresoxSanciones = IngresoxSanciones + BankPay.mingreso;
				elsif (BankPay.cuenta in ('11050501','13809501')) then
					IngresoxCuota = IngresoxCuota + BankPay.mingreso;
				end if;

			elsif ( substring(BankPay.factura,1,2) in ('AP','MC','MI','CA') ) then

				if (BankPay.cuenta in ('16252145','94350302','I010010014205','16252147','94350301','I010010014170') ) then
					IngresoxSanciones = IngresoxSanciones + BankPay.mingreso;
				else
					IngresoxCuota = IngresoxCuota + BankPay.mingreso;
				end if;

			elsif ( substring(BankPay.factura,1,2) = '') then
				if (BankPay.cuenta in ('16252145','94350302','I010010014205','16252147','94350301','I010010014170') ) then
					IngresoxSanciones = IngresoxSanciones + BankPay.mingreso;
				end if;
			end if;

		elsif ( substring(BankPay.num_ingreso,1,2) = 'IC' ) then

			if (BankPay.cuenta in ('16252145','94350302','I010010014205','16252147','94350301','I010010014170') ) then
				IngresoxSanciones = IngresoxSanciones + BankPay.mingreso;
			else
				IngresoxCuota = IngresoxCuota + BankPay.mingreso;
			end if;

		end if;

	END LOOP;

	if ( IngresoxCuota > 0 ) then
		TotalPagos.valor_pagos = IngresoxCuota;
	   else
		TotalPagos.valor_pagos = 0;
	end if;

	if ( IngresoxSanciones > 0 ) then
		TotalPagos.valor_sanciones = IngresoxSanciones;
	   else
		TotalPagos.valor_sanciones = 0;
	end if;

	RETURN NEXT TotalPagos;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_recaudototalnegocio(character varying, character varying)
  OWNER TO postgres;
