-- Function: prueba3()

-- DROP FUNCTION prueba3();

CREATE OR REPLACE FUNCTION prueba3()
  RETURNS text AS
$BODY$Declare
  retcod TEXT;
  cod_neg TEXT;
  negocios RECORD;
  negocio RECORD;
begin
	retcod = '''';
	FOR negocios IN SELECT distinct negasoc FROM con.factura where creation_date < '2008-09-01' and (documento like 'PC%' or documento like 'PL%') order by negasoc LOOP
	        cod_neg := negocios.negasoc;
		FOR negocio IN SELECT distinct negasoc, fecha_ultimo_pago FROM con.factura where negasoc = cod_neg and (documento like 'PC%' or documento like 'PL%') order by fecha_ultimo_pago LOOP
		-- Now negocios has one record from con.factura
			IF negocio.fecha_ultimo_pago = '0099-01-01' THEN
				 retcod := retcod || negocio.negasoc ||E'\r\n';
			END IF;
		END LOOP;
	END LOOP;
	RETURN retcod;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION prueba3()
  OWNER TO postgres;
