-- Function: procesar_ias_ncs(text)

-- DROP FUNCTION procesar_ias_ncs(text);

CREATE OR REPLACE FUNCTION procesar_ias_ncs(_tipo text)
  RETURNS text AS
$BODY$DECLARE
	_regs			RECORD;
	_facts			RECORD;
	_val			TEXT;
	_errval			TEXT;
	_cuenta			TEXT;
	_cuenta_ajuste		TEXT;
	_banco			TEXT;
	_idx			NUMERIC;
	_idx2			NUMERIC;
	_cnits			NUMERIC;
	_contenidas		NUMERIC;
	_wallet			NUMERIC;
	_consulta		text;
	_tipo_documento 	text;
	_num_ingreso		text;
	_auxiliar		text;
	_auxiliar_ajuste	text;
	_valor_ingreso		NUMERIC;
	_conceptico		CHARACTER VARYING;--20100512
	_ceros 			CHARACTER VARYING;--20100512
BEGIN
	_val		:='';
	_errval		:='';
	_ceros		:='';

	IF _tipo='IAS' THEN
		_consulta:='SELECT oid,*  FROM ias_fenalco WHERE procesado=''NO'' ORDER BY oid';

	ELSE
		IF _tipo='NAS' THEN
			_consulta:='SELECT oid,*  FROM nas_fenalco WHERE procesado=''NO'' ORDER BY oid';
			_ceros:='0';
		END if;
	END if;

	----SELECT oid,*  FROM ias_fenalco WHERE procesado='NO' ORDER BY oid--

-------------------------------VALIDACIONES----------------------------------
	_idx:=0;
	FOR _regs IN EXECUTE (_consulta) LOOP
		_idx:=_idx+1;
		_errval:='';
----------------------validar que las cuentas existan------------------------
		SELECT INTO _cuenta_ajuste,_auxiliar_ajuste cuenta,auxiliar FROM con.cuentas WHERE cuenta=_regs.cta_ajuste;
		IF _cuenta_ajuste IS NULL AND _tipo='IAS' THEN--AND _tipo='IAS'
			_errval:=_errval||'	La cuenta de ajuste '||_regs.cta_ajuste||e' no existe\n';
		END IF;

		SELECT INTO _cuenta,_auxiliar cuenta,auxiliar FROM con.cuentas WHERE cuenta=_regs.cuenta;
		IF _cuenta IS NULL THEN
			_errval:=_errval||'	La cuenta '||_regs.cuenta||e' no existe\n';
		END IF;
-----------------------------------------------------------------------------

----------------------validar que exita el banco y la sucursal------------------------

		SELECT INTO _banco branch_code FROM banco WHERE branch_code=_regs.banco AND bank_account_no=_regs.sucursal;
		IF (_tipo='IAS' AND (_regs.banco!='' OR _regs.sucursal!='')) THEN --20100630
			IF _banco IS NULL AND _tipo='IAS'  THEN
				_errval:=_errval||'	El banco '||_regs.banco||' o la sucursal '||_regs.sucursal||e' no existen\n';
			END IF;
	        END IF;--20100630
-----------------------------------------------------------------------------


----------------------validar nits facturas----------------------------------
		SELECT INTO _consulta 'SELECT count(*) FROM con.factura WHERE UPPER(documento) IN ('||''''||REPLACE(UPPER(_regs.facturas),',',''',''')||''') and valor_saldo!=0';--ojo
			EXECUTE (_consulta) INTO _contenidas;
		SELECT INTO _consulta 'SELECT count(distinct nit) FROM con.factura WHERE UPPER(documento) IN ('||''''||REPLACE(UPPER(_regs.facturas),',',''',''')||''') and valor_saldo!=0';--ojo
			EXECUTE (_consulta) INTO _cnits;

		--SELECT count(*) FROM con.factura WHERE UPPER(documento) IN ('||''''||REPLACE(UPPER(_regs.facturas),',',''',''')||''') and valor_saldo>0
		--SELECT count(distinct nit) FROM con.factura WHERE UPPER(documento) IN ('||''''||REPLACE(UPPER(_regs.facturas),',',''',''')||''') and valor_saldo>0


		IF  _cnits>1 THEN
			_errval:=_errval||e'	No todas las facturas pertenecen al mismo tercero\n';
		END IF;
		if _contenidas<>array_upper(string_to_array(_regs.facturas,','),1) THEN
			_errval:=_errval||e'	Algunas facturas no existen en el sistema o no tienen saldo\n';
		END IF;

		IF (EXISTS(SELECT documento FROM con.factura WHERE documento IN (REPLACE(_regs.facturas,',',''',''')) AND valor_saldo<0) AND _regs.valor>0) THEN
			_errval:=_errval||e'	No es permitido el registro: ' || _regs.oid || e' por tener 1 abono positivo para 1 saldo negativo. \n';
		END IF;
