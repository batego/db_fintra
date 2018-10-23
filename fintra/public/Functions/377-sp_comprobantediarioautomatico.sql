-- Function: sp_comprobantediarioautomatico(character varying, character varying, character varying, character varying)

-- DROP FUNCTION sp_comprobantediarioautomatico(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_comprobantediarioautomatico(distrito character varying, tipo_documento character varying, documfact character varying, usuario character varying)
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

    VerifyDetails CHARACTER VARYING;
    _NumeroCD CHARACTER VARYING;
    _PeriodoCD CHARACTER VARYING;
    _CuentaCD CHARACTER VARYING;

    _Mcomprobante CHARACTER VARYING;

  BEGIN

    mcad = '¡TERMINADO!'; --mcad = '';
    Diferencia = 0;

    --FOR factura_afectar IN select *, (select cuenta from con.cmc_doc where cmc = con.factura.cmc and tipodoc = 'FAC') as handle_code from con.factura where documento in (select documento from tem.traslado_corfi_fintra2) LOOP --(select * from tem.traslado_corfi_fintra)
    --FOR factura_afectar IN select *, (select cuenta from con.cmc_doc where cmc = f.cmc and tipodoc = 'FAC') as handle_code from tem.traslado_corfi_fintra3 f LOOP

    FOR factura_afectar IN select *, (select cuenta from con.cmc_doc where cmc = f.cmc and tipodoc = 'FAC') as handle_code from con.factura f where documento = DocumFact LOOP

	    _Mcomprobante = 'SM' || substring(factura_afectar.documento,3);
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
	    'HCUELLO',
	    now(),
	    'HCUELLO',
	    base,
	    tipo_operacion,
	    vlr_for
	    FROM con.comprobante WHERE numdoc = factura_afectar.documento and detalle not ilike 'DESCONTABILIZACION%';

	    --DETALLE COMPROBANTE
	    BolsaSaldo = factura_afectar.valor_saldo;
	    --mcad = 'BolsaSaldoORIGEN: ' || BolsaSaldo|| '::';

	    FOR items_comprobante IN SELECT *, (select concepto from con.factura_detalle where documento = con.comprodet.numdoc and valor_unitario = con.comprodet.valor_credito ) as "concepto" FROM con.comprodet WHERE numdoc = factura_afectar.documento and detalle not ilike 'DESCONTABILIZACION%' order by auxiliar, concepto LOOP

		   _transaccion = 0;
		   SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

		   VerifyDetails = 'N';

		   IF ( items_comprobante.valor_debito > 0  ) THEN

			_ValorDebito = factura_afectar.valor_saldo; --items_comprobante.valor_debito;
			_ValorCredito = 0;
			_CuentaCD = '13050704';
			VerifyDetails = 'S';

		   ELSIF ( items_comprobante.valor_credito > 0  ) THEN

			Diferencia = BolsaSaldo - items_comprobante.valor_credito;

			if ( Diferencia <= 0 and BolsaSaldo > 0) then

				_ValorCredito = BolsaSaldo; --items_comprobante.valor_credito;
				_ValorDebito = 0;
				_CuentaCD = factura_afectar.handle_code;

				BolsaSaldo = BolsaSaldo - items_comprobante.valor_credito;
				VerifyDetails = 'S';
				--mcad := mcad || 'A-Diferencia: ' || Diferencia || ' BolsaSaldo: ' || BolsaSaldo || ' valor_credito: ' ||items_comprobante.valor_credito;

			elsif ( Diferencia > 0 and BolsaSaldo > 0 ) then

				_ValorCredito = items_comprobante.valor_credito;
				_ValorDebito = 0;
				_CuentaCD = factura_afectar.handle_code;

				BolsaSaldo = BolsaSaldo - items_comprobante.valor_credito;
				VerifyDetails = 'S';
				--mcad := mcad || 'B-Diferencia: ' || Diferencia || ' BolsaSaldo: ' || BolsaSaldo || ' valor_credito: ' ||items_comprobante.valor_credito;

			end if;

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
			   'HCUELLO',
			   now(),
			   'HCUELLO',
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
	         VALUES (now(), usuario, factura_afectar.documento, factura_afectar.reg_status, Distrito, factura_afectar.nit, factura_afectar.codcli, factura_afectar.cmc, factura_afectar.clasificacion1, factura_afectar.handle_code);

	    UPDATE con.factura SET cmc = 'SR', clasificacion1 = 'FIDFIV' WHERE documento = factura_afectar.documento;

    END LOOP;

  RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_comprobantediarioautomatico(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
