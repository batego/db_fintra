-- Function: etes.validar_legalizacion_anticipo(integer)

-- DROP FUNCTION etes.validar_legalizacion_anticipo(integer);

CREATE OR REPLACE FUNCTION etes.validar_legalizacion_anticipo(idmanifiesto integer)
  RETURNS text AS
$BODY$

DECLARE

 recordInfoVentas record;
 numVenta text:='NRO VENTA: ';
 nomEds text:='NOMBRE EDS: ';
 totalVenta numeric:=0;
 retorno text:='';

BEGIN

	FOR recordInfoVentas IN (SELECT num_venta,nombre_eds,sum(total_venta) as total_venta
				FROM etes.ventas_eds ventas
				INNER JOIN etes.estacion_servicio es on (es.id=ventas.id_eds)
				where id_manifiesto_carga = idManifiesto group by num_venta, nombre_eds)
	LOOP

		numVenta:=numVenta||''||recordInfoVentas.num_venta||', ';
		nomEds:=nomEds||''||recordInfoVentas.nombre_eds||', ';
		totalVenta:=totalVenta+recordInfoVentas.total_venta;

	END LOOP;

	IF (recordInfoVentas IS NOT NULL)THEN
	  retorno:=numVenta||nomEds||'Total Venta: '||totalVenta;
	END IF;

        RETURN retorno;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.validar_legalizacion_anticipo(integer)
  OWNER TO postgres;
