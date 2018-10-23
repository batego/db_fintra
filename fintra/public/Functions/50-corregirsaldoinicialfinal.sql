-- Function: corregirsaldoinicialfinal(numeric)

-- DROP FUNCTION corregirsaldoinicialfinal(numeric);

CREATE OR REPLACE FUNCTION corregirsaldoinicialfinal(tasa numeric)
  RETURNS text AS
$BODY$
  DECLARE
    mcad TEXT;
    cadUpdate TEXT;

    cnt numeric;
    saldo_inicial numeric;
    capital numeric;
    saldo_final numeric;
    UltimoSaldo numeric;

    fila_items documentos_neg_aceptado;
    negocios_items tem.inserts_funciones_hys;

  BEGIN

    mcad = '';
    cadUpdate = '';

    saldo_inicial = 0;
    capital = 0;
    saldo_final = 0;
    UltimoSaldo = 0;

    FOR negocios_items IN SELECT * FROM tem.inserts_funciones_hys WHERE accion = 'INICIAL' LOOP

	    cnt = 1;

	    FOR fila_items IN SELECT * FROM documentos_neg_aceptado WHERE cod_neg = negocios_items.insert_update order by dias LOOP

		IF ( cnt = 1 ) THEN
		    saldo_inicial = fila_items.saldo_inicial;
		ELSE
		    saldo_inicial = saldo_final;
		END IF;

		capital = fila_items.capital;
		saldo_final = saldo_inicial - capital;

		IF ( saldo_final < 10 ) THEN
		    saldo_final = 0.00;
		END IF;

		cadUpdate := 'UPDATE documentos_neg_aceptado SET saldo_inicial =vi' || saldo_inicial || 'vi, saldo_final = vi' || saldo_final || 'vi where cod_neg = vi' || fila_items.cod_neg || 'vi and dias = vi' || fila_items.dias || 'vi;';
		INSERT INTO tem.inserts_funciones_hys (accion,tabla,negocio,insert_update) VALUES(fila_items.dias,'documentos_neg_aceptado',fila_items.cod_neg, cadUpdate);
		--mcad := mcad || cadUpdate || ',';
		cnt := cnt+1;

	    END LOOP;

    END LOOP;

  RETURN mcad;
  --RETURN a;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION corregirsaldoinicialfinal(numeric)
  OWNER TO postgres;
