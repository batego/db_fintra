-- Function: sp_facturasinteresmicrocredito()

-- DROP FUNCTION sp_facturasinteresmicrocredito();

CREATE OR REPLACE FUNCTION sp_facturasinteresmicrocredito()
  RETURNS text AS
$BODY$
  DECLARE

    mcad TEXT;
    cnt numeric;
    saldo numeric;

    fecha_basada timestamp;
    _numerofac_query CHARACTER VARYING;
    _auxiliar CHARACTER VARYING;

    fila_items record;

  BEGIN

    mcad = 'TERMINADO!';

    FOR fila_items IN

	select * from tem.microup2 LOOP

	IF ( fila_items.suma_mis < fila_items.interes_verdad ) THEN

		_numerofac_query = '';
		--SELECT INTO _numerofac_query get_lcod('CXC_INTERES_MC');
		SELECT INTO _numerofac_query get_lcod('CXC_CAT_MC');

		insert into con.factura
		(
		tipo_documento,
		documento,
		nit,
		codcli,
		concepto,
		fecha_factura,
		fecha_vencimiento,
		descripcion,
		moneda,
		forma_pago,
		negasoc,
		base,
		agencia_facturacion,
		agencia_cobro,
		creation_date,
		creation_user,
		cantidad_items,
		valor_tasa,
		valor_factura,
		valor_facturame,
		valor_saldo,
		valor_saldome,
		num_doc_fen,
		tipo_ref1,
		ref1,
		cmc,
		dstrct
		)
		--values('FAC',_numerofac_query,fila_items.nit,fila_items.codcli,'',fila_items.fecha_vencimiento::date,fila_items.fecha_vencimiento::date,'CXC_INTERES_MC','PES','CREDITO',fila_items.negocio,'COL','OP','BQ',now(),'HCUELLO','1','1.000000',fila_items.valor_generar,fila_items.valor_generar,fila_items.valor_generar,fila_items.valor_generar,fila_items.cuota,'','','CA','FINV');
		values('FAC',_numerofac_query,fila_items.nit,fila_items.codcli,'',fila_items.fecha_vencimiento::date,fila_items.fecha_vencimiento::date,'CXC_CAT_MC','PES','CREDITO',fila_items.negocio,'COL','OP','BQ',now(),'HCUELLO','1','1.000000',fila_items.valor_generar,fila_items.valor_generar,fila_items.valor_generar,fila_items.valor_generar,fila_items.cuota,'','','CA','FINV');

		--------------

		_auxiliar = 'RD-' || fila_items.nit;

		--------------

		--insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
		--values('FAC',_numerofac_query,1,fila_items.nit,'','INTERESES MICROCREDITO AUDITORIA','1.0000',fila_items.valor_generar,fila_items.valor_generar,'1.000000','PES',now(),'HCUELLO',fila_items.valor_generar,fila_items.valor_generar,fila_items.documento,'COL',_auxiliar,'I010130014169','FINV');


		insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
		values('FAC',_numerofac_query,1,fila_items.nit,'','IMPUESTO CAT AUDITORIA','1.0000',(fila_items.valor_generar/1.16),(fila_items.valor_generar/1.16),'1.000000','PES',now(),'HCUELLO',(fila_items.valor_generar/1.16),(fila_items.valor_generar/1.16),fila_items.documento,'COL',_auxiliar,'I010130014144','FINV');

		insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
		values('FAC',_numerofac_query,2,fila_items.nit,'','IVA CAT AUDITORIA','1.0000',(fila_items.valor_generar/1.16)*0.16,(fila_items.valor_generar/1.16)*0.16,'1.000000','PES',now(),'HCUELLO',(fila_items.valor_generar/1.16)*0.16,(fila_items.valor_generar/1.16)*0.16,fila_items.documento,'COL',_auxiliar,'24080109','FINV');

		--------------

		update documentos_neg_aceptado set interes_causado = interes where cod_neg = fila_items.negocio and item = fila_items.cuota;
	END IF;

    END LOOP;

  RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_facturasinteresmicrocredito()
  OWNER TO postgres;
