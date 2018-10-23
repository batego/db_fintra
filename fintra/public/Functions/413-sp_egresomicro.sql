-- Function: sp_egresomicro(character varying, character varying, character varying)

-- DROP FUNCTION sp_egresomicro(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_egresomicro(_cxpcheque character varying, _bancotransf character varying, _usuario character varying)
  RETURNS text AS
$BODY$

DECLARE

	InfoCxP record;

	_grupo_transaccion numeric;
	_transaccion numeric;

	NoEgreso varchar := '';
	BranchCode varchar := '';
	BankAccount varchar := '';
	_PeriodoCte varchar := '';

	_respuesta varchar := '';

	miHoy date;

BEGIN

	miHoy = now()::date;
	_PeriodoCte = replace(substring(miHoy,1,7),'-','')::varchar;

	select into InfoCxP * from fin.cxp_doc where documento = _CxPCheque and cheque = '';
	RAISE NOTICE 'InfoCxP : %', InfoCxP.documento;
	IF FOUND THEN

		--NUMERO DE EGRESO--
		NoEgreso := get_num_egreso_libranza();
		_respuesta = NoEgreso;
		RAISE NOTICE 'EGRESO No: %', NoEgreso;

		select into BranchCode split_part(_BancoTransf, ',', 1);
		select into BankAccount split_part(_BancoTransf, ',', 2);

		--CABECERA DEL EGRESO--
		INSERT INTO egreso(
			    reg_status, dstrct, branch_code, bank_account_no, document_no,
			    nit, payment_name, agency_id, pmt_date, printer_date, concept_code,
			    vlr, vlr_for, currency, last_update, user_update, creation_date,
			    creation_user, base, tipo_documento, tasa, fecha_cheque, usuario_impresion,
			    usuario_contabilizacion, fecha_contabilizacion,nit_beneficiario,
			    nit_proveedor, usuario_generacion, contabilizable, comision)
		    VALUES ('','FINV', BranchCode, BankAccount, NoEgreso,
			    InfoCxP.proveedor, get_nombp(InfoCxP.proveedor), 'OP', NOW()::date, '0099-01-01', '002',
			    InfoCxP.vlr_neto, InfoCxP.vlr_neto, 'PES', '0099-01-01'::TIMESTAMP,'', NOW(),
			    _Usuario, 'COL', '004', 1.0,  NOW()::date, '',
			    '','0099-01-01'::TIMESTAMP, InfoCxP.proveedor,
			    InfoCxP.proveedor, _Usuario, 'S', 0);


		--DETALLE DEL EGRESO--
		INSERT INTO egresodet(
			    reg_status, dstrct, branch_code, bank_account_no, document_no,
			    item_no, concept_code, vlr, vlr_for, currency, last_update,
			    user_update, creation_date, creation_user, description, base,
			    tasa, tipo_documento, documento, tipo_pago, cuenta,
			    auxiliar)
		    VALUES ('', 'FINV', BranchCode, BankAccount, NoEgreso,
			    lpad('1', 3, '0'), '003', InfoCxP.vlr_neto, InfoCxP.vlr_neto, 'PES', '0099-01-01'::TIMESTAMP,
			    '', NOW(), _Usuario, 'DESEMBOLSO MICROCREDITO', 'COL',
			    1.0, (SELECT COALESCE(tipo_documento,'-') FROM fin.cxp_doc  where documento = _CxPCheque), _CxPCheque, 'C', '',
			    '');

		--ACTUALIZA LA CUENTA POR PAGAR--
		_grupo_transaccion = 0;
		SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');
		------------------------------------------------------------------------------------------------------------------------------------------------
		UPDATE fin.cxp_doc
		SET
			banco                = BranchCode,
			sucursal             = BankAccount,
			moneda_banco         = 'PES',
			cheque               = NoEgreso,
			vlr_total_abonos     = vlr_total_abonos    + InfoCxP.vlr_neto,
			vlr_saldo            = vlr_saldo           - InfoCxP.vlr_neto,
			vlr_total_abonos_me  = vlr_total_abonos_me + InfoCxP.vlr_neto,
			vlr_saldo_me         = vlr_saldo_me        - InfoCxP.vlr_neto,
			user_update          = _Usuario,
			ultima_fecha_pago    = now()
		WHERE
		dstrct           =  'FINV'
		AND   proveedor        =  InfoCxP.proveedor
		AND   tipo_documento   =  InfoCxP.tipo_documento
		AND   documento        =  InfoCxP.documento;




	END IF;

	RETURN _respuesta;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_egresomicro(character varying, character varying, character varying)
  OWNER TO postgres;
