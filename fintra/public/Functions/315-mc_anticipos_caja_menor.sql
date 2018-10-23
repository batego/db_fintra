-- Function: mc_anticipos_caja_menor(character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying)

-- DROP FUNCTION mc_anticipos_caja_menor(character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying);

CREATE OR REPLACE FUNCTION mc_anticipos_caja_menor(tipoanticpo_ character varying, empleado_ character varying, banco_ character varying, sucursal_ character varying, autorizador_ character varying, concepto_ character varying, valor_anticipo_ numeric, usuario_ character varying)
  RETURNS boolean AS
$BODY$

DECLARE 

respuesta boolean :=false;

numeroAnticipoCM VARCHAR;
codigoCliente VARCHAR;
numero_documentoCXP VARCHAR;
numero_documentoCXC VARCHAR;
documentoExistCxp VARCHAR;
documentoExistCxc VARCHAR;

countCxp NUMERIC;
countCxc NUMERIC;

anticipoxfacturar RECORD;
infoCuentaHcCXC RECORD;
infoCuentaHcCXP RECORD;


  BEGIN

	-- INSERTAMOS EL ANTICIPO DE LA SOLICITUD

		numeroAnticipoCM :='ACM'||(get_lcod('ACM')) ;
		raise notice 'numeroAnticipoCM: %',numeroAnticipoCM;

		INSERT INTO anticipos_caja_menor(
			empleado, cod_anticipo, concepto, banco, 
			sucursal, valor_anticipo, creation_user,tipo_anticipo)
		VALUES (
			empleado_, numeroAnticipoCM, concepto_, banco_,
			sucursal_, valor_anticipo_, usuario_,tipoAnticpo_ );

	--BUSCAMOS LOS ANTICIPOS QUE ESTAN SIN FACTURAR
	FOR anticipoxfacturar IN  
		SELECT 
			cod_anticipo::varchar,
			empleado::varchar,
			concepto::varchar,
			banco::varchar,
			sucursal::varchar,
			valor_anticipo::numeric,
			num_factura::varchar,
			num_cxp::varchar
		FROM anticipos_caja_menor 
		WHERE reg_status =''
		AND cod_anticipo = numeroAnticipoCM

	LOOP
		raise notice 'anticipoxfacturar: %',anticipoxfacturar;

		codigoCliente:=get_codnit(empleado_);
		raise notice 'codigoCliente: %',codigoCliente;
		
		--BUSCAMOS SI EXISTE CXP y CXC REALCIONADAS AL ANTICIPO
		PERFORM * from fin.cxp_doc where dstrct='FINV'AND reg_status='' and tipo_documento='FAP' AND tipo_referencia_2 ='ACM' and referencia_2 = anticipoxfacturar.cod_anticipo;
		IF (NOT found) THEN 
			PERFORM * from con.factura where  dstrct='FINV'AND reg_status='' and tipo_documento='FAC' AND tipo_referencia_2 ='ACM' and referencia_2 = anticipoxfacturar.cod_anticipo;
		        IF (NOT found) THEN 

				SELECT INTO infoCuentaHcCXP
						cuenta,
						hc 
					FROM cuentas_anticipos_caja_menor
					WHERE reg_status ='' 
					AND tipo_documento = 'FAP'
					AND concepto = tipoAnticpo_
					AND reg_status ='';

				SELECT INTO infoCuentaHcCXC
						cuenta,
						hc 
					FROM cuentas_anticipos_caja_menor
					WHERE reg_status ='' 
					AND tipo_documento = 'FAC'
					AND concepto = tipoAnticpo_
					AND reg_status ='';
				
				--GENERAMOS EL NUMERO DE CXP
				numero_documentoCXP:= 'PCM'||(get_lcod('PCM'));

				--GENERAMOS EL NUMERO DE CXC
				numero_documentoCXC:= 'FCM'||(get_lcod('FCM'));

				IF (tipoAnticpo_ = 'ANTICIPO GASTO VIAJE')THEN 

					--CREAMOS LA CABECERA DE LA CXP
					INSERT INTO fin.cxp_doc(
						reg_status,dstrct, proveedor, tipo_documento, documento, descripcion,agencia,
						handle_code, aprobador, moneda,
						vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me, vlr_saldo_me,
						creation_date, creation_user, base, moneda_banco,fecha_documento, fecha_vencimiento,
						tipo_documento_rel, documento_relacionado,tipo_referencia_2,referencia_2, banco,sucursal)
					VALUES (
						'','FINV', anticipoxfacturar.empleado, 'FAP', numero_documentoCXP, 'FACTURA A PAGAR DEL ANTICPO: '||anticipoxfacturar.cod_anticipo ||' '||concepto_, 'OP', 
						infoCuentaHcCXP.hc, autorizador_, 'PES', 
						anticipoxfacturar.valor_anticipo, 0, anticipoxfacturar.valor_anticipo, anticipoxfacturar.valor_anticipo, 0, anticipoxfacturar.valor_anticipo,
						now(), usuario_, 'COL','PES', NOW(),NOW(),
						'ACM', anticipoxfacturar.cod_anticipo, 'ACM', anticipoxfacturar.cod_anticipo,anticipoxfacturar.banco,anticipoxfacturar.sucursal);

					--CREAMOS EL DETALLE DE LA CXP
					INSERT INTO fin.cxp_items_doc(
						reg_status,dstrct, proveedor, tipo_documento, documento, item, 
						descripcion, vlr, vlr_me, codigo_cuenta,
						creation_date, creation_user, base, 
						tipo_referencia_2, referencia_2)
					VALUES (
						'','FINV', anticipoxfacturar.empleado, 'FAP', numero_documentoCXP, '001',  
						'FACTURA A PAGAR DEL ANTICPO: '||anticipoxfacturar.cod_anticipo ||' '||concepto_, anticipoxfacturar.valor_anticipo, anticipoxfacturar.valor_anticipo, infoCuentaHcCXP.cuenta, 
						now(), usuario_, 'COL',
						'ANP', anticipoxfacturar.cod_anticipo);

					--ACTUALIZAMOS EL ANTICIPO COLOCANDO EL NUMERO DE CXP GANERADO
					UPDATE anticipos_caja_menor SET
						num_cxp = numero_documentoCXP, last_update=now(), user_update=usuario_
					WHERE cod_anticipo = anticipoxfacturar.cod_anticipo;

					------------------------------
					
					--INSERTAMOS LA CABECERA DE LA CXC
					INSERT INTO con.factura(
						reg_status,dstrct,tipo_documento,documento,nit,codcli,
						fecha_factura,fecha_vencimiento,descripcion,valor_factura,valor_abono,
						valor_saldo,valor_facturame,valor_abonome,valor_saldome,moneda,cantidad_items,forma_pago,agencia_facturacion,base,
						creation_date,creation_user,cmc,tipo_referencia_2,referencia_2, tipo_ref1, ref1)
					VALUES (
						'','FINV','FAC',numero_documentoCXC,anticipoxfacturar.empleado,codigoCliente,
						NOW(),(now() +'7 days')::date,'FACTURA ANTICIPO - '||anticipoxfacturar.cod_anticipo ||' '||concepto_,anticipoxfacturar.valor_anticipo,0,
						anticipoxfacturar.valor_anticipo,anticipoxfacturar.valor_anticipo,0,anticipoxfacturar.valor_anticipo,'PES','001','CREDITO','OP','COL',
						now(),usuario_,infoCuentaHcCXC.hc,'ACM',anticipoxfacturar.cod_anticipo,'ACM',anticipoxfacturar.cod_anticipo);
					
					--INSERTAMOS EL DETALLE DE LA CXC
					INSERT INTO con.factura_detalle(
						reg_status,dstrct,tipo_documento,documento,item,nit,descripcion,
						codigo_cuenta_contable,cantidad,valor_unitario,valor_unitariome,valor_item,valor_itemme,
						moneda,base,tipo_referencia_2,referencia_2,creation_user,creation_date,tipo_documento_rel,documento_relacionado)
					VALUES 
						('','FINV','FAC',numero_documentoCXC,'001',anticipoxfacturar.empleado,'FACTURA ANTICIPO - '||anticipoxfacturar.cod_anticipo ||' '||concepto_,
						infoCuentaHcCXC.cuenta,'1',anticipoxfacturar.valor_anticipo,anticipoxfacturar.valor_anticipo,anticipoxfacturar.valor_anticipo,valor_anticipo_,
						'PES','COL','ACM',anticipoxfacturar.cod_anticipo,usuario_ ,now(),'ACM',anticipoxfacturar.cod_anticipo);

					--ACTUALIZAMOS EL ANTICIPO COLOCANDO EL NUMERO DE CXC GANERADO
					UPDATE anticipos_caja_menor SET
					num_factura = numero_documentoCXC, last_update=now(), user_update=usuario_
					WHERE cod_anticipo = anticipoxfacturar.cod_anticipo;		
					
					respuesta:= true;

				ELSIF (tipoAnticpo_ = 'ANTICIPO OTROS')THEN

					--CREAMOS LA CABECERA DE LA CXP
					INSERT INTO fin.cxp_doc(
						reg_status,dstrct, proveedor, tipo_documento, documento, descripcion,agencia,
						handle_code, aprobador, moneda,
						vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me, vlr_saldo_me,
						creation_date, creation_user, base, moneda_banco,fecha_documento, fecha_vencimiento,
						tipo_documento_rel, documento_relacionado,tipo_referencia_2,referencia_2, banco,sucursal)
					VALUES (
						'','FINV', anticipoxfacturar.empleado, 'FAP', numero_documentoCXP, 'FACTURA A PAGAR DEL ANTICPO: '||anticipoxfacturar.cod_anticipo, 'OP', 
						infoCuentaHcCXP.hc, autorizador_, 'PES', 
						anticipoxfacturar.valor_anticipo, 0, anticipoxfacturar.valor_anticipo, anticipoxfacturar.valor_anticipo, 0, anticipoxfacturar.valor_anticipo,
						now(), usuario_, 'COL','PES', NOW(),NOW(),
						'ACM', anticipoxfacturar.cod_anticipo, 'ACM', anticipoxfacturar.cod_anticipo,anticipoxfacturar.banco,anticipoxfacturar.sucursal);

					--CREAMOS EL DETALLE DE LA CXP
					INSERT INTO fin.cxp_items_doc(
						reg_status,dstrct, proveedor, tipo_documento, documento, item, 
						descripcion, vlr, vlr_me, codigo_cuenta,
						creation_date, creation_user, base, 
						tipo_referencia_2, referencia_2)
					VALUES (
						'','FINV', anticipoxfacturar.empleado, 'FAP', numero_documentoCXP, '001',  
						'FACTURA A PAGAR DEL ANTICPO: '||anticipoxfacturar.cod_anticipo, anticipoxfacturar.valor_anticipo, anticipoxfacturar.valor_anticipo, infoCuentaHcCXP.cuenta, 
						now(), usuario_, 'COL',
						'ANP', anticipoxfacturar.cod_anticipo);

					--ACTUALIZAMOS EL ANTICIPO COLOCANDO EL NUMERO DE CXP GANERADO
					UPDATE anticipos_caja_menor SET
						num_cxp = numero_documentoCXP, last_update=now(), user_update=usuario_
					WHERE cod_anticipo = anticipoxfacturar.cod_anticipo;

					-------------
					
					--INSERTAMOS LA CABECERA DE LA CXC
					INSERT INTO con.factura(
						reg_status,dstrct,tipo_documento,documento,nit,codcli,
						fecha_factura,fecha_vencimiento,descripcion,valor_factura,valor_abono,
						valor_saldo,valor_facturame,valor_abonome,valor_saldome,moneda,cantidad_items,forma_pago,agencia_facturacion,base,
						creation_date,creation_user,cmc,tipo_referencia_2,referencia_2, tipo_ref1, ref1)
					VALUES (
						'','FINV','FAC',numero_documentoCXC,anticipoxfacturar.empleado,codigoCliente,
						NOW(),(now() +'7 days')::date,'FACTURA ANTICIPO - '||anticipoxfacturar.cod_anticipo ||' '||concepto_,anticipoxfacturar.valor_anticipo,0,
						anticipoxfacturar.valor_anticipo,anticipoxfacturar.valor_anticipo,0,anticipoxfacturar.valor_anticipo,'PES','001','CREDITO','OP','COL',
						now(),usuario_,infoCuentaHcCXC.hc,'ACM',anticipoxfacturar.cod_anticipo,'ACM',anticipoxfacturar.cod_anticipo);
					
					--INSERTAMOS EL DETALLE DE LA CXC
					INSERT INTO con.factura_detalle(
						reg_status,dstrct,tipo_documento,documento,item,nit,descripcion,
						codigo_cuenta_contable,cantidad,valor_unitario,valor_unitariome,valor_item,valor_itemme,
						moneda,base,tipo_referencia_2,referencia_2,creation_user,creation_date,tipo_documento_rel,documento_relacionado)
					VALUES 
						('','FINV','FAC',numero_documentoCXC,'001',anticipoxfacturar.empleado,'FACTURA ANTICIPO - '||anticipoxfacturar.cod_anticipo ||' '||concepto_,
						infoCuentaHcCXC.cuenta,'1',anticipoxfacturar.valor_anticipo,anticipoxfacturar.valor_anticipo,anticipoxfacturar.valor_anticipo,valor_anticipo_,
						'PES','COL','ACM',anticipoxfacturar.cod_anticipo,usuario_ ,now(),'ACM',anticipoxfacturar.cod_anticipo);

					--ACTUALIZAMOS EL ANTICIPO COLOCANDO EL NUMERO DE CXC GANERADO
					UPDATE anticipos_caja_menor SET
					num_factura = numero_documentoCXC, last_update=now(), user_update=usuario_
					WHERE cod_anticipo = anticipoxfacturar.cod_anticipo;		
					
					respuesta:= true;
				
				END IF;
			ELSE 
			 RAISE NOTICE 'TIENE CXC';
			 respuesta:= false;
			END IF;
			
		ELSE
			RAISE NOTICE 'TIENE CXP';
			respuesta:= false;
		END IF;
	END LOOP;
		
   	return respuesta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_anticipos_caja_menor(character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying)
  OWNER TO postgres;

