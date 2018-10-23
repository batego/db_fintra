-- Function: fin.fn_transf_nomina(text[], text[])

-- DROP FUNCTION fin.fn_transf_nomina(text[], text[]);

CREATE OR REPLACE FUNCTION fin.fn_transf_nomina(facturas text[], config text[])
  RETURNS SETOF record AS
$BODY$
 DECLARE

  _msgproceso VARCHAR;

  _serie INTEGER;
  _tasa INTEGER;

  _cheque RECORD;
  _retorno RECORD;

  _transferencia VARCHAR;
  _dstrct VARCHAR;
  _usuario VARCHAR;
  _banco VARCHAR;
  _sucursal VARCHAR;

 BEGIN
  _usuario = config[1];
  _dstrct = config[2];
  _banco = config[3];
  _sucursal = config[4];
  _tasa = 1;

  SELECT INTO _serie MAX(corrida) +1 FROM fin.corridas WHERE dstrct = _dstrct;

  SELECT INTO _transferencia to_char(current_timestamp, 'YYYYMMDDHH24MISS');

  raise notice '% : % : % : % : % : % : %', _usuario, _dstrct, _banco, _sucursal, _tasa, _serie, _transferencia;

  -------GENERANDO INFORMACION DE LA CORRIDA------------
  DELETE FROM fin.info_corridas WHERE dstrct = _dstrct AND corrida = _serie;
  INSERT INTO  fin.info_corridas (dstrct,corrida,creation_user,tpago,bancos,fproveedor,cheque_cero)
			   VALUES(_dstrct,_serie,_usuario,'T','','NOMINA','N' );

  raise notice '------------------------------------';
  FOR i IN 1 .. (array_upper(facturas, 1)) LOOP

  --------BUSCA LA INFORMACION PARA GENERAR LOS EGRESOS------
     SELECT INTO _cheque COALESCE(egreso.num,( last_number + 1 )) AS num, series.prefix,
			 COALESCE(egreso.existe,FALSE) AS existe, TRIM(to_char(COALESCE(egreso.fila,1), '000')) AS fila
     FROM series
     LEFT JOIN (
	SELECT to_number(SUBSTRING(document_no,3), '999999') AS num, SUBSTRING(document_no,1,2) AS prefix, TRUE AS existe,
	       (SELECT COUNT(*) + 1 FROM egresodet d
		WHERE e.dstrct=d.dstrct AND e.branch_code=d.branch_code AND d.reg_status = ''
		AND e.bank_account_no=d.bank_account_no AND e.document_no=d.document_no) AS fila
	FROM egreso e
	INNER JOIN fin.corridas c ON c.beneficiario = e.nit_beneficiario AND c.cheque=e.document_no AND c.transferencia = _transferencia AND c.corrida = _serie
	WHERE e.dstrct = _dstrct AND e.tipo_documento = '004' AND e.concept_code = 'TR' AND e.branch_code = _banco
	AND e.bank_account_no = _sucursal AND e.nit = facturas[i][4] AND e.nit_beneficiario = facturas[i][18]
	AND e.reg_status = '' AND e.creation_date::date = now()::date AND e.creation_user = _usuario
	GROUP BY e.dstrct, e.branch_code, e.bank_account_no, e.document_no, e.nit, e.nit_beneficiario
    ) egreso ON (egreso.prefix = series.prefix)
    WHERE reg_status='' AND concepto='CXP' AND document_type = '004'
    AND branch_code = _banco AND bank_account_no = _sucursal AND dstrct = _dstrct;

    raise notice '% --> % : % : % : % : % : %', i, facturas[i][1],facturas[i][2],facturas[i][3], (_cheque.prefix||_cheque.num), _cheque.fila, facturas[i][6];

  -------GENERANDO CORRIDAS-------------------
    INSERT INTO fin.corridas (
		corrida,dstrct,tipo_documento,documento,beneficiario,nombre,valor,valor_me,
		planilla,placa,banco,sucursal,agencia_banco,moneda,creation_user,tipo_pago,
		banco_transfer,suc_transfer,tipo_cuenta,no_cuenta,cedula_cuenta,nombre_cuenta,base,
		banco_pago_tr, sucursal_pago_tr, cheque, transferencia, impresion, usuario_impresion,	--estos marcan como transferido
		pago, usuario_pago 									--estos dos autorizan la corrida
    ) VALUES ( _serie,facturas[i][1],facturas[i][2],facturas[i][3],facturas[i][4],facturas[i][5],facturas[i][6]::numeric,facturas[i][6]::numeric,
		facturas[i][20],facturas[i][21],facturas[i][8],facturas[i][9],facturas[i][10],facturas[i][11],_usuario,facturas[i][13],
		facturas[i][16],facturas[i][17],facturas[i][15],facturas[i][14],facturas[i][18],facturas[i][19],facturas[i][12],
		_banco, _sucursal, (_cheque.prefix||_cheque.num), _transferencia, now(), _usuario,
		now(),_usuario);

  -------GENERANDO EGRESOS-------------------
    IF _cheque.existe = FALSE THEN
	INSERT INTO egreso (
	   dstrct, branch_code, bank_account_no, document_no, nit, payment_name, agency_id, pmt_date, printer_date, concept_code, vlr, vlr_for,
	   currency, tipo_documento, tasa, fecha_cheque, usuario_impresion, nit_beneficiario, nit_proveedor, creation_user, base
	) VALUES (
	   _dstrct,_banco,_sucursal,(_cheque.prefix||_cheque.num),facturas[i][4], facturas[i][5],'OP',now(),now(),'TR', facturas[i][6]::numeric,facturas[i][6]::numeric,
	   facturas[i][11],'004',_tasa, now(),_usuario,facturas[i][18],facturas[i][4],_usuario,facturas[i][12] );
    ELSE
	UPDATE egreso SET
	   vlr = vlr + facturas[i][6]::numeric, vlr_for = vlr_for + facturas[i][6]::numeric
	WHERE dstrct=_dstrct AND branch_code=_banco AND bank_account_no=_sucursal
	AND document_no=(_cheque.prefix||_cheque.num) AND nit=facturas[i][4]
	AND creation_date::date = now()::date AND creation_user=_usuario;
    END IF;

    INSERT INTO egresodet (
	dstrct, branch_code, bank_account_no, document_no, item_no,
	concept_code, vlr, vlr_for, currency, creation_user,
	description, base, tasa, tipo_documento, documento, tipo_pago
    ) VALUES (
	_dstrct,_banco,_sucursal,(_cheque.prefix||_cheque.num),_cheque.fila,
	'TR',facturas[i][6]::numeric,facturas[i][6]::numeric,facturas[i][11],_usuario,
	facturas[i][7],facturas[i][12],_tasa,facturas[i][2],facturas[i][3],'C' );

  -------ACTUALIZANDO FACTURAS-------------------
    UPDATE fin.cxp_doc SET
        banco = _banco, sucursal = _sucursal,
        user_update = _usuario, last_update = now(), ultima_fecha_pago = now(),
	cheque = (_cheque.prefix||_cheque.num), corrida = _serie,
        vlr_total_abonos = vlr_total_abonos + facturas[i][6]::numeric,
        vlr_saldo = vlr_saldo - facturas[i][6]::numeric,
        vlr_total_abonos_me = vlr_total_abonos_me + facturas[i][6]::numeric,
        vlr_saldo_me = vlr_saldo_me - facturas[i][6]::numeric
    WHERE dstrct = facturas[i][1] AND tipo_documento = facturas[i][2] AND documento = facturas[i][3] AND proveedor = facturas[i][4];

    IF _cheque.existe = FALSE THEN
	UPDATE series SET last_number = _cheque.num
	WHERE reg_status='' AND concepto='CXP' AND document_type = '004'
	AND branch_code = _banco AND bank_account_no = _sucursal AND dstrct = _dstrct;
    END IF;

  END LOOP;

  _msgproceso = 'Proceso terminado';

  FOR _retorno IN (
	SELECT c.corrida::INTEGER, c.transferencia::TEXT, e.document_no::TEXT AS egreso,
	       c.beneficiario::TEXT, c.nombre::TEXT, c.no_cuenta::TEXT AS cuenta,
	       COALESCE(t.descripcion,'')::TEXT AS banco_cod, COALESCE(t.table_code::TEXT,c.banco_transfer||'_'||c.tipo_cuenta) AS banco_nom,
	       e.vlr AS valor
	FROM egreso e
	INNER JOIN fin.corridas c ON c.beneficiario = e.nit_beneficiario AND c.cheque=e.document_no AND c.transferencia = _transferencia AND c.corrida = _serie
	--LEFT JOIN tablagen t ON t.table_type = 'COD_TRANSF' AND t.table_code = c.banco_transfer||'_'||c.tipo_cuenta AND t.reg_status != 'A'
	LEFT JOIN tablagen t ON t.table_type = 'BANCOLOMBI' AND t.table_code = UPPER(c.banco_transfer) AND t.reg_status != 'A'
	WHERE e.branch_code = _banco AND e.bank_account_no = _sucursal
	AND e.reg_status = '' AND e.creation_date::date = now()::date AND e.creation_user = _usuario
	GROUP BY corrida, transferencia, egreso, beneficiario, nombre, c.no_cuenta, e.vlr, t.descripcion, t.table_code,c.banco_transfer,c.tipo_cuenta
  ) LOOP
    RETURN NEXT _retorno;
  END LOOP;
 END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fin.fn_transf_nomina(text[], text[])
  OWNER TO postgres;
