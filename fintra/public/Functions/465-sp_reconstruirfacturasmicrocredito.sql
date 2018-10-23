-- Function: sp_reconstruirfacturasmicrocredito()

-- DROP FUNCTION sp_reconstruirfacturasmicrocredito();

CREATE OR REPLACE FUNCTION sp_reconstruirfacturasmicrocredito()
  RETURNS text AS
$BODY$
  DECLARE
    mcad TEXT;
    cnt numeric;
    saldo numeric;
    _numerofac_query CHARACTER VARYING;
    _numero_factura CHARACTER VARYING;
    _auxiliar CHARACTER VARYING;

    negocios_items negocios;
    fila_items record;

  BEGIN

    mcad = 'TERMINADO!';

    FOR negocios_items IN

	    SELECT *
	    FROM negocios
	    WHERE
	        estado_neg = 'T'
	        and extract(year from f_desem) in ('2013','2014')
	        and substring(cod_neg,1,2) = 'MC'
	        and (select count(0) from con.factura where negasoc = negocios.cod_neg) = 0
	    ORDER BY f_desem LOOP

	    _numerofac_query = '';
	    SELECT INTO _numerofac_query get_lcod('CXC_MICROCRED');
	    cnt = 1;

	    FOR fila_items IN

		SELECT dna.cod_neg, dna.item, dna.fecha, dna.dias, dna.saldo_inicial, dna.capital, dna.interes, dna.valor, dna.saldo_final, dna.reg_status, dna.creation_date, dna.no_aval, dna.capacitacion, dna.cat, dna.seguro, dna.interes_causado, dna.fch_interes_causado, dna.documento_cat, dna.custodia, dna.remesa, dna.causar, n.cod_cli, n.fecha_negocio, n.cmc, n.id_convenio
		FROM documentos_neg_aceptado dna, negocios n
		WHERE dna.cod_neg = n.cod_neg
		      AND dna.cod_neg = negocios_items.cod_neg
		ORDER BY dna.dias LOOP

		saldo = 0;
		_numero_factura = '';

		IF (cnt<10) THEN
		    _numero_factura = _numerofac_query||0||cnt;
		ELSE
		    _numero_factura = _numerofac_query||cnt;
		END IF;

		IF ( cnt = 1 ) THEN
		    saldo = fila_items.capital + fila_items.seguro + 20000;
		ELSE
		    saldo = fila_items.capital + fila_items.seguro;
		END IF;

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
		values('FAC',_numero_factura,fila_items.cod_cli,get_codnit(fila_items.cod_cli),'03',fila_items.fecha_negocio,fila_items.fecha,'CXC_MICROCRED','PES','CREDITO',fila_items.cod_neg,'COL','OP','BQ',now(),'HCUELLO','1','1.000000',saldo,saldo,saldo,saldo,fila_items.item,'','','CA','FINV');

	        _auxiliar = 'RD-' || fila_items.cod_cli;

		insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
		values('FAC',_numero_factura,1,fila_items.cod_cli,'03','CAPITAL','1.0000',fila_items.capital,fila_items.capital,'1.000000','PES',now(),'HCUELLO',fila_items.capital,fila_items.capital,fila_items.cod_neg,'COL',_auxiliar,'13050801','FINV');

		insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
		values('FAC',_numero_factura,2,fila_items.cod_cli,'03','SEGURO','1.0000',fila_items.seguro,fila_items.seguro,'1.000000','PES',now(),'HCUELLO',fila_items.seguro,fila_items.seguro,fila_items.cod_neg,'COL',_auxiliar,'28150702','FINV');

		IF ( cnt = 1 ) THEN
			insert into con.factura_detalle (tipo_documento,documento,item,nit,concepto,descripcion,cantidad,valor_unitario,valor_item,valor_tasa,moneda,creation_date,creation_user,valor_unitariome,valor_itemme,numero_remesa,base,auxiliar,codigo_cuenta_contable,dstrct)
			values('FAC',_numero_factura,3,fila_items.cod_cli,'03','CENTRAL','1.0000','20000','20000','1.000000','PES',now(),'HCUELLO','20000','20000',fila_items.cod_neg,'COL',_auxiliar,'I010130014219','FINV');
		END IF;

		cnt := cnt+1;

	    END LOOP;

    END LOOP;

  RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_reconstruirfacturasmicrocredito()
  OWNER TO postgres;
