-- Function: actualizarvalorpi()

-- DROP FUNCTION actualizarvalorpi();

CREATE OR REPLACE FUNCTION actualizarvalorpi()
  RETURNS text AS
$BODY$
  DECLARE
    mcad TEXT;
    cod_pi TEXT;
    suma_nueva_pi CHARACTER VARYING;
    negocios_items ing_fenalco;

  BEGIN

    mcad = 'TERMINADO!';
    cod_pi = '';

    FOR negocios_items IN

	SELECT DISTINCT ON (codneg) *
	FROM ing_fenalco
	WHERE tipodoc = 'IP'
	AND codneg in (select documento from tem.negocios_carguefiducia where ciclo_fecha = '2013-02-20' ) --'NG18031'
	LOOP

	cod_pi := 'PI'||substring(negocios_items.codneg,3);
	SELECT INTO suma_nueva_pi sum(valor) from ing_fenalco where codneg = negocios_items.codneg and tipodoc = 'IP' and extract(year from fecha_doc)>='2013';

	--mcad := cod_pi || ' - ' || suma_nueva_pi;
	--mcad := 'UPDATE con.comprobante SET total_debito = ' || suma_nueva_pi || ', total_credito = ' || suma_nueva_pi || ' WHERE numdoc = ' || cod_pi;

	UPDATE con.comprobante SET total_debito = suma_nueva_pi::numeric, total_credito = suma_nueva_pi::numeric WHERE numdoc = cod_pi;
	UPDATE con.comprodet SET valor_credito = suma_nueva_pi::numeric WHERE numdoc = cod_pi and valor_debito = '0';
	UPDATE con.comprodet SET valor_debito = suma_nueva_pi::numeric WHERE numdoc = cod_pi and valor_credito = '0';

    END LOOP;

    RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION actualizarvalorpi()
  OWNER TO postgres;
