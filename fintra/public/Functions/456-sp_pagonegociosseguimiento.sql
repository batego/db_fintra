-- Function: sp_pagonegociosseguimiento(character varying, character varying, character varying)

-- DROP FUNCTION sp_pagonegociosseguimiento(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_pagonegociosseguimiento(periodseguimiento character varying, bussnegocio character varying, busscuota character varying)
  RETURNS SETOF rstype_pagoseguimiento AS
$BODY$

DECLARE

	TotalPagos numeric;
	BankPay record;
	Ingresoxcuota_fiducia numeric := 0;
	Ingresoxcuota_fenalco numeric := 0;
	IngresoxCuota numeric := 0;
	rs rstype_pagoseguimiento;

BEGIN

	IF ( BussCuota != '' ) THEN

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
				and id.documento in (SELECT documento from con.factura where negasoc = BussNegocio and num_doc_fen = BussCuota and tipo_documento in ('FAC','NDC') and reg_status = '' /*and devuelta != 'S'*/ /*and corficolombiana != 'S'*/)
				and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodSeguimiento
			group by i.num_ingreso, id.factura, branch_code, bank_account_no, i.cuenta LOOP

			raise notice 'num_ingreso: %, factura: %, branch_code: %, bank_account_no: %, cuenta: %, valor: %',BankPay.num_ingreso, BankPay.factura, BankPay.branch_code, BankPay.bank_account_no, BankPay.cuenta, BankPay.mingreso;

			if ( substring(BankPay.num_ingreso,1,2) = 'IA' ) then

				if ( substring(BankPay.factura,1,2) in ('FC','FG','FI','CK','LC') ) then

					if ( (BankPay.branch_code != '' and BankPay.bank_account_no != '') or BankPay.cuenta in ('11050501','13809501','28150530','I010140014170','23809913') ) then --13050921
						IngresoxCuota = IngresoxCuota + BankPay.mingreso;
					else
						Ingresoxcuota_fiducia = Ingresoxcuota_fiducia + BankPay.mingreso;
					end if;


				elsif ( substring(BankPay.factura,1,2) in ('CC','CG','CI','CK') ) then

					if ( (BankPay.branch_code != '' and BankPay.bank_account_no != '') or BankPay.cuenta in ('11050501','13809501','27050901','28150530','I010140014170') ) then
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

			rs.rs_ingresoxcuota_fiducia := coalesce(Ingresoxcuota_fiducia,0);
			rs.rs_ingresoxcuota_fenalco := coalesce(Ingresoxcuota_fenalco,0);
			rs.rs_ingresoxCuota := coalesce(IngresoxCuota,0);

		END LOOP;

		RETURN NEXT rs;

	ELSE

		--RECAUDO DEL AVAL
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
				and id.documento in (
					SELECT documento
					from con.foto_cartera fc
					where fc.periodo_lote = PeriodSeguimiento
					and fc.valor_saldo > 0
					and fc.reg_status = ''
					and fc.dstrct = 'FINV'
					and fc.tipo_documento in ('FAC','NDC')
					and substring(fc.documento,1,2) not in ('CP','FF','DF')
					and replace(substring(fc.fecha_vencimiento,1,7),'-','')::numeric <= PeriodSeguimiento
					and fc.negasoc = BussNegocio
				)
				and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodSeguimiento
			group by i.num_ingreso, id.factura, branch_code, bank_account_no, i.cuenta LOOP

			raise notice 'AVAL FOTO:: num_ingreso: %, factura: %, bank_account_no: %, cuenta: %, valor: %',BankPay.num_ingreso, BankPay.factura, BankPay.bank_account_no, BankPay.cuenta, BankPay.mingreso;

			/*Cambios para verificar si esta cargada a la fiducia y rescribimos el record BankPay*/
			if((select count(0) from con.factura where documento=('C'||substring(BankPay.factura,2)))>0)then


				select into BankPay i.num_ingreso, id.factura, branch_code, bank_account_no, i.cuenta, sum(id.valor_ingreso) as mingreso
					from con.ingreso_detalle id, con.ingreso i
					where id.num_ingreso = i.num_ingreso
						and id.dstrct = i.dstrct
						and id.tipo_documento = i.tipo_documento
						and id.dstrct = 'FINV'
						and id.tipo_documento in ('ING','ICA')
						and i.reg_status = ''
						and id.reg_status = ''
						and id.documento =('C'||substring(BankPay.factura,2))
						and replace(substring(i.fecha_consignacion,1,7),'-','') = PeriodSeguimiento
					group by i.num_ingreso, id.factura, branch_code, bank_account_no, i.cuenta;

				raise notice 'AVAL FIDUCIA:: num_ingreso: %, factura: %, bank_account_no: %, cuenta: %, valor: %',BankPay.num_ingreso, BankPay.factura, BankPay.bank_account_no, BankPay.cuenta, BankPay.mingreso;

			end if;



			if ( substring(BankPay.num_ingreso,1,2) = 'IA' ) then

				if ( substring(BankPay.factura,1,2) in ('FC','FG','FI','CK') ) then

					if ( (BankPay.branch_code != '' and BankPay.bank_account_no != '') or BankPay.cuenta in ('11050501','13809501','28150530','I010140014170') ) then
						IngresoxCuota = IngresoxCuota + BankPay.mingreso;
					else
						Ingresoxcuota_fiducia = Ingresoxcuota_fiducia + BankPay.mingreso;

					end if;


				elsif ( substring(BankPay.factura,1,2) in ('CC','CG','CI','CK') ) then

					if ( (BankPay.branch_code != '' and BankPay.bank_account_no != '') or BankPay.cuenta in ('11050501','13809501','27050901','28150530','I010140014170') ) then
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

			rs.rs_ingresoxcuota_fiducia := coalesce(Ingresoxcuota_fiducia,0);
			rs.rs_ingresoxcuota_fenalco := coalesce(Ingresoxcuota_fenalco,0);
			rs.rs_ingresoxCuota := coalesce(IngresoxCuota,0);

		END LOOP;

		RETURN NEXT rs;


	END IF;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_pagonegociosseguimiento(character varying, character varying, character varying)
  OWNER TO postgres;