-----------------------------------------------------------------------------
---------------------------- FIN VALIDACIONES--------------------------------

-------------------------------CREACION DE NOTAS----------------------------------
		IF _errval='' THEN
			SELECT INTO _consulta 'SELECT * FROM con.factura WHERE documento IN ('||''''||REPLACE(_regs.facturas,',',''',''')||''')';

			_tipo_documento:= CASE WHEN _tipo='IAS' THEN 'ICA' WHEN _tipo='NAS' THEN 'ICR' END;
			--_num_ingreso:=                                                             get_lcod(CASE WHEN _tipo='IAS' THEN 'ICAC' WHEN _tipo='NAS' THEN 'ICRC' END);
			SELECT INTO _num_ingreso (SUBSTR(cod,1,2) || _ceros || SUBSTR(cod,3,10)) FROM (SELECT get_lcod(CASE WHEN _tipo='IAS' THEN 'ICAC' WHEN _tipo='NAS' THEN 'ICRC' END) AS cod) t;

-------------------------------CREACION DE CABECERA----------------------------------
			SELECT INTO _conceptico table_code
			FROM tablagen WHERE table_type ='CONINGRESO' AND reg_Status!='A' AND descripcion=_regs.concepto;--20100512

			INSERT INTO con.ingreso(
				    reg_status, dstrct, tipo_documento, num_ingreso, codcli, nitcli,
				    concepto, tipo_ingreso, fecha_consignacion, fecha_ingreso, branch_code,
				    bank_account_no, codmoneda, agencia_ingreso, descripcion_ingreso,
				    periodo, vlr_ingreso, vlr_ingreso_me, vlr_tasa, fecha_tasa, cant_item,
				    transaccion, transaccion_anulacion, fecha_impresion, fecha_contabilizacion,
				    fecha_anulacion_contabilizacion, fecha_anulacion, creation_user,
				    creation_date, user_update, last_update, base, nro_consignacion,
				    periodo_anulacion, cuenta, auxiliar, abc, tasa_dol_bol, saldo_ingreso,
				    cmc, corficolombiana, fec_envio_fiducia)
			    SELECT  '', 'FINV',_tipo_documento, _num_ingreso, fc.codcli, fc.nit,
				    _conceptico, 'C', _regs.fecha_consignacion, NOW(), _regs.banco, --20100512
				    _regs.sucursal, 'PES', 'OP', _regs.descripcion,
				    '000000', _regs.valor, _regs.valor, 1.000000, NOW(), array_upper(string_to_array(_regs.facturas,','),1),
				    0, 0, '0099-01-01 00:00:00', '0099-01-01 00:00:00',
				    '0099-01-01 00:00:00', '0099-01-01 00:00:00', 'ADMIN',
				    NOW(), '', '0099-01-01 00:00:00', 'COL', '',--20100512
				    '', _regs.cuenta, case when _auxiliar='S' THEN 'RD-'||fc.nit ELSE '' END, '', 0.000000, 0.00,
				    '', '', '0099-01-01 00:00:00'
			    FROM    con.factura as fc
			    WHERE   UPPER(documento)=UPPER((string_to_array(_regs.facturas,','))[1]);
-------------------------------------------------------------------------------------------------------------------------

