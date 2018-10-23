-- Function: sp_anularcomprobantes()

-- DROP FUNCTION sp_anularcomprobantes();

CREATE OR REPLACE FUNCTION sp_anularcomprobantes()
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
		--create table tem.anularcomprobantesCA as --select * from tem.anularcomprobantesCA
		select
		(select fecha_vencimiento from con.factura where documento = (select numero_remesa from con.factura_detalle where documento = f.documento limit 1)) as vencimiento_fact_padre,
		*
		from con.factura f
		where substring(documento,1,2) = 'CA'
		and fecha_factura = '2013-08-23'
		and reg_status != 'A'
		and (select fecha_vencimiento from con.factura where documento = (select numero_remesa from con.factura_detalle where documento = f.documento limit 1)) >= '2013-11-01'

	    LOOP

	    _grupo_transaccion = 0;
	    SELECT INTO _grupo_transaccion nextval('con.comprobante_grupo_transaccion_seq');

	    _detalle_factura = '';
	    _detalle_factura = 'DESCONTABILIZACION CLIENTE FAC ' || facturas_anular.documento;

		    INSERT INTO con.comprobante SELECT
		    reg_status,
		    dstrct,
		    tipodoc,
		    numdoc,
		    _grupo_transaccion,
		    sucursal,
		    '201310',
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
	    FOR items_comprobante IN SELECT * FROM con.comprodet WHERE numdoc = /*'MI27081'*/ facturas_anular.documento LOOP

		   _transaccion = 0;
		   SELECT INTO _transaccion nextval('con.comprodet_transaccion_seq');

		   INSERT INTO con.comprodet SELECT
		   reg_status,
		   dstrct,
		   tipodoc,
		   numdoc,
		   _grupo_transaccion,
		   _transaccion,
		   '201310',
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
ALTER FUNCTION sp_anularcomprobantes()
  OWNER TO postgres;
