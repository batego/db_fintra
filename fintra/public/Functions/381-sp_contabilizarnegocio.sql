-- Function: sp_contabilizarnegocio(character varying, character varying, character varying, numeric, character varying)

-- DROP FUNCTION sp_contabilizarnegocio(character varying, character varying, character varying, numeric, character varying);

CREATE OR REPLACE FUNCTION sp_contabilizarnegocio(_cod_neg character varying, _cod_cli character varying, _nombre character varying, _vlrnegocio numeric, _user character varying)
  RETURNS text AS
$BODY$

DECLARE

	_respuesta varchar := 'OK';
	_PeriodoCte varchar := '';

	_grupo_transaccion numeric;
	_transaccion numeric;

	miHoy date;

BEGIN

	miHoy = now()::date;
	_PeriodoCte = replace(substring(miHoy,1,7),'-','')::varchar;

	/*-----------------------------
	   --Contabilizar Negocio--
	-------------------------------*/

	_grupo_transaccion = 0;
	SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

	--(Cabecera)
	INSERT INTO con.comprobante(
		    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
		    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
		    total_items, moneda, fecha_aplicacion, aprobador, last_update,
		    user_update, creation_date, creation_user, base, usuario_aplicacion,
		    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
	    VALUES ('', 'FINV', 'NEG', _cod_neg, _grupo_transaccion, 'OP',
		    _PeriodoCte, now()::date, 'NEGOCIO No '||_cod_neg, _cod_cli, _VlrNegocio, _VlrNegocio,
		    2, 'PES', '0099-01-01 00:00:00', _User, now(),
		    _User, now(), _User, 'COL', _User,
		    '', '', 0.00, '', '');

	--(Detalle)
	--1
	_transaccion = 0;
	SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

	INSERT INTO con.comprodet(
		    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
		    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
		    tercero, documento_interno, last_update, user_update, creation_date,
		    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
		    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
		    tipo_referencia_3, referencia_3)
	    VALUES ('', 'FINV', 'NEG', _cod_neg, _grupo_transaccion, _transaccion,
		    _PeriodoCte, '13050940', 'RD - '||_cod_cli, _Nombre, _VlrNegocio, 0.00,
		    _cod_cli, _cod_neg, now(), _User, now(),
		    _User, 'COL', 'NEG', _cod_neg, '', 0.00,
		    '', '', '', '',
		    '', '');

	--2
	_transaccion = 0;
	SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

	--VlrComisionAnt = ROUND(InfoManfts.valor_neto_anticipo*(1.4/100));

	INSERT INTO con.comprodet(
		    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
		    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
		    tercero, documento_interno, last_update, user_update, creation_date,
		    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
		    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
		    tipo_referencia_3, referencia_3)
	    VALUES ('', 'FINV', 'NEG', _cod_neg, _grupo_transaccion, _transaccion,
		    _PeriodoCte, '23050940', 'RD - '||_cod_cli, _Nombre, 0.00, _VlrNegocio,
		    _cod_cli, _cod_neg, now(), _User, now(),
		    _User, 'COL', 'NEG', _cod_neg, '', 0.00,
		    '', '', '', '',
		    '', '');

	UPDATE negocios
	SET
	   fecha_cont = now(),
	   periodo = _PeriodoCte,
	   no_transacion = _grupo_transaccion
	WHERE cod_neg = _cod_neg;

	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_contabilizarnegocio(character varying, character varying, character varying, numeric, character varying)
  OWNER TO postgres;
