-- Function: sp_pagonegocios(character varying, character varying)

-- DROP FUNCTION sp_pagonegocios(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_pagonegocios(bussnegocio character varying, busscuota character varying)
  RETURNS text AS
$BODY$

DECLARE

	TotalPagos numeric;
	BankPay record;
	Ingresoxcuota_fiducia numeric;
	Ingresoxcuota_fenalco numeric;
	IngresoxCuota numeric;

BEGIN

	IngresoxCuota = 0;

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
		and id.reg_status = ''
		and id.documento in (SELECT documento from con.factura where negasoc = BussNegocio and num_doc_fen = BussCuota and tipo_documento in ('FAC','NDC') and reg_status = '' /*and devuelta != 'S' and corficolombiana != 'S'*/)
		--and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodoAsignacion::varchar
		group by i.num_ingreso, id.factura, branch_code, bank_account_no, i.cuenta LOOP

		raise notice 'num_ingreso: %, factura: %, bank_account_no: %, cuenta: %, valor: %',BankPay.num_ingreso, BankPay.factura, BankPay.bank_account_no, BankPay.cuenta, BankPay.mingreso;

		if ( substring(BankPay.num_ingreso,1,2) = 'IA' ) then

			if ( substring(BankPay.factura,1,2) in ('FC','FG','FI','CK') ) then

				if ( (BankPay.branch_code != '' and BankPay.bank_account_no != '') or BankPay.cuenta in ('11050501','13809501','28150530','I010140014170') ) then
					IngresoxCuota = IngresoxCuota + BankPay.mingreso;
				else
					Ingresoxcuota_fiducia = Ingresoxcuota_fiducia + BankPay.mingreso;
				end if;


			elsif ( substring(BankPay.factura,1,2) in ('CC','CG','CI','CK') ) then

				if ( (BankPay.branch_code != '' and BankPay.bank_account_no != '') or BankPay.cuenta in ('11050501','13809501','27050901','28150530','I010140014170')  ) then
					IngresoxCuota = IngresoxCuota + BankPay.mingreso;
				else
					Ingresoxcuota_fenalco = Ingresoxcuota_fenalco + BankPay.mingreso;
				end if;

			elsif ( substring(BankPay.factura,1,2) in ('AP','MC','MI','CA','CM') ) then

				IngresoxCuota = IngresoxCuota + BankPay.mingreso;

			end if;

		elsif ( substring(BankPay.num_ingreso,1,2) = 'IC' ) then

			IngresoxCuota = IngresoxCuota + BankPay.mingreso;

		end if;

	END LOOP;

	if ( IngresoxCuota > 0 ) then
		TotalPagos = IngresoxCuota;
	   else
		TotalPagos = 0;
	end if;

	RETURN TotalPagos::numeric;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_pagonegocios(character varying, character varying)
  OWNER TO postgres;
