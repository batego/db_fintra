-- Function: sp_cxclibranza(character varying, character varying)

-- DROP FUNCTION sp_cxclibranza(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_cxclibranza(_cod_neg character varying, _user character varying)
  RETURNS text AS
$BODY$

DECLARE

	fila_items record;
	rsProveedor record;

	_respuesta varchar := 'OK';
	_numerofac_query varchar := '';
	_numero_factura varchar := '';
	_auxiliar varchar := '';
	_PeriodoCte varchar := '';
	SerieIFLibranza varchar := '';
	SerieCxPSeguro varchar := '';

	cnt numeric;
	saldo numeric;
	_grupo_transaccion numeric;
	_transaccion numeric;
	_ValorCuota numeric;

	miHoy date;

BEGIN

	miHoy = now()::date;
	_PeriodoCte = replace(substring(miHoy,1,7),'-','')::varchar;

	/*-----------------------------
	   --Generar la cartera--
	-------------------------------*/

	_numerofac_query = '';
	SELECT INTO _numerofac_query get_lcod('CXC_LIBRANZA');
	cnt = 1;

	FOR fila_items IN

		SELECT dna.cod_neg, dna.item, dna.fecha, dna.dias, dna.saldo_inicial, dna.capital, dna.interes, dna.valor, dna.saldo_final, dna.reg_status, dna.creation_date, dna.no_aval, dna.capacitacion, dna.cat, dna.seguro, dna.interes_causado, dna.fch_interes_causado, dna.documento_cat, dna.custodia, dna.remesa, dna.causar, n.cod_cli, n.fecha_negocio, n.cmc, n.id_convenio
		FROM documentos_neg_aceptado dna, negocios n
		WHERE dna.cod_neg = n.cod_neg
		      AND item != 0
		      AND dna.cod_neg = _cod_neg
		ORDER BY dna.dias
	LOOP

		saldo = 0;
		_numero_factura = '';

		IF (cnt<10) THEN
		    _numero_factura = _numerofac_query||0||cnt;
		ELSE
		    _numero_factura = _numerofac_query||cnt;
		END IF;

		saldo = fila_items.capital;
		_ValorCuota = round(fila_items.capital + fila_items.interes + fila_items.seguro);

		INSERT INTO con.factura (
			    tipo_documento, documento, nit, codcli, concepto, fecha_factura, fecha_vencimiento,
			    descripcion, moneda, forma_pago, negasoc, base,
			    agencia_facturacion, agencia_cobro,  creation_date, creation_user, cantidad_items,
			    valor_tasa, valor_factura, valor_facturame, valor_saldo, valor_saldome, num_doc_fen,
			    tipo_ref1, ref1, cmc, dstrct)
		     VALUES('FAC', _numero_factura, fila_items.cod_cli, get_codnit(fila_items.cod_cli), '03', fila_items.fecha_negocio,fila_items.fecha,
		            'CXC_LIBRANZA','PES','CREDITO',fila_items.cod_neg,'COL',
		            'OP','BQ',now(),_User,'1',
		            '1.000000',round(_ValorCuota),round(_ValorCuota),round(_ValorCuota),round(_ValorCuota),fila_items.item,
		            '','','LC','FINV');

		_auxiliar = 'RD-' || fila_items.cod_cli;

		INSERT INTO con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
		VALUES('FAC',_numero_factura,1,fila_items.cod_cli,'03','CAPITAL','1.0000',fila_items.capital,fila_items.capital,'1.000000','PES',now(),_User,fila_items.capital,fila_items.capital,fila_items.cod_neg,'COL',_auxiliar,'13050940','FINV');

		INSERT INTO con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
		VALUES('FAC',_numero_factura,2,fila_items.cod_cli,'03','INTERES','1.0000',fila_items.interes,fila_items.interes,'1.000000','PES',now(),_User,fila_items.interes,fila_items.interes,fila_items.cod_neg,'COL',_auxiliar,'27050940','FINV');

		INSERT INTO con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
		VALUES('FAC',_numero_factura,3,fila_items.cod_cli,'03','SEGURO','1.0000',fila_items.seguro,fila_items.seguro,'1.000000','PES',now(),_User,fila_items.seguro,fila_items.seguro,fila_items.cod_neg,'COL',_auxiliar,'28150901','FINV');

		cnt := cnt+1;


		/*-----------------------------
		   --CONTABILIZAR LA FACTURA--
		-------------------------------*/

		_grupo_transaccion = 0;
		SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

		select into rsProveedor * from proveedor where nit = fila_items.cod_cli;

		--(Cabecera)
		INSERT INTO con.comprobante(
			    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
			    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
			    total_items, moneda, fecha_aplicacion, aprobador, last_update,
			    user_update, creation_date, creation_user, base, usuario_aplicacion,
			    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
		    VALUES ('', 'FINV', 'FAC', _numero_factura, _grupo_transaccion, 'OP',
			    _PeriodoCte, now()::date, 'CONT FAC '||_numero_factura, fila_items.cod_cli, round(_ValorCuota), round(_ValorCuota),
			    3, 'PES', '0099-01-01 00:00:00', _User, now(),
			    _User, now(), _User, 'COL', _User,
			    '003', '', 0.00, '', '');

		--(Detalle)
		--debito
		_transaccion = 0;
		SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

		INSERT INTO con.comprodet(
			    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
			    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
			    tercero, documento_interno, last_update, user_update, creation_date,
			    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
			    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
			    tipo_referencia_3, referencia_3)
		    VALUES ('', 'FINV', 'FAC', _numero_factura, _grupo_transaccion, _transaccion,
			    _PeriodoCte, '13050941', _auxiliar, rsProveedor.payment_name, round(_ValorCuota), 0.00,
			    fila_items.cod_cli, 'FAC', now(), _User, now(),
			    _User, 'COL', 'FAC', _numero_factura, '', 0.00,
			    '', '', '', '',
			    '', '');

		--Capital
		_transaccion = 0;
		SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

		INSERT INTO con.comprodet(
			    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
			    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
			    tercero, documento_interno, last_update, user_update, creation_date,
			    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
			    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
			    tipo_referencia_3, referencia_3)
		    VALUES ('', 'FINV', 'FAC', _numero_factura, _grupo_transaccion, _transaccion,
			    _PeriodoCte, '13050940', _auxiliar, 'CAPITAL', 0.00, fila_items.capital,
			    fila_items.cod_cli, 'FAC', now(), _User, now(),
			    _User, 'COL', 'FAC', _numero_factura, '', 0.00,
			    '', '', '', '',
			    '', '');

		--Interes
		_transaccion = 0;
		SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

		INSERT INTO con.comprodet(
			    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
			    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
			    tercero, documento_interno, last_update, user_update, creation_date,
			    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
			    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
			    tipo_referencia_3, referencia_3)
		    VALUES ('', 'FINV', 'FAC', _numero_factura, _grupo_transaccion, _transaccion,
			    _PeriodoCte, '27050940', _auxiliar, 'INTERES', 0.00, fila_items.interes,
			    fila_items.cod_cli, 'FAC', now(), _User, now(),
			    _User, 'COL', 'FAC', _numero_factura, '', 0.00,
			    '', '', '', '',
			    '', '');
		--seguro
		_transaccion = 0;
		SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

		INSERT INTO con.comprodet(
			    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
			    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
			    tercero, documento_interno, last_update, user_update, creation_date,
			    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
			    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
			    tipo_referencia_3, referencia_3)
		    VALUES ('', 'FINV', 'FAC', _numero_factura, _grupo_transaccion, _transaccion,
			    _PeriodoCte, '28150901', _auxiliar, 'SEGURO', 0.00, fila_items.seguro,
			    fila_items.cod_cli, 'FAC', now(), _User, now(),
			    _User, 'COL', 'FAC', _numero_factura, '', 0.00,
			    '', '', '', '',
			    '', '');

		--ACTUALIZAR FACTURA CxC - Para que no se contabilice en el proceso normal.
		update con.factura
		set
			transaccion = _grupo_transaccion,
			periodo = _PeriodoCte,
			fecha_contabilizacion = now()
		where documento = _numero_factura;
		--------------------------------------------------------------------------------------------------------------------------


		/*-----------------------------
		   --Generar los IF's--
		-------------------------------*/

		SELECT INTO SerieIFLibranza SP_SerieDiferidosLibranza();

		--_cod_neg _User
		INSERT INTO ing_fenalco(
			    reg_status, dstrct, cod, codneg, tipodoc, valor, nit, periodo,
			    transaccion, transaccion_anulacion, fecha_contabilizacion, fecha_anulacion,
			    usuario_anulacion, fecha_contabilizacion_anulacion, last_update,
			    user_update, creation_date, creation_user, base, usuario_aplicacion,
			    cmc, fecha_doc, marca_reestructuracion, cuota)
		    VALUES ('', 'FINV', SerieIFLibranza, _cod_neg, 'LI', fila_items.interes, fila_items.cod_cli, '',
			    0, 0, '0099-01-01 00:00:00', '0099-01-01 00:00:00',
			    '', '0099-01-01 00:00:00', now(),
			    '', now(), _User, 'COL', '',
			    'LI', fila_items.fecha, 'N', fila_items.item::integer);


		/*---------------------------------------
		   --Generar Control de CxP Aseguradora--
		-----------------------------------------*/

		SELECT INTO SerieCxPSeguro SP_SerieSegurosLibranza();

		INSERT INTO control_seguros_libranza(
			    reg_status, dstrct, nit, cod_neg, tipodoc, documento, cuota,
			    fecha_vencimiento, valor, periodo, transaccion, fecha_contabilizacion,
			    creation_date, creation_user, usuario_aplicacion, last_update, user_update)
		    VALUES (
			    '', 'FINV', fila_items.cod_cli, _cod_neg, 'CXP_DIF', SerieCxPSeguro, fila_items.item,
			    fila_items.fecha, fila_items.seguro, '', 0, '0099-01-01 00:00:00',
			    now(), _User, '', now(), '');


	END LOOP;

	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cxclibranza(character varying, character varying)
  OWNER TO postgres;
