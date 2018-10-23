-- Function: sp_agentescartera(character varying, character varying, character varying, character varying)

-- DROP FUNCTION sp_agentescartera(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_agentescartera(periodo_foto character varying, fch_corte character varying, fch_corte_periodo_anterior character varying, periodo_recaudo character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraxCliente record;
	RecaudoxCuota record;
	ClienteRec record;
	_Asesory record;
	BankPay record;

	_SumAbonos numeric;
	_SumDebidoCobrar numeric;
	_RestaPeriodo numeric;
	IngresoxCuota numeric;

	Business varchar;
	fecha_corte date;
	periodo_corte varchar;
	periodo_corriente varchar;
	cadena_pagos TEXT;

BEGIN

	Business = '';
	_RestaPeriodo = periodo_foto::numeric - 1;

	fecha_corte = fch_corte; --'2014-01-31'; --now()::date;
	periodo_corte = replace(substring(fecha_corte,1,7),'-','');

	periodo_corriente = periodo_recaudo; --replace(substring(now()::date,1,7),'-','');

	FOR CarteraxCliente IN

		SELECT
		''::varchar as control,
		negocio::varchar,
		convenio::numeric,
		cedula::varchar,
		''::varchar as nombre_cliente,
		''::varchar as direccion,
		''::varchar as ciudad,
		''::varchar as asesor ,
		fecha_desembolso::date as fecha_desembolso,
		periodo_desembolso::varchar as periodo_desembolso,
		cuota::varchar,

		fecha_vencimiento::date,
		periodo_vcto::varchar,
		dia_vcto::varchar,

		''::varchar as fecha_pago, --fecha_ultimo_pago::date as fecha_pago,
		sum(valor_saldo)::numeric as valor_saldo,
		dias_vencidos::numeric,
		rango::varchar,
		max_dias::numeric,
		rango_maxdia::varchar,
		rango_mayor_periodoanterior::varchar,
		0::numeric as recaudosxcuota,
		''::varchar as branch_code,
		''::varchar as bank_account_no,
		''::varchar as status,
		0::numeric as debido_cobrar

		FROM (

			select
			f.negasoc AS Negocio, --ng.cod_neg AS Negocio
			f.id_convenio as convenio, --,ng.id_convenio as Convenio
			f.nit AS cedula, --,ng.cod_cli AS Cedula,
			fecha_negocio as fecha_desembolso, --substring(ng.f_desem,1,10) as fecha_desembolso,
			replace(substring(fecha_negocio,1,7),'-','') as periodo_desembolso, --replace(substring(ng.f_desem,1,7),'-','') as periodo_desembolso,
			f.documento,
			f.num_doc_fen as cuota,

			f.fecha_vencimiento,
			replace(substring(f.fecha_vencimiento,1,7),'-','') as periodo_vcto,
			substring(f.fecha_vencimiento,9) as dia_vcto,

			--f.fecha_ultimo_pago,
			f.valor_saldo,
			(fecha_corte-f.fecha_vencimiento::DATE) AS dias_vencidos,

				--RANGO
				CASE WHEN (fecha_corte-f.fecha_vencimiento::DATE)>=361 THEN 'MAYOR A 1 AÃ‘O'
				     WHEN (fecha_corte-f.fecha_vencimiento::DATE)>=181 THEN 'ENTRE 180 Y 360'
				     WHEN (fecha_corte-f.fecha_vencimiento::DATE)>=121 THEN 'ENTRE 121 Y 180'
				     WHEN (fecha_corte-f.fecha_vencimiento::DATE)>=91 THEN 'ENTRE 91 Y 120'
				     WHEN (fecha_corte-f.fecha_vencimiento::DATE)>=61 THEN 'ENTRE 61 Y 90'
				     WHEN (fecha_corte-f.fecha_vencimiento::DATE)>=31 THEN 'ENTRE 31 Y 60'
				     WHEN (fecha_corte-f.fecha_vencimiento::DATE)>=1 THEN '1 A 30'
				     WHEN (fecha_corte-f.fecha_vencimiento::DATE)<=0 THEN 'CORRIENTE'
				ELSE '0' END AS rango,

				--MAX DIAS
				(SELECT max(fecha_corte-(fecha_vencimiento))
				 FROM con.foto_cartera fra
				 WHERE fra.dstrct = 'FINV'
					  AND fra.valor_saldo >0
 					  AND fra.reg_status = ''
					  AND fra.negasoc = f.negasoc
					  AND fra.tipo_documento = 'FAC'
					  AND fra.periodo_lote = periodo_foto
				 GROUP BY negasoc) as max_dias,

				--RANGO MAYOR
				(
				SELECT
					CASE WHEN maxdia >= 361 THEN 'MAYOR A 1 AÃ‘O'
					     WHEN maxdia >= 181 THEN 'ENTRE 180 Y 360'
					     WHEN maxdia >= 121 THEN 'ENTRE 121 Y 180'
					     WHEN maxdia >= 91 THEN 'ENTRE 91 Y 120'
					     WHEN maxdia >= 61 THEN 'ENTRE 61 Y 90'
					     WHEN maxdia >= 31 THEN 'ENTRE 31 Y 60'
					     WHEN maxdia >= 1 THEN '1 A 30'
					     WHEN maxdia <= 0 THEN 'CORRIENTE'
						ELSE '0' END AS rango
				FROM (
					 SELECT max(fecha_corte-(fecha_vencimiento)) as maxdia
					 --SELECT max('2014-02-28'-(fecha_vencimiento)) as maxdia
					 --select '2014-02-28'-fecha_vencimiento,*
					 FROM con.foto_cartera fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = f.negasoc --'MC03657'
						  AND fra.tipo_documento = 'FAC'
						  AND fra.periodo_lote = periodo_foto
					 GROUP BY negasoc

				) tabla2
				) as rango_maxdia,


				--RANGO MAYOR ANTERIOR
				(
				SELECT
					CASE WHEN maxdia >= 361 THEN 'MAYOR A 1 AÃ‘O'
					     WHEN maxdia >= 181 THEN 'ENTRE 180 Y 360'
					     WHEN maxdia >= 121 THEN 'ENTRE 121 Y 180'
					     WHEN maxdia >= 91 THEN 'ENTRE 91 Y 120'
					     WHEN maxdia >= 61 THEN 'ENTRE 61 Y 90'
					     WHEN maxdia >= 31 THEN 'ENTRE 31 Y 60'
					     WHEN maxdia >= 1 THEN '1 A 30'
					     WHEN maxdia <= 0 THEN 'CORRIENTE'
						ELSE '0' END AS rango
				FROM (
					 SELECT max(fch_corte_periodo_anterior::date-fecha_vencimiento) as maxdia
					 FROM con.foto_cartera fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = f.negasoc --'MC03657'
						  AND fra.tipo_documento = 'FAC'
						  AND fra.periodo_lote = _RestaPeriodo
					 GROUP BY negasoc

				) tabla3
				) as rango_mayor_periodoanterior

			----------------------------------------
			from con.foto_cartera f --, negocios ng
			where --f.negasoc = ng.cod_neg
				--and ng.estado_neg in ('A','T')
				f.id_convenio in(10,11,12,13)
				and f.valor_saldo > 0
				and f.reg_status = ''
				and f.dstrct = 'FINV'
				and f.tipo_documento = 'FAC'
				and substring(f.documento,1,2) in ('MC','MI','CA')
				and f.periodo_lote = periodo_foto
				--and f.negasoc = 'MC03476' -- 'MC00942' --in ('MC03712','MC01150','MC00890') --MC00632 'MC03652'--in ('MC03652','MC00208','MC00494')
			order by negasoc --,cuota
		) AS c

		GROUP BY negocio, convenio, cedula, nombre_cliente, fecha_desembolso,periodo_desembolso,
		cuota, fecha_vencimiento, periodo_vcto, dia_vcto, fecha_pago, dias_vencidos, rango, max_dias, rango_maxdia, rango_mayor_periodoanterior
		order by negocio, dias_vencidos desc LOOP

		_SumDebidoCobrar = 0;
		_SumAbonos = 0;

		--RECAUDO POR PERIODO
		/*
		SELECT INTO _SumAbonos sum(valor_abono) from con.factura where negasoc = CarteraxCliente.negocio and num_doc_fen = CarteraxCliente.cuota and reg_status = '';
		if ( _SumAbonos > 0 ) then
			CarteraxCliente.recaudosxcuota = _SumAbonos;
		   else
			CarteraxCliente.recaudosxcuota = null;
		end if;
		*/

		IngresoxCuota = 0;
		cadena_pagos := '';

		--RECAUDO Y ENTIDAD DEL PAGO
		FOR BankPay IN
			--SELECT INTO BankPay i.branch_code, i.bank_account_no, i.fecha_consignacion, sum(id.valor_ingreso) as mingreso --i.branch_code, i.bank_account_no
			select i.branch_code, i.bank_account_no, i.fecha_consignacion, sum(id.valor_ingreso) as mingreso
			from con.ingreso_detalle id, con.ingreso i
			where id.num_ingreso = i.num_ingreso
			and id.dstrct = i.dstrct
			and id.tipo_documento = i.tipo_documento
			and id.dstrct = 'FINV'
			and id.tipo_documento in ('ING','ICA')
			and i.reg_status = ''
			and id.documento in (SELECT documento from con.factura where negasoc = CarteraxCliente.negocio and num_doc_fen = CarteraxCliente.cuota and tipo_documento = 'FAC' and reg_status = '' /*and periodo_lote = periodo_foto*/ )
			and replace(substring(i.fecha_consignacion,1,7),'-','') = periodo_recaudo
			group by i.branch_code, i.bank_account_no, i.fecha_consignacion LOOP

			IngresoxCuota = IngresoxCuota + BankPay.mingreso;

			IF (BankPay.branch_code != '' OR BankPay.branch_code != null ) THEN

				CarteraxCliente.branch_code = BankPay.branch_code;
				CarteraxCliente.bank_account_no = BankPay.bank_account_no;
				cadena_pagos := BankPay.fecha_consignacion || '-';

			END IF;

		END LOOP;
		CarteraxCliente.fecha_pago = cadena_pagos;

		--if ( BankPay.mingreso > 0 ) then
		if ( IngresoxCuota > 0 ) then
			CarteraxCliente.recaudosxcuota = IngresoxCuota;
		   else
			CarteraxCliente.recaudosxcuota = null;
		end if;

		--STATUS Y DEBIDO COBRAR
		if (CarteraxCliente.periodo_vcto = periodo_corriente ) then

			SELECT INTO _SumDebidoCobrar valor from documentos_neg_aceptado where cod_neg = CarteraxCliente.negocio and item = CarteraxCliente.cuota;

			CarteraxCliente.status = 'A Vencer';
			CarteraxCliente.debido_cobrar = _SumDebidoCobrar;

		else
			if ( CarteraxCliente.dias_vencidos > 0 ) then

				CarteraxCliente.status = 'Vencido';
				CarteraxCliente.debido_cobrar = CarteraxCliente.valor_saldo;

			else
				SELECT INTO _SumDebidoCobrar valor from documentos_neg_aceptado where cod_neg = CarteraxCliente.negocio and item = CarteraxCliente.cuota;
				CarteraxCliente.status = 'Al DÃ­a';
				CarteraxCliente.debido_cobrar = _SumDebidoCobrar;
			end if;
		end if;


		--INFORMACION DE COBRO
		SELECT INTO ClienteRec nomcli,direccion,ciudad FROM cliente WHERE nit = CarteraxCliente.cedula;
		CarteraxCliente.nombre_cliente = ClienteRec.nomcli;
		CarteraxCliente.direccion = ClienteRec.direccion;
		CarteraxCliente.ciudad = ClienteRec.ciudad;

		SELECT INTO _Asesory nombre FROM usuarios WHERE idusuario = (select asesor from solicitud_aval where cod_neg = CarteraxCliente.negocio);
		IF FOUND THEN CarteraxCliente.asesor = _Asesory.nombre; END IF;



		--CONTROL
		if ( Business != CarteraxCliente.negocio ) then
			Business = CarteraxCliente.negocio;
			CarteraxCliente.control = '1';

			/*
			SELECT INTO ClienteRec nomcli,direccion,ciudad FROM cliente WHERE nit = CarteraxCliente.cedula;
			CarteraxCliente.nombre_cliente = ClienteRec.nomcli;
			CarteraxCliente.direccion = ClienteRec.direccion;
			CarteraxCliente.ciudad = ClienteRec.ciudad;

			SELECT INTO _Asesory nombre FROM usuarios WHERE idusuario = (select asesor from solicitud_aval where cod_neg = CarteraxCliente.negocio);
			IF FOUND THEN CarteraxCliente.asesor = _Asesory.nombre; END IF;
			*/
		else
			CarteraxCliente.control = '';
			Business = CarteraxCliente.negocio;
			--CarteraxCliente.cedula = '';
			--CarteraxCliente.convenio = null;
		end if;

	        RETURN NEXT CarteraxCliente;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_agentescartera(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
