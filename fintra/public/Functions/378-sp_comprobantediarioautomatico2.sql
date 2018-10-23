-- Function: sp_comprobantediarioautomatico2(character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION sp_comprobantediarioautomatico2(character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_comprobantediarioautomatico2(_distrito character varying, _tipo_documento character varying, _documfact character varying, _fiducia_destino character varying, _usuario character varying)
  RETURNS text AS
$BODY$

  DECLARE

    mcad TEXT;
    factura_afectar record;
    items_comprobante record;

    _grupo_transaccion numeric;
    _transaccion numeric;
    _ValorCredito numeric;
    _ValorDebito numeric;
    BolsaSaldo numeric;
    Diferencia numeric;
    TotalAbono numeric;
    Ajuste numeric;

    VerifyDetails CHARACTER VARYING;
    _NumeroCD CHARACTER VARYING;
    _PeriodoCD CHARACTER VARYING;
    _CuentaCD CHARACTER VARYING;

    _cmcFID CHARACTER VARYING;

    _Mcomprobante CHARACTER VARYING;

  BEGIN

    mcad = '¡TERMINADO!';
    Diferencia = 0;

    SELECT INTO _cmcFID valor FROM constante WHERE codigo= _fiducia_destino||' HANDLE CODE FACTURA PM';


    FOR factura_afectar IN select *, (select cuenta from con.cmc_doc where cmc = f.cmc and tipodoc = _tipo_documento) as handle_code from con.factura f where documento = _DocumFact LOOP

	    _Mcomprobante = 'DM' || substring(factura_afectar.documento,3);
	    _numeroCD = _Mcomprobante;
	    _PeriodoCD = replace(substring(now(),1,7),'-','');

	    _grupo_transaccion = 0;
	    SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

	    --CABECERA COMPROBANTE
	    INSERT INTO con.comprobante SELECT
	    reg_status,
	    dstrct,
	    'CDIAR',
	    _NumeroCD,
	    _grupo_transaccion,
	    sucursal,
	    _PeriodoCD,
	    fechadoc,
	    detalle,
	    tercero,
	    factura_afectar.valor_saldo, --total_debito,
	    factura_afectar.valor_saldo, --total_credito,
	    total_items,
	    moneda,
	    '0099-01-01 00:00:00',
	    aprobador,
	    now(),
	    _usuario,
	    now(),
	    _usuario,
	    base,
	    tipo_operacion,
	    vlr_for
	    FROM con.comprobante WHERE numdoc = factura_afectar.documento and detalle not ilike 'DESCONTABILIZACION%';

	    --DETALLE COMPROBANTE
	    BolsaSaldo = factura_afectar.valor_saldo;
	    TotalAbono = factura_afectar.valor_abono;
	    --mcad = 'BolsaSaldoORIGEN: ' || BolsaSaldo|| '::';

	    FOR items_comprobante IN SELECT *, (select concepto from con.factura_detalle where documento = con.comprodet.numdoc and valor_unitario = con.comprodet.valor_credito ) as "concepto" FROM con.comprodet WHERE numdoc = factura_afectar.documento and detalle not ilike 'DESCONTABILIZACION%' order by auxiliar, concepto LOOP

		   _transaccion = 0;
		   SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

		   VerifyDetails = 'N';

		   IF ( items_comprobante.valor_debito > 0  ) THEN

			_ValorDebito = factura_afectar.valor_saldo; --items_comprobante.valor_debito;
			_ValorCredito = 0;
			SELECT INTO _CuentaCD cuenta FROM con.cmc_doc WHERE cmc=_cmcFID AND tipodoc = _tipo_documento;
			VerifyDetails = 'S';

		   ELSIF ( items_comprobante.valor_credito > 0  ) THEN

			Diferencia = BolsaSaldo - items_comprobante.valor_credito;

			if ( Diferencia <= 0 and BolsaSaldo > 0) then

				_ValorCredito = BolsaSaldo; --items_comprobante.valor_credito;

			elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then
				--AJUSTES
				IF (TotalAbono < 0) THEN
					SELECT INTO Ajuste COALESCE(a.suma*-1,0)::numeric FROM (
					   SELECT
					   sum(id.valor_ingreso) AS suma,
					   CASE WHEN i.cuenta = '27050804' OR i.cuenta = '27050805' THEN 'Capital'
					   WHEN i.cuenta = '27050803' THEN 'Intereses'
					   ELSE '' END as concepto
					   FROM con.ingreso_detalle id
					   INNER JOIN con.ingreso i ON id.num_ingreso = i.num_ingreso AND id.tipo_documento = i.tipo_documento
					   WHERE id.valor_ingreso < 0 AND id.documento = items_comprobante.numdoc AND id.tipo_documento='ICA'
					   GROUP BY 2
					) a WHERE a.concepto = items_comprobante.detalle;

					items_comprobante.valor_credito = items_comprobante.valor_credito + Ajuste;
					TotalAbono = TotalAbono + Ajuste;
				END IF;
				_ValorCredito = items_comprobante.valor_credito;

			end if;

			_ValorDebito = 0;
			_CuentaCD = factura_afectar.handle_code;

			BolsaSaldo = BolsaSaldo - items_comprobante.valor_credito;
			VerifyDetails = 'S';

		   END IF;

		   if ( VerifyDetails = 'S' ) then

			   INSERT INTO con.comprodet SELECT
			   reg_status,
			   dstrct,
			   'CDIAR',
			   _NumeroCD,
			   _grupo_transaccion,
			   _transaccion,
			   _PeriodoCD,
			   _CuentaCD,
			   auxiliar,
			   detalle,
			   _ValorDebito, --valor_credito,
			   _ValorCredito, --valor_debito,
			   tercero,
			   documento_interno,
			   now(),
			   _usuario,
			   now(),
			   _usuario,
			   base,
			   tipodoc_rel,
			   documento_rel,
			   abc,
			   vlr_for
			   FROM con.comprodet WHERE numdoc = items_comprobante.numdoc and grupo_transaccion = items_comprobante.grupo_transaccion and transaccion = items_comprobante.transaccion;

		   end if;

	    END LOOP;

	    --CAMBIO DE HC y ALMACENAMIENTO HISTORICO.
	    INSERT INTO con.historico_traslado_fiducia(creation_date, usuario_traslado, documento, reg_status, dstrct, nit, codcli, cmc, clasificacion1, cuenta_detalle_factura)
	         VALUES (now(), _usuario, factura_afectar.documento, factura_afectar.reg_status, _distrito, factura_afectar.nit, factura_afectar.codcli, factura_afectar.cmc, factura_afectar.clasificacion1, factura_afectar.handle_code);

	    UPDATE con.factura SET cmc = _cmcFID, clasificacion1 = _fiducia_destino WHERE documento = factura_afectar.documento;

    END LOOP;

  RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_comprobantediarioautomatico2(character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
