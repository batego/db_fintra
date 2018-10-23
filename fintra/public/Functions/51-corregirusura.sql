-- Function: corregirusura(numeric)

-- DROP FUNCTION corregirusura(numeric);

CREATE OR REPLACE FUNCTION corregirusura(tasa numeric)
  RETURNS text AS
$BODY$
  DECLARE
    mcad TEXT;
    cadUpdate TEXT;
    cadDetall TEXT;
    r numeric;
    vp numeric;
    interes numeric;
    cnt numeric;
    saldo numeric;
    saldo_inicial numeric;
    capital numeric;
    cuota numeric;
    UltimoNumero numeric;
    DiffDias numeric;
    fila_items documentos_neg_aceptado;
    vp_items documentos_neg_aceptado;
    factura_items con.factura;
    negocios_items negocios;

  BEGIN

    mcad = '';
    cadUpdate = '';
    cadDetall = '';

    FOR negocios_items IN SELECT * FROM negocios WHERE cod_neg in (select insert_update from tem.inserts_funciones_hys where accion = 'INICIAL') LOOP

	    UltimoNumero = 0;
	    DiffDias = 0;
	    saldo_inicial = 0;
	    saldo = 0;
	    cnt = 1;
	    cuota = 0;
	    capital = 0;
	    vp = 0;

	    FOR vp_items IN SELECT * FROM documentos_neg_aceptado WHERE cod_neg = negocios_items.cod_neg order by dias LOOP

		IF ( cnt = 1 ) THEN
		    saldo_inicial = vp_items.saldo_inicial;
		END IF;

		DiffDias = vp_items.dias - UltimoNumero;
		vp = vp + ((1+(tasa/100)) ^ -(DiffDias/360));
		cnt := cnt+1;

	    END LOOP;
	    cuota = saldo_inicial / vp;
	    saldo = saldo_inicial;

	    UltimoNumero = 0;
	    DiffDias = 0;
	    cnt = 1;

	    FOR fila_items IN SELECT * FROM documentos_neg_aceptado WHERE cod_neg = negocios_items.cod_neg order by dias LOOP

		r = 0;
		interes = 0;
		capital = 0;
		DiffDias = fila_items.dias - UltimoNumero;
		r = (1+(tasa/100)) ^ (DiffDias/360);

		interes =  round((saldo * r) - saldo);
		capital = round((saldo_inicial / vp) - interes);
		UltimoNumero := fila_items.dias;

		saldo = saldo + interes - cuota;

		--mcad := mcad || round(capital) || '-' || interes || ',';
		cadUpdate := 'UPDATE documentos_neg_aceptado SET capital =vi' || capital || 'vi, interes = vi' || interes || 'vi, valor = vi' || capital+interes || 'vi where cod_neg = vi' || fila_items.cod_neg || 'vi and dias = vi' || fila_items.dias || 'vi;';
		INSERT INTO tem.inserts_funciones_hys (accion,tabla,negocio,insert_update) VALUES(fila_items.dias,'documentos_neg_aceptado',fila_items.cod_neg, cadUpdate);

		FOR factura_items IN

			select *
			from con.factura
			where negasoc = fila_items.cod_neg
			and valor_factura = fila_items.capital	LOOP

			--mcad := mcad || factura_items.documento || ',';
			cadUpdate := 'UPDATE con.factura SET valor_factura =vi' || capital || 'vi, valor_facturame = vi' || capital || 'vi, valor_saldo = vi' || capital || 'vi, valor_saldome = vi' || capital || 'vi where documento = vi' || factura_items.documento || 'vi and valor_factura = vi' || factura_items.valor_factura || 'vi;';
			cadDetall := 'UPDATE con.factura_detalle SET valor_unitario =vi' || capital || 'vi, valor_unitariome = vi' || capital || 'vi, valor_item = vi' || capital || 'vi, valor_itemme = vi' || capital || 'vi where documento = vi' || factura_items.documento || 'vi and valor_item = vi' || factura_items.valor_factura || 'vi;';
			INSERT INTO tem.inserts_funciones_hys (accion,tabla,negocio,insert_update) VALUES('UPDATE','factura',factura_items.documento, cadUpdate);
			INSERT INTO tem.inserts_funciones_hys (accion,tabla,negocio,insert_update) VALUES('DETALLE','factura',factura_items.documento, cadDetall);

		END LOOP;

	    END LOOP;

    END LOOP;

  RETURN mcad;
  --RETURN a;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION corregirusura(numeric)
  OWNER TO postgres;
