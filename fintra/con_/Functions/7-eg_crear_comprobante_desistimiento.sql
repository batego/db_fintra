-- Function: con.eg_crear_comprobante_desistimiento(character varying)

-- DROP FUNCTION con.eg_crear_comprobante_desistimiento(character varying);

CREATE OR REPLACE FUNCTION con.eg_crear_comprobante_desistimiento(usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

retorno text:='FALSE';
recordUnidad record;
recordCuentas record;
detalleDebito record;
numeroComprobante text;
_grupo_transaccion numeric:=0;
_transaccion numeric:=0;


BEGIN

	--AGRUPAMOS LOS COMPROBANTES PENDIENTES POR REALIZAR POR LINEA NEGOCIO Y TIPO CARTERA(ESTE LOOP EN TEORIA ES DE UNA ITERACION)

	for recordUnidad in 	SELECT linea_negocio, cartera_en ,SUM(valor_desistido) as valor_credito
				from  administrativo.detalle_desistimiento_factura
				where reg_status='' and estado_proceso='' and fecha_desistimiento='0099-01-01 00:00:00'::timestamp
				group by linea_negocio, cartera_en

	LOOP

		--BUSCAMOS LAS CUENTAS DEL CREDITO DEL COMPROBANTE (FENALCO ATLANTICO O BOLIVAR)
		select INTO recordCuentas codigo,nombre,cuenta,referencia_1  from administrativo.asociacion_cartera where codigo =recordUnidad.linea_negocio and reg_status='';

		--CREAMOS LA CABECERA DEL COPROBANTE DIARIO.

		numeroComprobante := con.serie_comprobante_cid();
		_grupo_transaccion = 0;
		SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

		INSERT INTO con.comprobante(
			    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
			    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
			    total_items, moneda, fecha_aplicacion, aprobador, last_update,
			    user_update, creation_date, creation_user, base, usuario_aplicacion,
			    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)

		    VALUES ('', 'FINV','CDIAR', numeroComprobante, _grupo_transaccion, 'OP',
			    replace(substring(now(),1,7),'-',''),now()::date,'COMPROBANTE DIARIO DESIMIENTO '||upper(recordCuentas.nombre),recordCuentas.referencia_1, 0, 0,
			    0, 'PES', NOW()::DATE, usuario, '0099-01-01 00:00:00'::TIMESTAMP,
			    '', NOW(), usuario, 'COL', usuario,
			    'GRAL', '', 0.00, '', ''); --FALTA EL NIT LOS ITEMS Y VALOR DEBITO Y CREDITO


		--CREAMOS EL CREDITO DEL COMPROBANTE DIARIO.

		_transaccion = 0;
		SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

		INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV','CDIAR', numeroComprobante, _grupo_transaccion, _transaccion,
				    replace(substring(now(),1,7),'-',''), recordCuentas.cuenta, recordCuentas.referencia_1, 'CONTABILIZACION DEBITO CDIAR DESISTIMIENTO',0.00, recordUnidad.valor_credito,
				    recordCuentas.referencia_1, 'CDIAR', '0099-01-01 00:00:00'::TIMESTAMP, Usuario, now(),
				    Usuario, 'COL', '', '', '', 0.00,
				    '', '', '', '',
				    '', '' );

		--CREAMOS EL DEBITO DEL COMPROBANTE...
		for detalleDebito in (SELECT fac.*, ctrl.nombre_cliente
				     from administrativo.detalle_desistimiento_factura fac
				     INNER JOIN administrativo.control_indemnizacion_fenalco ctrl on (ctrl.documento=fac.documento and ctrl.negocio=fac.negocio)
				     where  fac.reg_status='' and fac.estado_proceso='' and ctrl.estado_proceso='P'
				     and fac.fecha_desistimiento='0099-01-01 00:00:00'::timestamp
				     AND fac.linea_negocio=recordUnidad.linea_negocio
				     and fac.cartera_en=recordUnidad.cartera_en)

	        loop
			_transaccion = 0;
		        SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');
			INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV','CDIAR', numeroComprobante, _grupo_transaccion, _transaccion,
				    replace(substring(now(),1,7),'-',''), detalleDebito.cuenta_contable, '', 'DESISTIMIENTO '||detalleDebito.nombre_cliente,detalleDebito.valor_desistido,0.00,
				    '8020220161', 'CDIAR', '0099-01-01 00:00:00'::TIMESTAMP, Usuario, now(),
				    Usuario, 'COL', 'FAC', detalleDebito.documento, '', 0.00,
				    'NEG', detalleDebito.negocio, '', '',
				    '', '');


			--ACTUALIZAMOS LA TABLA DE CONTROL COMO DESITIDA LA FACTURA..
			update administrativo.control_indemnizacion_fenalco
			set fecha_desistimiento=now(),
			    valor_desistido=valor_desistido+detalleDebito.valor_desistido,
			    ultimo_comprobante_desistimiento=numeroComprobante,
			    numero_desistimientos=numero_desistimientos+1,
			    last_update=now(),
			    user_update=usuario
			where documento= detalleDebito.documento and estado_proceso='P'
			and linea_negocio=recordUnidad.linea_negocio
			and cartera_en=recordUnidad.cartera_en ;

	        end loop;


		--ACTUALIZAMOS LA CABECERA DEL COMPROBANTE....

		UPDATE con.comprobante set
			total_debito=(SELECT sum(valor_debito) FROM con.comprodet WHERE numdoc=numeroComprobante AND reg_status='' ),
			total_credito=(SELECT sum(valor_credito) FROM con.comprodet WHERE numdoc=numeroComprobante AND reg_status='' ),
			total_items=(SELECT count(0) FROM con.comprodet WHERE numdoc=numeroComprobante AND reg_status='' )
		where numdoc=numeroComprobante and reg_status='' ;

		--VALIDAMOS QUE EL COMPROBANTE ESTE CUADRADO....

		if( NOT exists( SELECT * FROM con.comprobante c where c.numdoc = numeroComprobante and tipodoc = 'CDIAR'
		        	and total_debito =(SELECT sum(valor_debito) FROM con.comprodet WHERE numdoc=c.numdoc AND reg_status='' )
			        AND total_credito=(SELECT sum(valor_credito) FROM con.comprodet WHERE numdoc=c.numdoc AND reg_status='' )
			 )
		) THEN

			DELETE FROM con.comprobante  where numdoc= numeroComprobante and tipodoc = 'CDIAR';
			DELETE FROM con.comprodet  where numdoc= numeroComprobante and tipodoc = 'CDIAR';
			retorno:='LO SENTIMOS EL COMPROBANTE '||numeroComprobante||'  FUE ELIMINADO POR VALORES DEBITO Y CREDITO ERRADOS.';

		else

			--MARCAMOS LAS FACTURAS COMO PROCESADAS
			UPDATE administrativo.detalle_desistimiento_factura
			SET  estado_proceso='P', num_comprobante=numeroComprobante, fecha_desistimiento=now(), user_update=usuario, last_update=now()
		        where estado_proceso='' and fecha_desistimiento='0099-01-01 00:00:00'::timestamp
			and reg_status=''
			AND linea_negocio=recordUnidad.linea_negocio
			and cartera_en=recordUnidad.cartera_en ;

			retorno:='TRUE';

		END IF;

	END loop ;


RETURN retorno;

EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
	WHEN  null_value_not_allowed  THEN
		RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.eg_crear_comprobante_desistimiento(character varying)
  OWNER TO postgres;
