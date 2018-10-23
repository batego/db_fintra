-- Function: mc_legalizacion_caja_menor(character varying, numeric, numeric, character varying)

-- DROP FUNCTION mc_legalizacion_caja_menor(character varying, numeric, numeric, character varying);

CREATE OR REPLACE FUNCTION mc_legalizacion_caja_menor(cod_anticipo_ character varying, valor_legalizar_ numeric, valor_cxc_ numeric, usuario_ character varying)
  RETURNS boolean AS
$BODY$

DECLARE 

respuesta boolean :=false;

codigoCliente VARCHAR;
numero_documentoCXP VARCHAR;
numero_documentoNA VARCHAR;
numero_documentoNC VARCHAR;
tipoDocLegalizar VARCHAR;

diferencia NUMERIC; 
valor_saldo_factura NUMERIC;
valor_abono_factura NUMERIC;

anticipoxlegalizar RECORD;
infoCuentaHcCXC RECORD;
infoCuentaHcCXP RECORD;
infoCuentaHcICA RECORD;
infoCuentaHcNC RECORD;
infoFacturarel RECORD;
infoFacturarelDET RECORD;


  BEGIN

	--BUSCAMOS LOS ANTICIPOS QUE ESTAN SIN LEGALIZAR
	FOR anticipoxlegalizar IN  
		SELECT 
			cod_anticipo::varchar,
			empleado::varchar,
			concepto::varchar,
			banco::varchar,
			sucursal::varchar,
			valor_anticipo::numeric,
			num_factura::varchar,
			num_cxp::varchar,
			tipo_num_doc_leg::varchar,
			num_doc_legalizado::varchar,
			tipo_anticipo::varchar,
			cxp_gasto::varchar
		FROM anticipos_caja_menor 
		WHERE reg_status =''
		AND cod_anticipo = cod_anticipo_
		AND legalizado ='N' 

	LOOP

		raise notice 'anticipoxlegalizar: %',anticipoxlegalizar;

		
		---OBTENERMOS LA CUENTA Y EL HC PARA CXP 
		SELECT into infoCuentaHcCXP 
			cuenta,
			hc 
		FROM cuentas_anticipos_caja_menor
		WHERE reg_status ='' 
		AND tipo_documento = 'FAP'
		AND concepto = anticipoxlegalizar.tipo_anticipo
		AND legalizar = 'S';

		---OBTENERMOS LA CUENTA Y EL HC PARA IA 
		SELECT into infoCuentaHcICA 
			cuenta,
			hc 
		FROM cuentas_anticipos_caja_menor
		WHERE reg_status ='' 
		AND tipo_documento = 'ICA'
		AND concepto = anticipoxlegalizar.tipo_anticipo
		AND legalizar = 'S';

		---OBTENERMOS LA CUENTA Y EL HC PARA NC 
		SELECT into infoCuentaHcNC
			cuenta,
			hc 
		FROM cuentas_anticipos_caja_menor
		WHERE reg_status ='' 
		AND tipo_documento = 'NC'
		AND concepto = anticipoxlegalizar.tipo_anticipo
		AND legalizar = 'S';
		
		codigoCliente:= get_codnit(anticipoxlegalizar.empleado);
		raise notice 'codigoCliente: %',codigoCliente;
		
		diferencia:= valor_cxc_ - valor_legalizar_ ;
		raise notice 'diferencia: %',diferencia;
		
		SELECT INTO infoFacturarel * FROM con.factura where documento = anticipoxlegalizar.num_factura and tipo_documento = 'FAC' and dstrct = 'FINV'; 
		SELECT INTO infoFacturarelDET * FROM con.factura_detalle where documento = anticipoxlegalizar.num_factura and tipo_documento = 'FAC' and dstrct = 'FINV'; 
		raise notice 'infoFacturarel: %',infoFacturarel; 

		--GENERAMOS EL NUMERO DE NOTA DE AJUSTE
		select into numero_documentoNA get_lcod('ICAC');


		--CREAMOS LA NOTA CREDITO QUE CANCELARA LA CXP DE GASTOS
		numero_documentoNC :='NCG'||(get_lcod('NCG'));
		INSERT INTO fin.cxp_doc(
			reg_status,dstrct, proveedor, tipo_documento, documento, descripcion,agencia,
			handle_code, aprobador, moneda,
			vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me, vlr_saldo_me,
			creation_date, creation_user, base, moneda_banco,fecha_documento, fecha_vencimiento,
			tipo_documento_rel, documento_relacionado,tipo_referencia_2,referencia_2, banco,sucursal,
			tipo_referencia_3,referencia_3)
		VALUES (
			'','FINV', anticipoxlegalizar.empleado, 'NC', numero_documentoNC, 'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo ||' GASTO NUMERO: '||anticipoxlegalizar.cxp_gasto, 'OP', 
			infoCuentaHcNC.hc, 'ADMIN', 'PES', 
			valor_legalizar_, valor_legalizar_, 0, valor_legalizar_, valor_legalizar_, 0,
			now(), usuario_, 'COL','PES', NOW(),NOW(),
			'FAP', anticipoxlegalizar.cxp_gasto, 'FAP', anticipoxlegalizar.cxp_gasto,'BANCOLOMBIA','CPAG',
			'FAC',anticipoxlegalizar.num_factura);

		INSERT INTO fin.cxp_items_doc(
			reg_status,dstrct, proveedor, tipo_documento, documento, item, 
			descripcion, vlr, vlr_me, codigo_cuenta,
			creation_date, creation_user, base, 
			tipo_referencia_2, referencia_2,tipo_referencia_3,referencia_3)
		VALUES (
			'','FINV', anticipoxlegalizar.empleado, 'NC', numero_documentoNC, '001',  
			'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo||' GASTO NUMERO: '||anticipoxlegalizar.cxp_gasto, valor_legalizar_, valor_legalizar_, infoCuentaHcNC.cuenta, 
			now(), usuario_, 'COL',
			'FAP', anticipoxlegalizar.cxp_gasto,'FAC',anticipoxlegalizar.num_factura);

		--ACTUALIZAMOS EL GASTO
		update fin.cxp_doc set 
			vlr_total_abonos = valor_legalizar_,
			vlr_saldo = vlr_neto-valor_legalizar_,
			vlr_total_abonos_me = valor_legalizar_,
			vlr_saldo_me = vlr_neto-valor_legalizar_,
			last_update = now(),user_update = usuario_
		where documento  = anticipoxlegalizar.cxp_gasto and tipo_documento = 'FAP';

		update anticipos_caja_menor set 
			nc_gasto = numero_documentoNC,
			last_update = now(),user_update = usuario_
		where cod_anticipo = cod_anticipo_;

		
		
		IF (diferencia < 0)THEN 
			
			tipoDocLegalizar := 'FAP';
			diferencia := diferencia * -1;
			
			valor_saldo_factura := infoFacturarel.valor_saldo -  anticipoxlegalizar.valor_anticipo;
			valor_abono_factura := infoFacturarel.valor_abono + anticipoxlegalizar.valor_anticipo;
			--GENERAMOS EL NUMERO DE CXP  
			numero_documentoCXP :='PCM'||(get_lcod('PCM'));
			raise notice 'numero_documentoCXP: %',numero_documentoCXP;

			--CREAMOS LA NOTA DE AJUSTE
			INSERT INTO con.ingreso(
				dstrct, tipo_documento, num_ingreso, codcli, nitcli, 
				concepto, tipo_ingreso, fecha_consignacion, fecha_ingreso, branch_code, 
				bank_account_no, codmoneda, agencia_ingreso, descripcion_ingreso, 
				vlr_ingreso, vlr_ingreso_me, vlr_tasa, fecha_tasa, cant_item, 
				creation_user, creation_date,base,cuenta, cmc)
			VALUES (
				'FINV', 'ICA', numero_documentoNA, codigoCliente, anticipoxlegalizar.empleado,
				'FE', 'C', NOW(), NOW()::DATE, anticipoxlegalizar.banco,
				anticipoxlegalizar.sucursal,'PES', 'OP', 'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo,
				anticipoxlegalizar.valor_anticipo,anticipoxlegalizar.valor_anticipo, 1, NOW()::DATE, 1,
				usuario_, NOW(),'COL', infoCuentaHcICA.cuenta, infoCuentaHcICA.hc);

			INSERT INTO con.ingreso_detalle(
				dstrct, tipo_documento, num_ingreso, item, nitcli, 
				valor_ingreso, valor_ingreso_me, fecha_factura,  creation_user, 
				creation_date,  base, cuenta, 
				descripcion, valor_tasa, saldo_factura,tipo_doc,documento,factura)
			VALUES (
				'FINV', 'ICA', numero_documentoNA, 1, anticipoxlegalizar.empleado,
				anticipoxlegalizar.valor_anticipo,anticipoxlegalizar.valor_anticipo, now()::date, usuario_,
				NOW(),'COL', infoCuentaHcICA.cuenta ,
				'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo,1,anticipoxlegalizar.valor_anticipo,'FAC',anticipoxlegalizar.num_factura,anticipoxlegalizar.num_factura);

			--ACTUALIZAMOS LA FACTURA AFECTADA
			update con.factura set 
				valor_saldo = valor_saldo_factura,
				valor_saldome = valor_saldo_factura,
				valor_abono = valor_abono_factura,
				valor_abonome = valor_abono_factura,
				last_update = now(),user_update = usuario_
			where documento  = anticipoxlegalizar.num_factura and tipo_documento = 'FAC';
			
			--CREAMOS LA CABECERA DE LA CXP
			INSERT INTO fin.cxp_doc(
				reg_status,dstrct, proveedor, tipo_documento, documento, descripcion,agencia,
				handle_code, aprobador, moneda,
				vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me, vlr_saldo_me,
				creation_date, creation_user, base, moneda_banco,fecha_documento, fecha_vencimiento,
				tipo_documento_rel, documento_relacionado,tipo_referencia_2,referencia_2, banco,sucursal,
				tipo_referencia_3,referencia_3)
			VALUES (
				'','FINV', anticipoxlegalizar.empleado, tipoDocLegalizar, numero_documentoCXP, 'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo, 'OP', 
				infoCuentaHcCXP.hc, 'JGOMEZ', 'PES', 
				diferencia, 0, diferencia, diferencia, 0, diferencia,
				now(), usuario_, 'COL','PES', NOW(),NOW(),
				'LCM', anticipoxlegalizar.cod_anticipo, 'LCM', anticipoxlegalizar.cod_anticipo,anticipoxlegalizar.banco,anticipoxlegalizar.sucursal,
				'FAC',anticipoxlegalizar.num_factura);

			--CREAMOS EL DETALLE DE LA CXP
			INSERT INTO fin.cxp_items_doc(
				reg_status,dstrct, proveedor, tipo_documento, documento, item, 
				descripcion, vlr, vlr_me, codigo_cuenta,
				creation_date, creation_user, base, 
				tipo_referencia_2, referencia_2,tipo_referencia_3,referencia_3)
			VALUES (
				'','FINV', anticipoxlegalizar.empleado, tipoDocLegalizar, numero_documentoCXP, '001',  
				'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo, diferencia, diferencia, infoCuentaHcCXP.cuenta, 
				now(), usuario_, 'COL',
				'LCM', anticipoxlegalizar.cod_anticipo,'FAC',anticipoxlegalizar.num_factura);

			--ACTUALIZAMOS EL ANTICIPO COLOCANDO EL NUMERO DE CXP GANERADO Y CAMBIANDO EL ESTADO 
			UPDATE anticipos_caja_menor SET
				valor_legalizado = valor_legalizar_, num_doc_legalizado = numero_documentoCXP, 
				tipo_num_doc_leg = tipoDocLegalizar,last_update=now(), user_update=usuario_,
				legalizado ='S', nota_ajuste = numero_documentoNA
			WHERE cod_anticipo = cod_anticipo_;

		ELSIF (diferencia > 0 )THEN 
		
			valor_saldo_factura := infoFacturarel.valor_saldo -  valor_legalizar_;
			valor_abono_factura := infoFacturarel.valor_abono + valor_legalizar_;
			--CREAMOS LA NOTA DE AJUSTE
			INSERT INTO con.ingreso(
				dstrct, tipo_documento, num_ingreso, codcli, nitcli, 
				concepto, tipo_ingreso, fecha_consignacion, fecha_ingreso, branch_code, 
				bank_account_no, codmoneda, agencia_ingreso, descripcion_ingreso, 
				vlr_ingreso, vlr_ingreso_me, vlr_tasa, fecha_tasa, cant_item, 
				creation_user, creation_date,base,cuenta, cmc)
			VALUES (
				'FINV', 'ICA', numero_documentoNA, codigoCliente, anticipoxlegalizar.empleado,
				'FE', 'C', NOW(), NOW()::DATE, anticipoxlegalizar.banco,
				anticipoxlegalizar.sucursal,'PES', 'OP', 'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo,
				diferencia, diferencia, 1, NOW()::DATE, 1,
				usuario_, NOW(),'COL', infoCuentaHcICA.cuenta, infoCuentaHcICA.hc);

			INSERT INTO con.ingreso_detalle(
				dstrct, tipo_documento, num_ingreso, item, nitcli, 
				valor_ingreso, valor_ingreso_me, fecha_factura,  creation_user, 
				creation_date,  base, cuenta, 
				descripcion, valor_tasa, saldo_factura,tipo_doc,documento,factura)
			VALUES (
				'FINV', 'ICA', numero_documentoNA, 1, anticipoxlegalizar.empleado,
				diferencia, diferencia, now()::date, usuario_,
				NOW(),'COL', infoCuentaHcICA.cuenta ,
				'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo,1,diferencia,'FAC',anticipoxlegalizar.num_factura,anticipoxlegalizar.num_factura);

			--ACTUALIZAMOS LA FACTURA AFECTADA
			update con.factura set 
				valor_saldo = valor_saldo_factura,
				valor_saldome = valor_saldo_factura,
				valor_abono = valor_abono_factura,
				valor_abonome = valor_abono_factura,
				last_update = now(),user_update = usuario_
			where documento  = anticipoxlegalizar.num_factura and tipo_documento = 'FAC';
			
			--ACTUALIZAMOS EL ANTICIPO COLOCANDO EL NUMERO DE CXC GANERADO
			UPDATE anticipos_caja_menor SET
				valor_legalizado = valor_legalizar_, nota_ajuste = numero_documentoNA, 
				last_update=now(), user_update=usuario_,
				legalizado ='S'
			WHERE cod_anticipo = cod_anticipo_;	
				
		ELSIF (diferencia =  0)THEN 
			valor_saldo_factura := infoFacturarel.valor_saldo -  valor_legalizar_;
			valor_abono_factura := infoFacturarel.valor_abono + valor_legalizar_;
			
			--CREAMOS LA NOTA DE AJUSTE
			INSERT INTO con.ingreso(
				dstrct, tipo_documento, num_ingreso, codcli, nitcli, 
				concepto, tipo_ingreso, fecha_consignacion, fecha_ingreso, branch_code, 
				bank_account_no, codmoneda, agencia_ingreso, descripcion_ingreso, 
				vlr_ingreso, vlr_ingreso_me, vlr_tasa, fecha_tasa, cant_item, 
				creation_user, creation_date,base,cuenta, cmc)
			VALUES (
				'FINV', 'ICA', numero_documentoNA, codigoCliente, anticipoxlegalizar.empleado,
				'FE', 'C', NOW(), NOW()::DATE, anticipoxlegalizar.banco,
				anticipoxlegalizar.sucursal,'PES', 'OP', 'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo,
				anticipoxlegalizar.valor_anticipo,anticipoxlegalizar.valor_anticipo, 1, NOW()::DATE, 1,
				usuario_, NOW(),'COL', infoCuentaHcICA.cuenta, infoCuentaHcICA.hc);

			INSERT INTO con.ingreso_detalle(
				dstrct, tipo_documento, num_ingreso, item, nitcli, 
				valor_ingreso, valor_ingreso_me, fecha_factura,  creation_user, 
				creation_date,  base, cuenta, 
				descripcion, valor_tasa, saldo_factura,tipo_doc,documento,factura)
			VALUES (
				'FINV', 'ICA', numero_documentoNA, 1, anticipoxlegalizar.empleado,
				anticipoxlegalizar.valor_anticipo,anticipoxlegalizar.valor_anticipo, now()::date, usuario_,
				NOW(),'COL', infoCuentaHcICA.cuenta ,
				'LEGALIZACION DEL ANTICPO: '||anticipoxlegalizar.cod_anticipo,1,anticipoxlegalizar.valor_anticipo,'FAC',anticipoxlegalizar.num_factura,anticipoxlegalizar.num_factura);

			--ACTUALIZAMOS LA FACTURA AFECTADA
			update con.factura set 
				valor_saldo = valor_saldo_factura,
				valor_saldome = valor_saldo_factura,
				valor_abono = valor_abono_factura,
				valor_abonome = valor_abono_factura,
				last_update = now(),user_update = usuario_
			where documento  = anticipoxlegalizar.num_factura and tipo_documento = 'FAC';
			
			--ACTUALIZAMOS EL ANTICIPO COLOCANDO EL NUMERO DE CXC GANERADO
			UPDATE anticipos_caja_menor SET
				valor_legalizado = valor_legalizar_, nota_ajuste = numero_documentoNA, 
				last_update=now(), user_update=usuario_,
				legalizado ='S'
			WHERE cod_anticipo = cod_anticipo_;
		
		END IF;
		raise notice 'diferencia: %',diferencia;
		raise notice 'tipoDocLegalizar: %',tipoDocLegalizar;

		respuesta:= true;

	END LOOP;
		
   	return respuesta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_legalizacion_caja_menor(character varying, numeric, numeric, character varying)
  OWNER TO postgres;

