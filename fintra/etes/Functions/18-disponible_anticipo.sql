-- Function: etes.disponible_anticipo(character varying, numeric, character varying, character varying, character varying, integer, numeric, character varying)

-- DROP FUNCTION etes.disponible_anticipo(character varying, numeric, character varying, character varying, character varying, integer, numeric, character varying);

CREATE OR REPLACE FUNCTION etes.disponible_anticipo(_num_venta character varying, _valor_venta numeric, _planilla character varying, cedula_conductor character varying, _placa character varying, transportadora integer, valor_planilla numeric, usuario character varying)
  RETURNS numeric AS
$BODY$
DECLARE

disponible NUMERIC:=0;
suma NUMERIC:=0;
sql VARCHAR:='';

BEGIN
		   -- TABLA EMPANADA

		sql='INSERT INTO tem.extracto_propietario_'||usuario||'(num_venta,planilla,cedula,placa,valor_venta)
			VALUES('''||_num_venta||''','''||_planilla||''','''||cedula_conductor||''','''||_placa||''','||_valor_venta||')';

		Execute sql;


               Execute 'SELECT  SUM(valor_venta) FROM tem.extracto_propietario_'||usuario||'
			WHERE planilla='''||_planilla||''' AND cedula='''||cedula_conductor||''' AND placa='''||_placa||''' ' INTO suma;

                disponible:= valor_planilla::NUMERIC - suma::NUMERIC ;
		RAISE NOTICE 'SUMA %',suma;

RETURN disponible;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.disponible_anticipo(character varying, numeric, character varying, character varying, character varying, integer, numeric, character varying)
  OWNER TO postgres;
