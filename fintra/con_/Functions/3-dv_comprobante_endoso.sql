-- Function: con.dv_comprobante_endoso(character varying)

-- DROP FUNCTION con.dv_comprobante_endoso(character varying);

CREATE OR REPLACE FUNCTION con.dv_comprobante_endoso(usuario character varying)
  RETURNS text AS
$BODY$

DECLARE

retorno text:='FALSE';

RsFacturas record;
recordCuentas record;

numeroComprobante text;

CtaCmc varchar := '';
_tercero varchar := '';
_endosadoa varchar := '';

_grupo_transaccion numeric:=0;
_transaccion numeric:=0;

BEGIN

	--CREAMOS LA CABECERA DEL COPROBANTE DIARIO.
	numeroComprobante := con.serie_comprobante_cen();
	raise notice 'numeroComprobante: %', numeroComprobante;
	_grupo_transaccion = 0;

	SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

	INSERT INTO con.comprobante(
		    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
		    periodo, fechadoc, detalle, total_debito, total_credito,
		    total_items, moneda, fecha_aplicacion, aprobador, last_update,
		    user_update, creation_date, creation_user, base, usuario_aplicacion,
		    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
	    VALUES ('', 'FINV','CDIAR', numeroComprobante, _grupo_transaccion, 'OP',
		    replace(substring(now(),1,7),'-',''),now()::date,'COMPROBANTE DIARIO DE ENDOSO ', 0, 0,
		    0, 'PES', NOW()::DATE, usuario, '0099-01-01 00:00:00'::TIMESTAMP,
		    '', NOW(), usuario, 'COL', usuario,
		    'GRAL', '', 0.00, '', ''); --FALTA EL NIT LOS ITEMS Y VALOR DEBITO Y CREDITO

	--AGRUPAMOS LOS COMPROBANTES PENDIENTES POR REALIZAR POR LINEA NEGOCIO Y TIPO CARTERA(ESTE LOOP EN TEORIA ES DE UNA ITERACION)
	FOR RsFacturas IN

		SELECT * --linea_negocio, negocio, documento, cuota, endosar_en, valor_saldo_trasladado as valor_debito
		FROM  administrativo.control_endosofiducia
		WHERE reg_status=''
			AND estado_proceso=''
			AND num_comprobante=''
			AND fecha_cdiar='0099-01-01 00:00:00'::timestamp
		--GROUP BY linea_negocio, negocio, documento, cuota, endosar_en, valor_saldo_trasladado
		ORDER BY negocio, documento, cuota

	LOOP
		_tercero = RsFacturas.nit_cliente;
		if ( RsFacturas.endosar_en = '' ) then _endosadoa = '8020220161'; else _endosadoa = RsFacturas.endosar_en; end if;

		--BUSCAMOS LAS CUENTAS DEL DEBITO DEL COMPROBANTE (FENALCO ATLANTICO O BOLIVAR)
		select INTO recordCuentas * from administrativo.proceso_endoso where reg_status='' and custodiada_por = _endosadoa; --RsFacturas.endosar_en;

		raise notice 'RsFacturas.id_unidad_negocio: %', RsFacturas.id_unidad_negocio;
		if (RsFacturas.id_unidad_negocio = 2) then recordCuentas.cuenta_cabecera_cdiar = '13050902'; end if;

		if (RsFacturas.id_unidad_negocio = 8) then recordCuentas.cuenta_cabecera_cdiar = '13050521'; end if;

		--CREAMOS EL DEBITO DEL COMPROBANTE DIARIO.
		_transaccion = 0;
		SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');
		raise notice 'custodiada_por: %', recordCuentas.custodiada_por;

		INSERT INTO con.comprodet(
				    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
				    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
				    tercero, documento_interno, last_update, user_update, creation_date,
				    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3)
			    VALUES ('', 'FINV','CDIAR', numeroComprobante, _grupo_transaccion, _transaccion,
				    replace(substring(now(),1,7),'-',''), recordCuentas.cuenta_cabecera_cdiar, _tercero, 'CONTABILIZACION DEBITO CDIAR ENDOSO', RsFacturas.valor_saldo_trasladado, 0.00,
				    '8020220161', 'CDIAR', '0099-01-01 00:00:00'::TIMESTAMP, Usuario, now(),
				    Usuario, 'COL', 'FAC', RsFacturas.documento, '', 0.00,
				    'NEG', RsFacturas.negocio, '', '',
				    '', '' );

		--CREAMOS EL CREDITO DEL COMPROBANTE...
		_transaccion = 0;

		select into CtaCmc (select cuenta from con.cmc_doc where cmc = f.cmc and tipodoc = 'FAC') as cuenta_credito
		from con.factura f
		where documento = RsFacturas.documento;

		SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');
		INSERT INTO con.comprodet(
			    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
			    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
			    tercero, documento_interno, last_update, user_update, creation_date,
			    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
			    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
			    tipo_referencia_3, referencia_3)
		    VALUES ('', 'FINV','CDIAR', numeroComprobante, _grupo_transaccion, _transaccion,
			    replace(substring(now(),1,7),'-',''), CtaCmc, _tercero, 'ENDOSO '||RsFacturas.nombre_cliente,0.00,RsFacturas.valor_saldo_trasladado,
			    '8020220161', 'CDIAR', '0099-01-01 00:00:00'::TIMESTAMP, Usuario, now(),
			    Usuario, 'COL', 'FAC', RsFacturas.documento, '', 0.00,
			    'NEG', RsFacturas.negocio, '', '',
			    '', '');

		--MARCAMOS LAS FACTURAS COMO INDEMNIZADAS...

		if (RsFacturas.id_unidad_negocio = 2) then recordCuentas.cmc_to_facturas = 'FA'; end if;

		if (RsFacturas.id_unidad_negocio = 8) then recordCuentas.cmc_to_facturas = 'NB'; end if;

		UPDATE con.factura set corficolombiana='S', cmc = recordCuentas.cmc_to_facturas WHERE documento=RsFacturas.documento and tipo_documento IN ('FAC','ND');

	END LOOP;

	--ACTUALIZAMOS LA CABECERA DEL COMPROBANTE....
	UPDATE con.comprobante SET
		tercero = _endosadoa,
		total_debito = (SELECT sum(valor_debito) FROM con.comprodet WHERE numdoc=numeroComprobante AND reg_status='' ),
		total_credito = (SELECT sum(valor_credito) FROM con.comprodet WHERE numdoc=numeroComprobante AND reg_status='' ),
		total_items = (SELECT count(0) FROM con.comprodet WHERE numdoc=numeroComprobante AND reg_status='' )
	WHERE numdoc=numeroComprobante AND reg_status='' ;

	--VALIDAMOS QUE EL COMPROBANTE ESTE CUADRADO...
	IF ( NOT exists( SELECT * FROM con.comprobante c where c.numdoc = numeroComprobante and tipodoc = 'CDIAR' and total_debito =(SELECT sum(valor_debito) FROM con.comprodet WHERE numdoc=c.numdoc AND reg_status='') AND total_credito = (SELECT sum(valor_credito) FROM con.comprodet WHERE numdoc=c.numdoc AND reg_status='') ) ) THEN

		DELETE FROM con.comprobante  where numdoc= numeroComprobante and tipodoc = 'CDIAR';
		DELETE FROM con.comprodet  where numdoc= numeroComprobante and tipodoc = 'CDIAR';
		retorno:='LO SENTIMOS EL COMPROBANTE '||numeroComprobante||'  FUE ELIMINADO POR VALORES DEBITO Y CREDITO ERRADOS.';

	ELSE

		--MARCAMOS LAS FACTURAS COMO PROCESADAS
		UPDATE administrativo.control_endosofiducia
			SET estado_proceso='P', num_comprobante=numeroComprobante, fecha_cdiar=now(), user_update=usuario, last_update=now()
		WHERE estado_proceso=''
			AND fecha_cdiar='0099-01-01 00:00:00'::timestamp
			AND reg_status=''
			AND linea_negocio=RsFacturas.linea_negocio
			AND endosar_en=RsFacturas.endosar_en;

		retorno:='TRUE';

	END IF;

	RETURN retorno;

EXCEPTION

	WHEN foreign_key_violation THEN RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
	WHEN  null_value_not_allowed THEN RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.dv_comprobante_endoso(character varying)
  OWNER TO postgres;
