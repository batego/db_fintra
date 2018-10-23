-- Function: sp_reestructurarmicrocredito(character varying, character varying)

-- DROP FUNCTION sp_reestructurarmicrocredito(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_reestructurarmicrocredito(negociobase character varying, usuario character varying)
  RETURNS text AS
$BODY$

DECLARE

	CarteraGeneral record;
	CarteraGeneral2 record;
	DocNegAcept record;
	NegociosReestructuracion record;


	_PeriodoCte numeric;
	cnt numeric;
	cnt2 numeric;
	count numeric;

	_numerofac_query varchar;
	_auxiliar varchar;
	_numero_factura varchar;
	_numero_factura_seguro varchar;
	_hc_factura varchar;
	Negocio varchar;

	Validador boolean := true;

	mcad TEXT;

	miHoy date;

BEGIN
	mcad := 'OK';
	miHoy = now()::date;
	--_PeriodoCte = replace(substring(miHoy,1,7),'-','')::numeric;
	cnt = 1;
	cnt2 = 1;
	count = 3;

	--Edgar: Para buscar el negocio que se va a ajustar!
	SELECT INTO NegociosReestructuracion * FROM rel_negocios_reestructuracion WHERE negocio_reestructuracion = NegocioBase;
	--Negocio|negocio_base|NegociosReestructuracion.negocio_base


	SELECT INTO _numero_factura_seguro get_lcod('ICAC');

	FOR CarteraGeneral IN

		SELECT *
		,(select valor_unitario from con.factura_detalle where documento = fac.documento and descripcion = 'SEGURO') as valor_seguro
		,(now()::date-fecha_vencimiento::date) as diff_day
		,(SELECT max(fecha_vencimiento)
			FROM con.factura fra
			WHERE fra.dstrct = 'FINV'
			  AND fra.valor_saldo > 0
			  AND fra.reg_status = ''
			  AND fra.negasoc = fac.negasoc
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF','MI','CA')
			  AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric < replace(substring(now()::date,1,7),'-','')::numeric
			GROUP BY negasoc
		) as maxdate
		FROM con.factura as fac
		WHERE fac.reg_status = ''
		    AND fac.dstrct = 'FINV'
		    AND fac.tipo_documento in ('FAC','NDC')
		    AND fac.valor_saldo > 0
		    AND substring(documento,1,2) not in ('CP','FF','DF','MI','CA')
		    AND fac.negasoc = NegociosReestructuracion.negocio_base
		ORDER BY fac.num_doc_fen::numeric

	LOOP

		--#PASOS:
		--A)IA PARA EL AJUSTE DEL CONCEPTO DE SEGURO

		IF ( (miHoy - CarteraGeneral.fecha_vencimiento::date) <= 0 ) THEN

			SELECT INTO _hc_factura cuenta from con.cmc_doc where cmc = CarteraGeneral.cmc and tipodoc = CarteraGeneral.tipo_documento;

			--GENERA LA CABECERA DEL DOCUMENTO DE INGRESO (NOTA AJUSTE)

			UPDATE con.factura
			SET valor_abono = (valor_abono+CarteraGeneral.valor_seguro::numeric),
			valor_saldo = (valor_saldo-CarteraGeneral.valor_seguro::numeric)
			, valor_abonome = (valor_abonome+CarteraGeneral.valor_seguro), valor_saldome = (valor_saldome-CarteraGeneral.valor_seguro)
			WHERE documento = CarteraGeneral.documento;

			IF ( Validador ) THEN
				raise notice 'cabecera';
				INSERT INTO con.ingreso
				(
				dstrct,
				tipo_documento,
				num_ingreso,
				codcli,
				nitcli,
				concepto,
				tipo_ingreso,
				fecha_consignacion,
				fecha_ingreso,
				branch_code,
				bank_account_no,
				codmoneda,
				agencia_ingreso,
				descripcion_ingreso,
				vlr_ingreso,
				vlr_ingreso_me,
				vlr_tasa,
				fecha_tasa,
				cant_item,
				creation_user,
				creation_date,
				base,
				cuenta,
				tipo_referencia_1,
				referencia_1
				)
				VALUES('FINV','ICA',_numero_factura_seguro,CarteraGeneral.codcli,CarteraGeneral.nit,'FE','C',now(),now(),'CAJA REFI MICRO','REFINANCIACION MICRO','PES','OP','AJUSTE FACTURAS DE SEGURO POR REESTRUCTURACION'
					,CarteraGeneral.valor_seguro,CarteraGeneral.valor_seguro,'1.000000',substring(now(),1,10)::date,CarteraGeneral.cantidad_items,Usuario,now(),'COL','28150702','NEG',NegociosReestructuracion.negocio_base);

				Validador = false;
			END IF;

			--GENERA EL DETALLE DEL DOCUMENTO DE INGRESO (NOTA AJUSTE SEGURO)
			INSERT INTO con.ingreso_detalle
			(
			dstrct,
			tipo_documento,
			num_ingreso,
			item,
			nitcli,
			valor_ingreso,
			valor_ingreso_me,
			factura,
			fecha_factura,
			tipo_doc,
			documento,
			creation_user,
			creation_date,
			base,
			cuenta,
			descripcion,
			valor_tasa,
			saldo_factura,
			tipo_referencia_1,
			referencia_1
			)
			VALUES('FINV','ICA',_numero_factura_seguro,cnt2,CarteraGeneral.nit,CarteraGeneral.valor_seguro,CarteraGeneral.valor_seguro,CarteraGeneral.documento,CarteraGeneral.fecha_factura,'FAC',CarteraGeneral.documento
				,Usuario,now(),'COL',_hc_factura,CarteraGeneral.descripcion,'1.0000000000',CarteraGeneral.valor_seguro,'NEG',NegociosReestructuracion.negocio_base);

		END IF;
		--


		--B) Generar las Facturas de CAT's y la MI atravesá | Marcarlas en: documentos_neg_aceptado, para q no se generen con el CRON.
		SELECT INTO DocNegAcept * FROM documentos_neg_aceptado WHERE cod_neg = NegociosReestructuracion.negocio_base AND item = CarteraGeneral.num_doc_fen;
		IF FOUND THEN

			--GENERA INTERES CORRIENTE

			--Busco cuál es la factura que debo generar
			_PeriodoCte = replace(substring(CarteraGeneral.fecha_vencimiento,1,7),'-','')::numeric;


			raise notice 'ciclo: %',(DocNegAcept.fecha-CarteraGeneral.maxdate);
			raise notice 'fija: %',(CarteraGeneral.maxdate-DocNegAcept.fecha);
			raise notice 'interes_causado: %',DocNegAcept.interes_causado;
			raise notice 'num_doc_fen: %',CarteraGeneral.num_doc_fen;


			IF ( (DocNegAcept.fecha::date-CarteraGeneral.maxdate::date)::numeric between 29 and 34 and DocNegAcept.interes_causado = 0 ) THEN

				_numerofac_query = '';

				raise notice 'Anticipa Interes';
				SELECT INTO _numerofac_query get_lcod('CXC_INTERES_MC');

				insert into con.factura
				(
				tipo_documento,
				documento,
				nit,
				codcli,
				concepto,
				fecha_factura,
				fecha_vencimiento,
				descripcion,
				moneda,
				forma_pago,
				negasoc,
				base,
				agencia_facturacion,
				agencia_cobro,
				creation_date,
				creation_user,
				cantidad_items,
				valor_tasa,
				valor_factura,
				valor_facturame,
				valor_saldo,
				valor_saldome,
				num_doc_fen,
				tipo_ref1,
				ref1,
				cmc,
				dstrct
				)
				values('FAC',_numerofac_query,CarteraGeneral.nit,CarteraGeneral.codcli,'',now()::date,CarteraGeneral.fecha_vencimiento::date,'CXC_INTERES_MC_REESTRUCTURACION','PES','CREDITO',CarteraGeneral.negasoc,'COL','OP','BQ',now(),Usuario,'1','1.000000',DocNegAcept.interes,DocNegAcept.interes,DocNegAcept.interes,DocNegAcept.interes,CarteraGeneral.num_doc_fen,'','','CA','FINV');

				--------------
				_auxiliar = 'RD-' || CarteraGeneral.nit;
				--------------

				insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
				values('FAC',_numerofac_query,1,CarteraGeneral.nit,'','INTERESES REESTRUCTURACION','1.0000',DocNegAcept.interes,DocNegAcept.interes,'1.000000','PES',now(),'HCUELLO',DocNegAcept.interes,DocNegAcept.interes,CarteraGeneral.documento,'COL',_auxiliar,'I010130014169','FINV');

				update documentos_neg_aceptado set interes_causado = interes, fch_interes_causado = now(), causar = 'N' where cod_neg = CarteraGeneral.negasoc and item = CarteraGeneral.num_doc_fen;

			END IF;
			--

			--GENERA IMPUESTO CAT
			IF ( DocNegAcept.documento_cat = '' ) THEN

				_numerofac_query = '';

				raise notice 'Anticipa Interes';
				SELECT INTO _numerofac_query get_lcod('CXC_CAT_MC');

				insert into con.factura
				(
				tipo_documento,
				documento,
				nit,
				codcli,
				concepto,
				fecha_factura,
				fecha_vencimiento,
				descripcion,
				moneda,
				forma_pago,
				negasoc,
				base,
				agencia_facturacion,
				agencia_cobro,
				creation_date,
				creation_user,
				cantidad_items,
				valor_tasa,
				valor_factura,
				valor_facturame,
				valor_saldo,
				valor_saldome,
				num_doc_fen,
				tipo_ref1,
				ref1,
				cmc,
				dstrct
				)
				values('FAC',_numerofac_query,CarteraGeneral.nit,CarteraGeneral.codcli,'',now()::date,CarteraGeneral.fecha_vencimiento::date,'CXC_CAT_MC_REESTRUCTURACION','PES','CREDITO',CarteraGeneral.negasoc,'COL','OP','BQ',now(),Usuario,'1','1.000000',DocNegAcept.cat,DocNegAcept.cat,DocNegAcept.cat,DocNegAcept.cat,CarteraGeneral.num_doc_fen,'','','CA','FINV');

				--------------
				_auxiliar = 'RD-' || CarteraGeneral.nit;
				--------------

				insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
				values('FAC',_numerofac_query,1,CarteraGeneral.nit,'','IMPUESTO CAT REESTRUCTURACION','1.0000',(DocNegAcept.cat/1.19),(DocNegAcept.cat/1.19),'1.000000','PES',now(),Usuario,(DocNegAcept.cat/1.19),(DocNegAcept.cat/1.19),CarteraGeneral.documento,'COL',_auxiliar,'I010130014144','FINV');

				insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
				values('FAC',_numerofac_query,2,CarteraGeneral.nit,'','IVA CAT REESTRUCTURACION','1.0000',(DocNegAcept.cat/1.19)*0.19,(DocNegAcept.cat/1.19)*0.19,'1.000000','PES',now(),Usuario,(DocNegAcept.cat/1.19)*0.19,(DocNegAcept.cat/1.19)*0.19,CarteraGeneral.documento,'COL',_auxiliar,'24080109','FINV');

				update documentos_neg_aceptado set documento_cat = _numerofac_query, causar = 'N' where cod_neg = CarteraGeneral.negasoc and item = CarteraGeneral.num_doc_fen;
			END IF;

		END IF;

		cnt2 := cnt2+1;

	END LOOP;
	--

	UPDATE con.ingreso SET vlr_ingreso = (select sum(valor_ingreso) from con.ingreso_detalle where num_ingreso = con.ingreso.num_ingreso), vlr_ingreso_me = (select sum(valor_ingreso) from con.ingreso_detalle where num_ingreso = con.ingreso.num_ingreso) WHERE num_ingreso = _numero_factura_seguro;

	SELECT INTO _numero_factura get_lcod('ICAC');

	--SEGUNDO BLOQUE
	FOR CarteraGeneral2 IN

		SELECT *
		FROM con.factura as fac
		WHERE fac.reg_status = ''
		    AND fac.dstrct = 'FINV'
		    AND fac.tipo_documento in ('FAC','NDC')
		    AND fac.valor_saldo > 0
		    AND substring(documento,1,2) not in ('CP','FF','DF')
		    AND fac.negasoc = NegociosReestructuracion.negocio_base
		ORDER BY fac.num_doc_fen::numeric

	LOOP

		--C) Generar las IA con su respectivo Cta Cabecera (23051104 para todos) y la Ccta Detalle (Es el HC de la CxC) que afecte a cada documento.
		--Secuencia de la Nota

		SELECT INTO _hc_factura cuenta from con.cmc_doc where cmc = CarteraGeneral2.cmc and tipodoc = CarteraGeneral2.tipo_documento;

		--GENERA LA CABECERA DEL DOCUMENTO DE INGRESO (NOTA AJUSTE)
		IF ( cnt = 1 ) THEN

			INSERT INTO con.ingreso
			(
			dstrct,
			tipo_documento,
			num_ingreso,
			codcli,
			nitcli,
			concepto,
			tipo_ingreso,
			fecha_consignacion,
			fecha_ingreso,
			branch_code,
			bank_account_no,
			codmoneda,
			agencia_ingreso,
			descripcion_ingreso,
			vlr_ingreso,
			vlr_ingreso_me,
			vlr_tasa,
			fecha_tasa,
			cant_item,
			creation_user,
			creation_date,
			base,
			cuenta,
			tipo_referencia_1,
			referencia_1
			)
			VALUES('FINV','ICA',_numero_factura,CarteraGeneral2.codcli,CarteraGeneral2.nit,'FE','C',now(),now(),'CAJA REFI MICRO','REFINANCIACION MICRO','PES','OP','AJUSTE FACTURA CAPITAL POR REESTRUCTURACION',CarteraGeneral2.valor_factura
				,CarteraGeneral2.valor_factura,'1.000000',substring(now(),1,10)::date,CarteraGeneral2.cantidad_items,Usuario,now(),'COL','23051101','NEG',CarteraGeneral2.negasoc);
			--'CAJA GENERAL','CAJA'

			INSERT INTO con.ingreso_detalle
			(
			dstrct,
			tipo_documento,
			num_ingreso,
			item,
			nitcli,
			valor_ingreso,
			valor_ingreso_me,
			factura,
			fecha_factura,
			tipo_doc,
			documento,
			creation_user,
			creation_date,
			base,
			cuenta,
			descripcion,
			valor_tasa,
			saldo_factura,
			tipo_referencia_1,
			referencia_1
			)
			VALUES('FINV','ICA',_numero_factura,1,CarteraGeneral2.nit,NegociosReestructuracion.gac,NegociosReestructuracion.gac,'',CarteraGeneral2.fecha_factura,'','',Usuario,now(),'COL','I010130014235','AJUSTE AL GASTO DE COBRANZA'
				,'1.0000000000',NegociosReestructuracion.gac,'NEG',CarteraGeneral2.negasoc);


			INSERT INTO con.ingreso_detalle
			(
			dstrct,
			tipo_documento,
			num_ingreso,
			item,
			nitcli,
			valor_ingreso,
			valor_ingreso_me,
			factura,
			fecha_factura,
			tipo_doc,
			documento,
			creation_user,
			creation_date,
			base,
			cuenta,
			descripcion,
			valor_tasa,
			saldo_factura,
			tipo_referencia_1,
			referencia_1
			)
			VALUES('FINV','ICA',_numero_factura,2,CarteraGeneral2.nit,NegociosReestructuracion.intxmora,NegociosReestructuracion.intxmora,'',CarteraGeneral2.fecha_factura,'','',Usuario,now()
				,'COL','I010130014174','AJUSTE AL INTERES MORATORIO','1.0000000000',NegociosReestructuracion.intxmora,'NEG',CarteraGeneral2.negasoc);


		END IF;

		--GENERA EL DETALLE DEL DOCUMENTO DE INGRESO (NOTA AJUSTE)
		INSERT INTO con.ingreso_detalle
		(
		dstrct,
		tipo_documento,
		num_ingreso,
		item,
		nitcli,
		valor_ingreso,
		valor_ingreso_me,
		factura,
		fecha_factura,
		tipo_doc,
		documento,
		creation_user,
		creation_date,
		base,
		cuenta,
		descripcion,
		valor_tasa,
		saldo_factura,
		tipo_referencia_1,
		referencia_1
		)
		VALUES('FINV','ICA',_numero_factura,count,CarteraGeneral2.nit,CarteraGeneral2.valor_saldo,CarteraGeneral2.valor_saldo,CarteraGeneral2.documento,CarteraGeneral2.fecha_factura,'FAC'
			,CarteraGeneral2.documento,Usuario,now(),'COL',_hc_factura,CarteraGeneral2.descripcion,'1.0000000000',CarteraGeneral2.valor_saldo,'NEG',CarteraGeneral2.negasoc);

		--D) Saldar las facturas pendientes
		UPDATE con.factura SET valor_abono = valor_factura, valor_saldo = 0 , valor_abonome = valor_factura, valor_saldome = 0 WHERE documento = CarteraGeneral2.documento;

		cnt := cnt+1;
		count := count+1;

	END LOOP;
	--

	UPDATE con.ingreso SET vlr_ingreso = (select sum(valor_ingreso) from con.ingreso_detalle where num_ingreso = con.ingreso.num_ingreso), vlr_ingreso_me = (select sum(valor_ingreso) from con.ingreso_detalle where num_ingreso = con.ingreso.num_ingreso) WHERE num_ingreso = _numero_factura;

	RETURN mcad;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_reestructurarmicrocredito(character varying, character varying)
  OWNER TO postgres;
