-- Function: mc_prueba(integer[])

-- DROP FUNCTION mc_prueba(integer[]);

CREATE OR REPLACE FUNCTION mc_prueba(valores integer[])
  RETURNS text AS
$BODY$

DECLARE
resultado text;
m varchar[];
arr varchar[][] := array[['valor1','123'],['valor2','456']];
------------------------------------------------------------------
a integer[] =valores;-- array[4,2,3];
arr_prueba_add integer [];
i integer;
BEGIN
	/*
	for m in 
		select arr  
	LOOP
		raise NOTICE '%',m;
	END LOOP;
*/
	/** 
	el 1.. es desde que posicion
	array_upper : Devuelve el límite superior de la dimensión del array solicitado
	**/
	for i in 1..15
		--array_upper(a, 1)
	loop 
		--array_prepend adiciona informacion aun arra creado
		arr_prueba_add = ARRAY[1,2,3] || ARRAY[4,5,6];--array_prepend(i, arr_prueba_add);
		
	end loop;

	raise notice 'arr_prueba_add % ',arr_prueba_add;

resultado:= 'hola';
return resultado;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_prueba(integer[])
  OWNER TO postgres;

