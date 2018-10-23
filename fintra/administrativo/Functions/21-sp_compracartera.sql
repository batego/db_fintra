-- Function: administrativo.sp_compracartera()

-- DROP FUNCTION administrativo.sp_compracartera();

CREATE OR REPLACE FUNCTION administrativo.sp_compracartera()
  RETURNS text AS
$BODY$

DECLARE

	RsCartera record;

	_PeriodoCte numeric;
	ItemDetalleIngreso numeric := 0;

	NumeroIngreso varchar := '';
	CuentaDetalle varchar := '';

	_TipoIngreso varchar := '';
	_BranchCode varchar := 'CAJA GENERAL';
	_BankAccountNo varchar := 'CAJA';

	fecha_hoy date;
	fechaAnterior date;
	miHoy date;

	mcad TEXT;

BEGIN

	miHoy = now()::date;
	_PeriodoCte = replace(substring(miHoy,1,7),'-','')::numeric;

	_TipoIngreso = 'ING';

	FOR RsCartera IN

		/*
		select sum(valor_saldo)
		from con.factura
		where documento in (select documento from tem.compra_cartera_2016_bkp)
		and valor_saldo > 0*/

		select * from tem.compra_cartera2016_saldofactura where valor_saldo = 0

	LOOP
		SELECT INTO NumeroIngreso get_lcod('INGC');
		raise notice 'NUMERO IA: %',NumeroIngreso;

		SELECT INTO CuentaDetalle cuenta from con.cmc_doc where cmc = RsCartera.cmc and tipodoc = 'FAC';

		/*CABECERA DEL INGRESO*/
		INSERT INTO con.ingreso(dstrct,tipo_documento,num_ingreso,codcli,nitcli,
			     concepto,tipo_ingreso,fecha_consignacion,fecha_ingreso,branch_code,
			     bank_account_no,codmoneda,agencia_ingreso,descripcion_ingreso,vlr_ingreso,
			     vlr_ingreso_me,vlr_tasa,fecha_tasa,cant_item,creation_user,
			     creation_date,base,cuenta)
		VALUES('FINV',_TipoIngreso,NumeroIngreso,RsCartera.codcli,RsCartera.nit,
		       'FE','C','2016-12-30','2016-12-30 11:21:36.414084','CAJA GENERAL', --'2016-12-30 11:21:36.313083',
		       'CAJA','PES','OP','INGRESO AUTOMATICO - COMPRA CARTERA 2016',RsCartera.valor_saldo,
		       RsCartera.valor_saldo,'1.000000','2016-12-30',1,'HCUELLO',
		       '2016-12-30 11:21:36.313083','COL','11050501');

		ItemDetalleIngreso:=ItemDetalleIngreso+1;

		INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
						valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
						documento,creation_user,creation_date,base,cuenta,descripcion,
						valor_tasa,saldo_factura)
		VALUES('FINV',_TipoIngreso,NumeroIngreso,ItemDetalleIngreso,RsCartera.nit,
			RsCartera.valor_saldo,RsCartera.valor_saldo,RsCartera.documento,'2016-12-30','FAC',
			RsCartera.documento,'HCUELLO','2016-12-30 11:21:36.414084','COL',CuentaDetalle,
			'COMPRA CARTERA 2016','1.0000000000',0);

	END LOOP;

	--
	mcad = 'OK';

	RETURN mcad;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.sp_compracartera()
  OWNER TO postgres;
