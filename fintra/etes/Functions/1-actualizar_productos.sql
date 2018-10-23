-- Function: etes.actualizar_productos(text[], integer, character varying, integer)

-- DROP FUNCTION etes.actualizar_productos(text[], integer, character varying, integer);

CREATE OR REPLACE FUNCTION etes.actualizar_productos(productos text[], idestacion integer, usuario character varying, idproceso integer)
  RETURNS boolean AS
$BODY$
DECLARE

retorno boolean:=true;

BEGIN

	FOR i IN 1 .. (array_upper(productos, 1))
	LOOP

		RAISE NOTICE 'indice i: % indice j: % codigo_producto : %',i,1, productos[i][1];
		RAISE NOTICE 'indice i: % indice j: % precio : %',i,2, productos[i][2];

		/************ ACTUALIZAMOS LAS LISTA DE PRODUCTOS ************/
		UPDATE etes.configcomerial_productos
		   SET precio_producto= productos[i][2]::numeric,
		       last_update=NOW(),
		       user_update=usuario
		WHERE id_eds=idestacion AND id_producto_es=productos[i][1]::integer;

        END LOOP;

	/************ MARCAMOS LA TRAMA COMO PROCESADA ************/
	/*UPDATE etes.trama_anticipos
	   SET procesado=true,
	       fecha_fin_proceso=now()
	 WHERE id=idproceso;*/

RETURN retorno;

EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
	WHEN  null_value_not_allowed  THEN
		RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.actualizar_productos(text[], integer, character varying, integer)
  OWNER TO postgres;
