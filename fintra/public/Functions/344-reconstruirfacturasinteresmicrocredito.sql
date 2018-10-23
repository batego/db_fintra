-- Function: reconstruirfacturasinteresmicrocredito()

-- DROP FUNCTION reconstruirfacturasinteresmicrocredito();

CREATE OR REPLACE FUNCTION reconstruirfacturasinteresmicrocredito()
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

	select *
	--,(select fecha_vencimiento from con.factura where documento = tem.cambios_microcredito.documento) as vencimiento
	from tem.cambios_microcredito
	where candidata = 'GENERAR'
	      and causar = 'S'
	      and accion = 'MENOR'
	      and saldo_factura_capital and coco = 'coco' > 0 LOOP

	_numerofac_query = '';
	SELECT INTO _numerofac_query get_lcod('CXC_INTERES_MC');

	IF ( fila_items.ano = '2012' ) THEN
	   fecha_basada := '2013-01-31 00:00:00';
	ELSE
	   fecha_basada := fila_items.fecha;
	END IF;

	saldo = fila_items.interes - fila_items.suma_mi_mia;

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
	values('FAC',_numerofac_query,fila_items.nit,fila_items.cod_cli,'',fecha_basada,fecha_basada,'CXC_INTERES_MC','PES','CREDITO',fila_items.cod_neg,'COL','OP','BQ',now(),'HCUELLO','1','1.000000',saldo,saldo,saldo,saldo,fila_items.item,'','','CA','FINV');

	--------------

	_auxiliar = 'RD-' || fila_items.cod_cli;

	--------------

	insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
	values('FAC',_numerofac_query,1,fila_items.cod_cli,'','BQ-013-FENALCO-OTROS  INTERESES','1.0000',saldo,saldo,'1.000000','PES',now(),'HCUELLO',saldo,saldo,fila_items.documento,'COL',_auxiliar,'I010130014169','FINV');

	--------------

	update documentos_neg_aceptado set interes_causado = interes where cod_neg = fila_items.cod_neg and item = fila_items.item;

    END LOOP;

  RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION reconstruirfacturasinteresmicrocredito()
  OWNER TO postgres;
