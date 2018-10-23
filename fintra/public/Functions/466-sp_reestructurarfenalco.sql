-- Function: sp_reestructurarfenalco(integer, character varying)

-- DROP FUNCTION sp_reestructurarfenalco(integer, character varying);

CREATE OR REPLACE FUNCTION sp_reestructurarfenalco(idrop integer, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

 listaNegocioExtracto record;
 recordFacturas record;
 recordCliente record;
 recordIFenalco record;
 IntxMora numeric:=0;
 gastoCobranza numeric:=0;
 numeroIAcarteraIndemnizada varchar:='';
 numeroIAcarteraFintraFiducia varchar:='';
 validarCabeceraIndemnizada boolean :=true;
 validarCabeceraFintraFiducia boolean :=true;
 validarCreacionNegocio boolean :=false;
 validarCrearComprobante boolean :=false;
 itemsIndemnizada integer:=0;
 itemsFintraFiducia integer:=0;
 numeroComprobante varchar:='';
 grupoTransaccion integer:=0;
 transaccionDetalle integer:=0;
 itemComprobante integer :=1;
 valorIndemnizado numeric;
 valorFintraFiducia numeric;
 totalDebito numeric;
 crearNegocio varchar:='';
 valorIF numeric:=0;
 validarIAIFintra boolean :=true;
 validarIAIFiducia boolean :=true;
 numeroIAIFintra varchar:='';
 numeroIAIFiducia varchar:='';
 itemsIAIFintra integer:=0;
 itemsIAIFiducia integer:=0;
 diasInteres integer:=0;
 fechanterior date;
 resta numeric;
 nuevoInteres numeric;
 diferencia numeric;
 cuentaIngreso varchar;




BEGIN

 --tabla temporal con pago de aldair
	INSERT INTO copia_reestructuracion_cartera
		SELECT reg_status, dstrct, tipo_documento, documento, nit, codcli, concepto,
		       fecha_factura, fecha_vencimiento, fecha_ultimo_pago, fecha_impresion,
		       descripcion, observacion, valor_factura, valor_abono, valor_saldo,
		       valor_facturame, valor_abonome, valor_saldome, valor_tasa, moneda,
		       cantidad_items, forma_pago, agencia_facturacion, agencia_cobro,
		       zona, clasificacion1, clasificacion2, clasificacion3, transaccion,
		       transaccion_anulacion, fecha_contabilizacion, fecha_anulacion,
		       fecha_contabilizacion_anulacion, base, last_update, user_update,
		       creation_date, creation_user, fecha_probable_pago, flujo, rif,
		       cmc, usuario_anulo, formato, agencia_impresion, periodo, valor_tasa_remesa,
		       negasoc, num_doc_fen, obs, pagado_fenalco, corficolombiana, tipo_ref1,
		       ref1, tipo_ref2, ref2, dstrct_ultimo_ingreso, tipo_documento_ultimo_ingreso,
		       num_ingreso_ultimo_ingreso, item_ultimo_ingreso, fec_envio_fiducia,
		       nit_enviado_fiducia, tipo_referencia_1, referencia_1, tipo_referencia_2,
		       referencia_2, tipo_referencia_3, referencia_3, nc_traslado, fecha_nc_traslado,
		       tipo_nc, numero_nc, factura_traslado, factoring_formula_aplicada,
		       nit_endoso, devuelta, fc_eca, fc_bonificacion, indicador_bonificacion,
		       fi_bonificacion, endoso_fenalco, endoso_fiducia, causacion_int_ms,
		       fecha_causacion_int_ms
		FROM con.factura WHERE negasoc in  (
		SELECT dtrop.negocio FROM detalle_rop dtrop INNER JOIN recibo_oficial_pago rop on (rop.id=dtrop.id_rop)
		WHERE id_rop=idrop and dtrop.negocio !='' --AND dtrop.porcentaje_cta_inicial !=100
		AND rop.cod_rop like 'EPR%' GROUP BY dtrop.negocio,rop.creation_date::date ORDER BY dtrop.negocio );

 FOR listaNegocioExtracto IN SELECT dtrop.negocio,rop.creation_date::date FROM detalle_rop dtrop INNER JOIN recibo_oficial_pago rop on (rop.id=dtrop.id_rop)
			     WHERE id_rop=idRop and dtrop.negocio !='' --AND dtrop.porcentaje_cta_inicial !=100
			     AND rop.cod_rop like 'EPR%' GROUP BY dtrop.negocio,rop.creation_date::date ORDER BY dtrop.negocio
LOOP

    validarCreacionNegocio:=true;
    validarCabeceraIndemnizada:=true;
    validarCabeceraFintraFiducia:=true;
    validarCrearComprobante:=false;
    itemsIndemnizada:=0;
    itemsFintraFiducia:=0;
    numeroIAcarteraIndemnizada:='';
    numeroIAcarteraFintraFiducia:='';
    numeroComprobante :='';
    valorIndemnizado:=0;
    valorFintraFiducia:=0;
    validarIAIFintra:=true;
    validarIAIFiducia:=true;
    numeroIAIFintra:='';
    numeroIAIFiducia:='';
    itemsIAIFintra:=0;
    itemsIAIFiducia:=0;
    diasInteres:=0;
    resta=0;
    nuevoInteres:=0;
    diferencia:=0;
    cuentaIngreso:='';

    /********************************************
    *1.)ANULAR INTERESES FENALCO SIN ANASTACIA**/

     FOR recordIFenalco IN SELECT factd.valor_unitario,
			   listaNegocioExtracto.creation_date::date -fac.fecha_vencimiento::date as dias_mora,
		           fac.*,(SELECT cuenta FROM con.cmc_doc where cmc =fac.cmc and tipodoc='FAC') as cuenta FROM con.factura fac
		           INNER JOIN con.factura_detalle factd on (factd.documento=fac.documento)
			   WHERE fac.negasoc =listaNegocioExtracto.negocio
			   AND  factd.descripcion='INTERESES'
			   AND substring(fac.documento,1,2) not in ('CP','FF','DF') AND fac.valor_saldo > 0
			   AND fac.reg_status !='A'  order by cmc,fac.documento

     LOOP

        resta=0;
        nuevoInteres:=0;
        diferencia:=0;
        cuentaIngreso:='';

	IF (recordIFenalco.dias_mora < 0) THEN

		IF(recordIFenalco.cuenta LIKE '13%')THEN --FINTRA

			itemsIAIFintra:=itemsIAIFintra+1;

			IF(validarIAIFintra)THEN
				validarIAIFintra:=false;
				SELECT INTO numeroIAIFintra get_lcod('ICAC');
                                RAISE NOTICE 'NUMERO IA FINTRA INTERES: %',numeroIAIFintra;
				/*****************************************************
				************* 1.) CABECERA DE LA IA INTERESES FINTRA**/
				SELECT INTO recordCliente  codcli,nomcli,nit FROM cliente where nit=(SELECT COD_CLI FROM negocios where cod_neg=listaNegocioExtracto.negocio);
				INSERT INTO con.ingreso(dstrct,tipo_documento,num_ingreso,codcli,nitcli,
					     concepto,tipo_ingreso,fecha_consignacion,fecha_ingreso,branch_code,
					     bank_account_no,codmoneda,agencia_ingreso,descripcion_ingreso,vlr_ingreso,
					     vlr_ingreso_me,vlr_tasa,fecha_tasa,cant_item,creation_user,
					     creation_date,base,cuenta)

				VALUES('FINV','ICA',numeroIAIFintra,recordCliente.codcli,recordCliente.nit,
				       'FE','C',now(),now(),'CAJA TESORERIA',
					'BARRANQUILLA','PES','OP','AJUSTE IF FINTRA POR REESTRUCTURACION',1,
				       1,'1.000000',substring(now(),1,10)::date,1,usuario,
				       now(),'COL','27050901');
			 END IF;


			/* ***********************************************
			* Verificamos si es la primera cuota corriente *
			* Despues de la vencidas                        *
			*************************************************/
			resta= recordIFenalco.fecha_vencimiento - fechanterior;

			IF(resta between 27  and 34)THEN --esta condicion solo me sirve para saber cual es al cuota

				nuevoInteres:=ROUND((recordIFenalco.valor_unitario/30)*(diasInteres));

				--AGREGAMOS UN ITEM CON LA DIFERENCIA DEL INTERES
				--VALIDAMOS LA CUENTA FA O FB.

				diferencia:=ROUND(recordIFenalco.valor_unitario-nuevoInteres);
				IF(substring(listaNegocioExtracto.negocio,1,2) like 'FA%')THEN
				  cuentaIngreso:='I010140014169';
				ELSE
				  cuentaIngreso:='I020140014169';
				END IF;

				INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
								valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
								documento,creation_user,creation_date,base,cuenta,descripcion,
								valor_tasa,saldo_factura)
				VALUES('FINV','ICA',numeroIAIFintra,itemsIAIFintra,recordCliente.nit,
					nuevoInteres,nuevoInteres,'',now()::date,'',
					'',usuario,now(),'COL',cuentaIngreso,
					'AJUSTE A SALDO','1.0000000000',nuevoInteres);

				--EL RESTO SE LO LLEVO A CARTERA DEL CLIENTE.
				nuevoInteres:=diferencia;
				itemsIAIFintra:=itemsIAIFintra+1;
                        ELSE
                           nuevoInteres:=recordIFenalco.valor_unitario;
			END IF;

			--GENERA EL DETALLE DEL DOCUMENTO DE INGRESO (NOTA AJUSTE FINTRA)
			INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
							valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
							documento,creation_user,creation_date,base,cuenta,descripcion,
							valor_tasa,saldo_factura)
			VALUES('FINV','ICA',numeroIAIFintra,itemsIAIFintra,recordCliente.nit,
				nuevoInteres,nuevoInteres,recordIFenalco.documento,recordIFenalco.fecha_factura,'FAC',
				recordIFenalco.documento,usuario,now(),'COL',recordIFenalco.cuenta,
				recordIFenalco.descripcion,'1.0000000000',nuevoInteres);

			--ACTUALIZAR SALDOS POR FACTURA.
	                UPDATE con.factura SET
				valor_abono = valor_abono + nuevoInteres,
				valor_saldo = valor_saldo - nuevoInteres ,
				valor_abonome = valor_abonome + nuevoInteres,
				valor_saldome =valor_saldome - nuevoInteres,
				user_update=usuario,
				last_update=now()
			WHERE documento = recordIFenalco.documento;


		ELSIF(recordIFenalco.cuenta LIKE '16%') THEN  --FIDUCIA

			itemsIAIFiducia:=itemsIAIFiducia+1;
			IF(validarIAIFiducia)THEN
				validarIAIFiducia:=false;
				SELECT INTO numeroIAIFiducia get_lcod('ICAC');
                                RAISE NOTICE 'NUMERO IA FIDUCIA INTERES: %',numeroIAIFiducia;
				/*******************************************************
				************* 1.) CABECERA DE LA IA INTERESES FIDUCIA**/
				SELECT INTO recordCliente  codcli,nomcli,nit FROM cliente where nit=(SELECT COD_CLI FROM negocios where cod_neg=listaNegocioExtracto.negocio);
				INSERT INTO con.ingreso(dstrct,tipo_documento,num_ingreso,codcli,nitcli,
					     concepto,tipo_ingreso,fecha_consignacion,fecha_ingreso,branch_code,
					     bank_account_no,codmoneda,agencia_ingreso,descripcion_ingreso,vlr_ingreso,
					     vlr_ingreso_me,vlr_tasa,fecha_tasa,cant_item,creation_user,
					     creation_date,base,cuenta)

				VALUES('FINV','ICA',numeroIAIFiducia,recordCliente.codcli,recordCliente.nit,
				       'FE','C',now(),now(),'CAJA TESORERIA',
					'BARRANQUILLA','PES','OP','AJUSTE IF FIDUCIA POR REESTRUCTURACION',1,
				       1,'1.000000',substring(now(),1,10)::date,1,usuario,
				       now(),'COL','16252104');
			END IF;

			/* ***********************************************
			* Verificamos si es la primera cuaota corriente *
			* Despues de la vencidas                        *
			*************************************************/
			resta= recordIFenalco.fecha_vencimiento - fechanterior;

			IF(resta between 27  and 34)THEN --esta condicion solo me sirve para saber cual es al cuota

				nuevoInteres:=ROUND((recordIFenalco.valor_unitario/30)*(diasInteres));

				--AGREGAMOS UN ITEM CON LA DIFERENCIA DEL INTERES
				--VALIDAMOS LA CUENTA FA O FB.

				diferencia:=ROUND(recordIFenalco.valor_unitario-nuevoInteres);
				IF(substring(listaNegocioExtracto.negocio,1,2) like 'FA%')THEN
				  cuentaIngreso:='I010140014169';
				ELSE
				  cuentaIngreso:='I020140014169';
				END IF;

				INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
								valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
								documento,creation_user,creation_date,base,cuenta,descripcion,
								valor_tasa,saldo_factura)
				VALUES('FINV','ICA',numeroIAIFiducia,itemsIAIFintra,recordCliente.nit,
					nuevoInteres,nuevoInteres,'',now()::date,'',
					'',usuario,now(),'COL',cuentaIngreso,
					'AJUSTE A SALDO','1.0000000000',nuevoInteres);

				--EL RESTO SE LO LLEVO A CARTERA DEL CLIENTE.
				nuevoInteres:=diferencia;
				itemsIAIFiducia:=itemsIAIFiducia+1;

                        ELSE
                           nuevoInteres:=recordIFenalco.valor_unitario;
			END IF;

			--GENERA EL DETALLE DEL DOCUMENTO DE INGRESO (NOTA AJUSTE FINTRA)
			INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
							valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
							documento,creation_user,creation_date,base,cuenta,descripcion,
							valor_tasa,saldo_factura)
			VALUES('FINV','ICA',numeroIAIFiducia,itemsIAIFiducia,recordCliente.nit,
				nuevoInteres,nuevoInteres,recordIFenalco.documento,recordIFenalco.fecha_factura,'FAC',
				recordIFenalco.documento,usuario,now(),'COL',recordIFenalco.cuenta,
				recordIFenalco.descripcion,'1.0000000000',nuevoInteres);


			--ACTUALIZAR SALDOS POR FACTURA.
	                UPDATE con.factura SET
				valor_abono = valor_abono + nuevoInteres,
				valor_saldo = valor_saldo - nuevoInteres ,
				valor_abonome = valor_abonome + nuevoInteres,
				valor_saldome =valor_saldome - nuevoInteres,
				user_update=usuario,
				last_update=now()
			WHERE documento = recordIFenalco.documento;


		END IF;
	ELSE
	   --dias de los intereses a fecha de corte
	   diasInteres:=recordIFenalco.dias_mora;
           fechanterior:=recordIFenalco.fecha_vencimiento;
	END IF;

     END LOOP;

     /***************************************************************
     ********ACTUALIZAMOS LA CABECERA DE LAS NOTASDE INTERES*********/
	IF(numeroIAIFintra !='')THEN
          UPDATE con.ingreso
		SET vlr_ingreso =(SELECT coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso =numeroIAIFintra),
		vlr_ingreso_me = (SELECT coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso =numeroIAIFintra),
		cant_item= itemsIAIFintra
	  WHERE num_ingreso = numeroIAIFintra;
        END IF;

	IF(numeroIAIFiducia !='')THEN
	  UPDATE con.ingreso
		SET vlr_ingreso =(SELECT coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso =numeroIAIFiducia),
		vlr_ingreso_me = (SELECT coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso =numeroIAIFiducia),
		cant_item= itemsIAIFiducia
	  WHERE num_ingreso = numeroIAIFiducia;

        END IF;

       -- IF (listaNegocioExtracto.negocio IS NOT NULL) THEN
		UPDATE ing_fenalco  SET reg_status='A' WHERE codneg =listaNegocioExtracto.negocio AND periodo='' AND marca_reestructuracion !='S' ;
       -- END IF;

    /***********************************************************
    ************ 3.) BUSAMOS LAS FACTURAS POR NEGOCIO  ********/
    FOR recordFacturas IN SELECT *,(SELECT cuenta FROM con.cmc_doc where cmc =fac.cmc and tipodoc='FAC') as cuenta FROM con.factura fac WHERE fac.negasoc =listaNegocioExtracto.negocio
			 AND substring(fac.documento,1,2) not in ('CP','FF','DF') AND valor_saldo > 0
			 AND fac.reg_status !='A'  order by cmc,documento
    LOOP


        validarCrearComprobante:=true;
	RAISE NOTICE 'NEGOCIO % CUENTA: %',recordFacturas.negasoc,recordFacturas.cuenta;
        IF(recordFacturas.cuenta LIKE '94%')THEN --INDEMNIZADA u ORDEN

                itemsIndemnizada:=itemsIndemnizada+1;
                --VALIDAR CABECERA
                IF(validarCabeceraIndemnizada)THEN
			validarCabeceraIndemnizada:=false;
                        SELECT INTO numeroIAcarteraIndemnizada get_lcod('ICAC');
                        RAISE NOTICE 'NEGOCIO: % NUMERO DE IA INDEMNIZADA: %',listaNegocioExtracto.negocio,numeroIAcarteraIndemnizada;
			/****************************************************
			************* 1.) CABECERA DE LA IA INDEMNIZADA e ORDEN***/
			SELECT INTO recordCliente  codcli,nomcli,nit FROM cliente where nit=(SELECT COD_CLI FROM negocios where cod_neg=listaNegocioExtracto.negocio);
			INSERT INTO con.ingreso(dstrct,tipo_documento,num_ingreso,codcli,nitcli,
				     concepto,tipo_ingreso,fecha_consignacion,fecha_ingreso,branch_code,
				     bank_account_no,codmoneda,agencia_ingreso,descripcion_ingreso,vlr_ingreso,
				     vlr_ingreso_me,vlr_tasa,fecha_tasa,cant_item,creation_user,
				     creation_date,base,cuenta)

			VALUES('FINV','ICA',numeroIAcarteraIndemnizada,recordCliente.codcli,recordCliente.nit,
			       'FE','C',now(),now(),'CAJA TESORERIA',
			       'BARRANQUILLA','PES','OP','AJUSTE FACTURAS INDEMNIZADAS POR REESTRUCTURACION',1,
			       1,'1.000000',substring(now(),1,10)::date,1,usuario,
			       now(),'COL','94350104');

                END IF;

		--GENERA EL DETALLE DEL DOCUMENTO DE INGRESO (NOTA AJUSTE INDEMNIZADA u ORDEN)
			INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
							valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
							documento,creation_user,creation_date,base,cuenta,descripcion,
							valor_tasa,saldo_factura)
			VALUES('FINV','ICA',numeroIAcarteraIndemnizada,itemsIndemnizada,recordCliente.nit,
				recordFacturas.valor_saldo,recordFacturas.valor_saldo,recordFacturas.documento,recordFacturas.fecha_factura,'FAC',
				recordFacturas.documento,usuario,now(),'COL',recordFacturas.cuenta,
				recordFacturas.descripcion,'1.0000000000',recordFacturas.valor_saldo);

		--ACTUALIZAR SALDOS POR FACTURA.
	        UPDATE con.factura SET valor_abono = valor_factura, valor_saldo = 0 , valor_abonome = valor_factura, valor_saldome = 0, user_update=usuario, last_update=now() WHERE documento = recordFacturas.documento;


	ELSIF(recordFacturas.cuenta LIKE '13%' OR recordFacturas.cuenta LIKE '16%')THEN--CARTERA FINTRA O FIDUCIA

		itemsFintraFiducia:=itemsFintraFiducia+1;
                --validar cabecera
                IF(validarCabeceraFintraFiducia)THEN

			validarCabeceraFintraFiducia:=false;
                        SELECT INTO numeroIAcarteraFintraFiducia get_lcod('ICAC');
                        RAISE NOTICE 'NEGOCIO: % NUMERO DE IA FINTRA O FIDUCIA: %',listaNegocioExtracto.negocio,numeroIAcarteraFintraFiducia;
			/***************************************************************
			************* 1.) CABECERA DE LA IA CARTERA FINTRA Y FIDUCIA***/
			SELECT INTO recordCliente  codcli,nomcli,nit FROM cliente where nit=(SELECT COD_CLI FROM negocios where cod_neg=listaNegocioExtracto.negocio);
			INSERT INTO con.ingreso(dstrct,tipo_documento,num_ingreso,codcli,nitcli,
				     concepto,tipo_ingreso,fecha_consignacion,fecha_ingreso,branch_code,
				     bank_account_no,codmoneda,agencia_ingreso,descripcion_ingreso,vlr_ingreso,
				     vlr_ingreso_me,vlr_tasa,fecha_tasa,cant_item,creation_user,
				     creation_date,base,cuenta)

			VALUES('FINV','ICA',numeroIAcarteraFintraFiducia,recordCliente.codcli,recordCliente.nit,
			       'FE','C',now(),now(),'CAJA TESORERIA',
			        'BARRANQUILLA','PES','OP','AJUSTE FACTURAS CARTERA FINTRA/FIDUCIA POR REESTRUCTURACION',1,
			       1,'1.000000',substring(now(),1,10)::date,1,usuario,
			       now(),'COL','13050903');
                END IF;

		--GENERA EL DETALLE DEL DOCUMENTO DE INGRESO (NOTA AJUSTE CARTERA FINTRA Y FIDUCIA)
			INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
							valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
							documento,creation_user,creation_date,base,cuenta,descripcion,
							valor_tasa,saldo_factura)
			VALUES('FINV','ICA',numeroIAcarteraFintraFiducia,itemsFintraFiducia,recordCliente.nit,
				recordFacturas.valor_saldo,recordFacturas.valor_saldo,recordFacturas.documento,recordFacturas.fecha_factura,'FAC',
				recordFacturas.documento,usuario,now(),'COL',recordFacturas.cuenta,
				recordFacturas.descripcion,'1.0000000000',recordFacturas.valor_saldo);

                --ACTUALIZAR SALDOS POR FACTURA.
                 UPDATE con.factura SET valor_abono = valor_factura, valor_saldo = 0 , valor_abonome = valor_factura, valor_saldome = 0, user_update=usuario, last_update=now() WHERE documento = recordFacturas.documento;

        END IF;

    END LOOP;

    /****************************************************
    ********ACTUALIZAMOS LA CABECERA DEL LOS INGRESOS***/

        SELECT INTO valorIndemnizado coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso =numeroIAcarteraIndemnizada;
	SELECT INTO valorFintraFiducia coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso =numeroIAcarteraFintraFiducia;

	IF(numeroIAcarteraIndemnizada !='' AND valorIndemnizado > 0 )THEN

          UPDATE con.ingreso
		SET vlr_ingreso =valorIndemnizado,
		vlr_ingreso_me = valorIndemnizado,
		cant_item= itemsIndemnizada
	  WHERE num_ingreso = numeroIAcarteraIndemnizada;

        END IF;


	IF(numeroIAcarteraFintraFiducia !='' AND valorFintraFiducia > 0 )THEN

	  UPDATE con.ingreso
		SET vlr_ingreso =valorFintraFiducia,
		vlr_ingreso_me = valorFintraFiducia,
		cant_item= itemsFintraFiducia
	  WHERE num_ingreso = numeroIAcarteraFintraFiducia;

        END IF;


     /*******************************************************************************
     ********CREAR COMPROBANTE DIARIO PARA CRUZAR LA IA CON LAS CUENTAS TEMPORALES***/
        --buscamos los valores del comprobante...

	IF(validarCrearComprobante)THEN
		SELECT INTO numeroComprobante get_lcod('CDIAR');
		RAISE NOTICE 'NUMERO COMPROBANTE: %',numeroComprobante;
		SELECT INTO grupoTransaccion nextval('con.comprobante_grupo_transaccion_seq');
		totalDebito:=valorIndemnizado + valorFintraFiducia;

		INSERT INTO con.comprobante(
		    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
		    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
		    total_items, moneda, fecha_aplicacion, aprobador, last_update,
		    user_update, creation_date, creation_user, base, usuario_aplicacion,
		    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
		VALUES ('', 'FINV', 'CDIAR', numeroComprobante, grupoTransaccion, 'OP',
			replace(substring(now(),1,7),'-',''), NOW()::date, 'COMPROBANTE DIARIO REESTRUCTURACION FENALCO',recordCliente.nit, totalDebito, totalDebito,
			1, 'PES', NOW(),'', '0099-01-01',
			'',  NOW(), usuario, '', usuario,
			'GRAL', '', 0, '', '');

		/******************************************
		*****CREAMOS EL DETELLE DEL COMPROBANTE***/
		--items 1
		SELECT INTO transaccionDetalle nextval('con.comprodet_transaccion_seq');
		INSERT INTO con.comprodet(
		    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
		    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
		    tercero, documento_interno, last_update, user_update, creation_date,
		    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
		    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
		    tipo_referencia_3, referencia_3)
		VALUES ('', 'FINV', 'CDIAR',numeroComprobante,grupoTransaccion,transaccionDetalle,
		    replace(substring(now(),1,7),'-',''), '13050910', '', 'DETALLE CARTERA', totalDebito, 0,
		    recordCliente.nit, 'CD', '0099-01-01', '', NOW(),
		    usuario, '', '', '', '',0,
		    '', '', '', '',
		    '', '');


		--items 2
		IF(numeroIAcarteraIndemnizada !='' AND valorIndemnizado > 0 )THEN--orden cuenta 23

			SELECT INTO transaccionDetalle nextval('con.comprodet_transaccion_seq');
			INSERT INTO con.comprodet(
			    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
			    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
			    tercero, documento_interno, last_update, user_update, creation_date,
			    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
			    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
			    tipo_referencia_3, referencia_3)
			VALUES ('', 'FINV', 'CDIAR',numeroComprobante,grupoTransaccion,transaccionDetalle,
			    replace(substring(now(),1,7),'-',''), '23802003', '', 'AJUSTE FACTURAS INDEMNIZADAS POR REESTRUCTURACION', 0, valorIndemnizado,
			    recordCliente.nit, 'CD', '0099-01-01', '', NOW(),
			    usuario, '', '', '', '',0,
			    '', '', '', '',
			    '', '');

			itemComprobante:=itemComprobante+1;

		END IF;

		--items 3
		IF(numeroIAcarteraFintraFiducia !='' AND valorFintraFiducia > 0 )THEN---fintra y fiducia

			SELECT INTO transaccionDetalle nextval('con.comprodet_transaccion_seq');
			INSERT INTO con.comprodet(
			    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
			    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
			    tercero, documento_interno, last_update, user_update, creation_date,
			    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
			    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
			    tipo_referencia_3, referencia_3)
			VALUES ('', 'FINV', 'CDIAR',numeroComprobante,grupoTransaccion,transaccionDetalle,
			    replace(substring(now(),1,7),'-',''), '13050903', '', 'AJUSTE FACTURAS CARTERA FINTRA/FIDUCIA POR REESTRUCTURACION', 0, valorFintraFiducia,
			    recordCliente.nit, 'CD', '0099-01-01', '', NOW(),
			    usuario, '', '', '','',0,
			    '', '', '', '',
			    '', '');

			itemComprobante:=itemComprobante+1;
		END IF;

		 RAISE NOTICE 'ACTUALIZAMOS EL COMPROBANTE % ',numeroComprobante;
		--actualizamos los items del comprobante
		UPDATE con.comprobante SET total_items=itemComprobante WHERE numdoc=numeroComprobante;
	END IF;

END LOOP;

	/********************************************************
	********EJECUTAMOS LA CREACION DEL NUEVO NEGOCIO********/
        IF(validarCreacionNegocio)THEN
		SELECT INTO crearNegocio eg_generar_negocio_reestructuracion_fenalco(idRop,usuario);
        END IF;

        return crearNegocio;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_reestructurarfenalco(integer, character varying)
  OWNER TO postgres;
