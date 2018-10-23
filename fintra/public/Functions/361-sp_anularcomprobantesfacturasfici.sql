-- Function: sp_anularcomprobantesfacturasfici()

-- DROP FUNCTION sp_anularcomprobantesfacturasfici();

CREATE OR REPLACE FUNCTION sp_anularcomprobantesfacturasfici()
  RETURNS text AS
$BODY$

  DECLARE

    mcad TEXT;
    facturas_anular record;
    items_comprobante record;

    _grupo_transaccion numeric;
    _transaccion numeric;

    _detalle_factura CHARACTER VARYING;

  BEGIN

    mcad = 'TERMINADO!';

    FOR facturas_anular IN
		--create table tem.AnularFacturasfici as --select * from tem.AnularFacturasfici
		select *
		from con.factura
		where substring(documento,1,2) in ('FI','CI')
		and reg_status = 'A'
		and fecha_contabilizacion_anulacion = '0099-01-01 00:00:00'
		and (select count(0) from con.comprobante where numdoc = con.factura.documento ) = 1 LOOP

	    _grupo_transaccion = 0;
	    SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

	    _detalle_factura = '';
	    _detalle_factura = 'DESCONTABILIZACION HYS CLIENTE FAC ' || facturas_anular.documento;

		    INSERT INTO con.comprobante SELECT
		    reg_status,
		    dstrct,
		    tipodoc,
		    numdoc,
		    _grupo_transaccion,
		    sucursal,
		    '201311',
		    fechadoc,
		    _detalle_factura,
		    tercero,
		    total_debito,
		    total_credito,
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
		    FROM con.comprobante WHERE numdoc = facturas_anular.documento;

	    --------------------------------DETALLE-------------------------------------------------
	    FOR items_comprobante IN SELECT * FROM con.comprodet WHERE numdoc = facturas_anular.documento LOOP

		   _transaccion = 0;
		   SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

		   INSERT INTO con.comprodet SELECT
		   reg_status,
		   dstrct,
		   tipodoc,
		   numdoc,
		   _grupo_transaccion,
		   _transaccion,
		   '201311',
		   cuenta,
		   '',
		   _detalle_factura,
		   valor_credito,
		   valor_debito,
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
	    END LOOP;

    END LOOP;

  RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_anularcomprobantesfacturasfici()
  OWNER TO postgres;
