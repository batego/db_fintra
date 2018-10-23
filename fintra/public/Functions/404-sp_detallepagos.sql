-- Function: sp_detallepagos(numeric, character varying)

-- DROP FUNCTION sp_detallepagos(numeric, character varying);

CREATE OR REPLACE FUNCTION sp_detallepagos(periodoasignacion numeric, negocioref character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraGeneral record;
	ClienteRec record;
	FacturaActual record;
	NegocioAvales record;
	BankPay record;

	FechaCortePeriodo varchar;
	VencimientoMayor varchar;

	PeriodoTramo numeric;

	ControlReg Text;

BEGIN

	if ( substring(PeriodoAsignacion,5) = '01' ) then
		PeriodoTramo = substring(PeriodoAsignacion,1,4)::numeric-1||'12';
	else
		PeriodoTramo = PeriodoAsignacion::numeric - 1;
	end if;

	--PeriodoTramo = PeriodoAsignacion::numeric - 1;
	ControlReg = '';

	select into FechaCortePeriodo to_char(to_timestamp(substring(PeriodoTramo,1,4)::numeric || '-' || to_char(substring(PeriodoTramo,5,2)::numeric,'FM00') || '-01', 'YYYY-MM-DD') + INTERVAL '1 month' - INTERVAL '1 days', 'YYYY-MM-DD');
	raise notice 'FechaCortePeriodo%',FechaCortePeriodo;
	FOR CarteraGeneral IN

		select negasoc::varchar as negocio,
		       nit::varchar as cedula,
		       ''::varchar as nombre_cliente,
		       num_doc_fen::varchar as cuota,
		       documento::varchar, --''::varchar as documento,  --documento::varchar,
		       fecha_vencimiento::date,
		       (FechaCortePeriodo::date-fecha_vencimiento)::numeric AS dias_vencidos,
		       valor_factura::numeric,
		       0::numeric as valor_saldo,
		       ''::varchar as ingreso,
		       ''::varchar as branch_code,
		       ''::varchar as bank_account_no,
		       ''::varchar as fecha_ingreso,
		       ''::varchar as fecha_consignacion,
		       ''::varchar as descripcion_ingreso,
		       0::numeric as valor_ingreso
		from con.foto_cartera f
		where negasoc = NegocioRef
		and valor_saldo > 0
		and periodo_lote = PeriodoAsignacion
		and reg_status = ''
		--and descripcion != 'CXC AVAL'
		and substring(documento,1,2) not in ('CP','FF','DF')
		and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion
		order by num_doc_fen::numeric,creation_date

	LOOP

		SELECT INTO ClienteRec nomcli FROM cliente WHERE nit = CarteraGeneral.cedula;
		CarteraGeneral.nombre_cliente = ClienteRec.nomcli;

		SELECT INTO FacturaActual valor_saldo FROM con.factura WHERE documento = CarteraGeneral.documento;
		CarteraGeneral.valor_saldo = FacturaActual.valor_saldo;

		--if ( and devuelta != 'S' and corficolombiana != 'S' )
		--RECAUDO Y ENTIDAD DEL PAGO
		FOR BankPay IN

			select i.num_ingreso, i.descripcion_ingreso, i.branch_code, i.bank_account_no, i.fecha_ingreso, i.fecha_consignacion, sum(id.valor_ingreso) as mingreso
			from con.ingreso_detalle id, con.ingreso i
			where id.num_ingreso = i.num_ingreso
			and id.dstrct = i.dstrct
			and id.tipo_documento = i.tipo_documento
			and id.dstrct = 'FINV'
			and id.tipo_documento in ('ING','ICA')
			and i.reg_status = ''
			and id.reg_status = ''
			and id.documento = (SELECT documento from con.factura where documento = CarteraGeneral.documento and tipo_documento in ('FAC','NDC') and reg_status = '' and endoso_fenalco !='S' and devuelta != 'S' and corficolombiana != 'S') --CarteraGeneral.documento
			and replace(substring(i.fecha_consignacion,1,7),'-','') <= PeriodoAsignacion
			group by i.num_ingreso, i.descripcion_ingreso, i.branch_code, i.bank_account_no, i.fecha_ingreso, i.fecha_consignacion

		LOOP
			if found then

				CarteraGeneral.ingreso = BankPay.num_ingreso;
				CarteraGeneral.branch_code = BankPay.branch_code;
				CarteraGeneral.bank_account_no = BankPay.bank_account_no;
				CarteraGeneral.fecha_ingreso = BankPay.fecha_ingreso;
				CarteraGeneral.fecha_consignacion = BankPay.fecha_consignacion;
				CarteraGeneral.descripcion_ingreso = BankPay.descripcion_ingreso;
				CarteraGeneral.valor_ingreso = BankPay.mingreso;

				RETURN NEXT CarteraGeneral;
				ControlReg = 'X';
			end if;

		END LOOP;

		if ( ControlReg = '' ) then RETURN NEXT CarteraGeneral; end if;

		-- select * from SP_DetallePagos(201405, 'FA03700') as coco(negocio varchar, cedula varchar, nombre_cliente varchar, cuota varchar, documento varchar, fecha_vencimiento date, dias_vencidos numeric, valor_factura numeric, valor_saldo numeric, ingreso varchar, branch_code varchar, bank_account_no varchar, fecha_ingreso varchar, fecha_consignacion varchar, descripcion_ingreso varchar, valor_ingreso numeric)

	END LOOP;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_detallepagos(numeric, character varying)
  OWNER TO postgres;
