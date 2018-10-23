-- Function: tem.concatenarme()

-- DROP FUNCTION tem.concatenarme();

CREATE OR REPLACE FUNCTION tem.concatenarme()
  RETURNS text AS
$BODY$
  DECLARE
    mcad TEXT;
    --fila_items tem.ias_hys%ROWTYPE;
    fila_items tem.ias_hys;
  BEGIN
    mcad ='';
    --DROP TABLE tem.items_hys;
    --CREATE TABLE tem.items_hys (id numeric(11) NOT NULL, descripcion varchar(100));

    FOR fila_items IN SELECT * FROM tem.ias_hys WHERE ciclo_fecha = '2012-12-07' LOOP
	   mcad := mcad || fila_items.documento || ',';
    END LOOP;

  RETURN mcad;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.concatenarme()
  OWNER TO postgres;
