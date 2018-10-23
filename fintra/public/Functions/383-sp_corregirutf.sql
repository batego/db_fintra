-- Function: sp_corregirutf(character varying)

-- DROP FUNCTION sp_corregirutf(character varying);

CREATE OR REPLACE FUNCTION sp_corregirutf(sarta character varying)
  RETURNS text AS
$BODY$

DECLARE

	Respuesta varchar := Sarta;
	Arreglo text[] := '{{Ã¡,á},{Ã©,é},{Ã*,í},{Ã³,ó},{Ãº,ú},{Ã,Á},{Ã‰,É},{Ã,Í},{Ã“,Ó},{Ãš,Ú}}';

BEGIN

	raise notice 'Es: %', (array_upper(Arreglo, 1));
	FOR i IN 1 .. (array_upper(Arreglo, 1)) LOOP
		RAISE NOTICE 'indice i: % indice j: % clasificacion : %',i,1, Arreglo[i][1];
		RAISE NOTICE 'indice i: % indice j: % clasificacion : %',i,2, Arreglo[i][2];
	END LOOP;

	RETURN Respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_corregirutf(character varying)
  OWNER TO postgres;
