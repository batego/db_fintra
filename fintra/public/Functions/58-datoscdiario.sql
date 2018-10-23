-- Function: datoscdiario()

-- DROP FUNCTION datoscdiario();

CREATE OR REPLACE FUNCTION datoscdiario()
  RETURNS text AS
$BODY$

DECLARE
	mcad TEXT;
	cad1 TEXT;
	cad2 TEXT;
	ing_fenalco_ip ing_fenalco;
	ing_fenalco_if ing_fenalco;

BEGIN

	mcad = '';
	cad1 = '';
	cad2 = '';

	FOR ing_fenalco_ip IN

		select *
		from ing_fenalco
		where codneg in (select documento from tem.negocios_carguefiducia)
		and transaccion != 0
		and tipodoc = 'IP'
		order by fecha_doc,reg_status LOOP

		FOR ing_fenalco_if IN select * from ing_fenalco where tipodoc = 'IF' and transaccion != 0 and transaccion_anulacion = ing_fenalco_ip.transaccion and substring(periodo,1,4) <= '2012' LOOP
			IF ( ing_fenalco_if.cod != '' ) THEN --unknown
				cad1 := 'vi' || ing_fenalco_ip.reg_status || 'vi,vi' || ing_fenalco_ip.cod || 'vi,vi' || ing_fenalco_ip.codneg || 'vi,vi' || ing_fenalco_ip.tipodoc || 'vi,vi' || ing_fenalco_ip.valor || 'vi,vi' || ing_fenalco_ip.nit || 'vi,vi' || ing_fenalco_ip.periodo || 'vi,vi' || ing_fenalco_ip.transaccion || 'vi,vi' || ing_fenalco_ip.transaccion_anulacion || 'vi,vi' || ing_fenalco_ip.creation_date || 'vi,vi' || ing_fenalco_ip.fecha_contabilizacion || 'vi,vi' || ing_fenalco_ip.fecha_anulacion || 'vi,vi' || ing_fenalco_ip.cmc || 'vi,vi' || ing_fenalco_ip.fecha_doc || 'vi' || E'\n';
				cad2 := 'vi' || ing_fenalco_if.reg_status || 'vi,vi' || ing_fenalco_if.cod || 'vi,vi' || ing_fenalco_if.codneg || 'vi,vi' || ing_fenalco_if.tipodoc || 'vi,vi' || ing_fenalco_if.valor || 'vi,vi' || ing_fenalco_if.nit || 'vi,vi' || ing_fenalco_if.periodo || 'vi,vi' || ing_fenalco_if.transaccion || 'vi,vi' || ing_fenalco_if.transaccion_anulacion || 'vi,vi' || ing_fenalco_if.creation_date || 'vi,vi' || ing_fenalco_if.fecha_contabilizacion || 'vi,vi' || ing_fenalco_if.fecha_anulacion || 'vi,vi' || ing_fenalco_if.cmc || 'vi,vi' || ing_fenalco_if.fecha_doc || 'vi' || E'\n';
				mcad := mcad || cad1 || cad2;
			END IF;
		END LOOP;


	END LOOP;


RETURN mcad;

  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION datoscdiario()
  OWNER TO postgres;