-------------------------------CREACION DE DETALLES----------------------------------
			_idx2:=1;
			_wallet:=_regs.valor;
			_val:=_val||'Se creo el ingreso '||_num_ingreso||e' y se cancelaron las siguientes facturas:\n';
			FOR _facts IN EXECUTE(_consulta) LOOP
				IF (_wallet!=0  /*AND NOT( _wallet>0 AND _facts.valor_saldo<0 )*/) THEN--ojo
					IF _wallet>=_facts.valor_saldo THEN--ojo		-100>=-200		-200>=-100	100>=-200
						_valor_ingreso= _facts.valor_saldo;	--	      -200				      100
					ELSE
						_valor_ingreso=_wallet;			--				      -100
					END IF;
					IF _wallet<0 THEN--OK				--	-100<0			      -200<0
						_valor_ingreso=_wallet;			--	      -100		      -200
					END IF;
					_wallet:=_wallet-_valor_ingreso;		--	-100=-100-(-100)=0
					_val:=_val||'	Se bajo el saldo de la factura '||_facts.documento||e' en '||to_char(_valor_ingreso,'999G999G999G999G999G999')||e' pesos\n';
					INSERT INTO con.ingreso_detalle(
						    reg_status, dstrct, tipo_documento, num_ingreso, item, nitcli,
						    valor_ingreso, valor_ingreso_me, factura, fecha_factura, codigo_retefuente,
						    valor_retefuente, valor_retefuente_me, tipo_doc, documento, codigo_reteica,
						    valor_reteica, valor_reteica_me, valor_diferencia_tasa, creation_user,
						    creation_date, user_update, last_update, base, cuenta, auxiliar,
						    fecha_contabilizacion, fecha_anulacion_contabilizacion, periodo,
						    fecha_anulacion, periodo_anulacion, transaccion, transaccion_anulacion,
						    descripcion, valor_tasa, saldo_factura, procesado)
					    SELECT  '', 'FINV', _tipo_documento, _num_ingreso, _idx2, _facts.nit,
						    _valor_ingreso, _valor_ingreso, _facts.documento, _facts.fecha_factura, '',
						    0.00, 0.00, _facts.tipo_documento, _facts.documento, '',
						    0.00, 0.00, 0.00, 'ADMIN',
						    NOW(), '', '0099-01-01 00:00:00', 'COL',
						    (SELECT cuenta
						     FROM con.cmc_doc
						     WHERE tipodoc=_facts.tipo_documento and cmc=_facts.cmc) ,
						     CASE WHEN (SELECT auxiliar
								FROM con.cmc_doc cmc
								   INNER JOIN con.cuentas ct ON(ct.cuenta=cmc.cuenta)
								WHERE tipodoc=_facts.tipo_documento and cmc=_facts.cmc)='S' THEN 'RD-'||_facts.nit ELSE '' END,
						    '0099-01-01 00:00:00', '0099-01-01 00:00:00', '', --20100512
						    '0099-01-01 00:00:00', '', 0, 0,
						    _facts.descripcion, 1.0000000000, _facts.valor_saldo, 'NO';

					UPDATE con.factura SET	valor_saldo=valor_saldo-_valor_ingreso,
								valor_saldome=valor_saldome-_valor_ingreso,
								valor_abono=valor_abono+_valor_ingreso,
								valor_abonome=valor_abonome+_valor_ingreso,
								last_update=NOW(),
								user_update='ADMIN',
								fecha_ultimo_pago=NOW()
					WHERE documento=_facts.documento;
					_idx2:=_idx2+1;

					IF _tipo='IAS' THEN
						_consulta:='UPDATE ias_fenalco SET PROCESADO = ''SI'' WHERE OID='''||_regs.oid||''';';

					ELSE
						IF _tipo='NAS' THEN
							_consulta:='UPDATE nas_fenalco SET PROCESADO = ''SI'' WHERE OID='''||_regs.oid||''';';
						END if;
					END if;
				--ELSE
						--_errval:=_errval||e'	No es permitido el registro: ' || _regs.oid || e' por tener abono 0 o por tener abono positivo para saldo negativo. \n';
				END IF;
				EXECUTE(_consulta);

			END LOOP;

			IF (_wallet>0 ) THEN--ojo
				_val:=_val||'	Se ajusto el saldo de la nota a la cuenta '||_regs.cta_ajuste||' en '||to_char(_wallet,'999G999G999G999G999G999')||e' pesos \n';
				INSERT INTO con.ingreso_detalle(
					    reg_status, dstrct, tipo_documento, num_ingreso, item, nitcli,
					    valor_ingreso, valor_ingreso_me, factura, fecha_factura, codigo_retefuente,
					    valor_retefuente, valor_retefuente_me, tipo_doc, documento, codigo_reteica,
					    valor_reteica, valor_reteica_me, valor_diferencia_tasa, creation_user,
					    creation_date, user_update, last_update, base, cuenta, auxiliar,
					    fecha_contabilizacion, fecha_anulacion_contabilizacion, periodo,
					    fecha_anulacion, periodo_anulacion, transaccion, transaccion_anulacion,
					    descripcion, valor_tasa, saldo_factura, procesado)
				    SELECT  '', 'FINV', _tipo_documento, _num_ingreso, _idx2, fc.nit,
					    _wallet, _wallet, '', CURRENT_DATE, '',
					    0.00, 0.00, '', '', '',
					    0.00, 0.00, 0.00, 'ADMIN',
					    NOW(), '', '0099-01-01 00:00:00', 'COL', _regs.cta_ajuste,
					     '',
					    '0099-01-01 00:00:00', '0099-01-01 00:00:00', '', --20100512
					    '0099-01-01 00:00:00', '', 0, 0,
					    'Ajuste saldo al ingreso Nro. ' || _num_ingreso, 1.0000000000, _wallet, 'NO'
				    FROM    con.factura as fc
				    WHERE   documento=(string_to_array(_regs.facturas,','))[1];
				    UPDATE con.ingreso SET cant_item=cant_item+1 WHERE num_ingreso=_num_ingreso;
			END IF;
---------------------------------------------------------------------------------------------------------

		END IF;
--------------------------------FIN CREACION NOTAS--------------------------------------------------------
		IF _errval<>'' THEN
			_val:=_val||'Errores en el registro '||_idx||e':\n'||_errval;
		ELSE
		END IF;
	END LOOP;
RETURN _val;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION procesar_ias_ncs(text)
  OWNER TO postgres;
