-- Function: etes.desaprobar_anticipos(text[], character varying)

-- DROP FUNCTION etes.desaprobar_anticipos(text[], character varying);

CREATE OR REPLACE FUNCTION etes.desaprobar_anticipos(anticipos text[], usuario character varying)
  RETURNS boolean AS
$BODY$
DECLARE

retorno boolean:=true;

BEGIN

	FOR i IN 1 .. (array_upper(anticipos, 1))
	LOOP


		RAISE NOTICE 'indice i: % indice j: % transportadora : %',i,1, anticipos[i][1];
		RAISE NOTICE 'indice i: % indice j: % id_manifiesto : %',i,2, anticipos[i][2];
		RAISE NOTICE 'indice i: % indice j: % nombre_agencia : %',i,3, anticipos[i][3];
		RAISE NOTICE 'indice i: % indice j: % conductor : %',i,4, anticipos[i][4];
		RAISE NOTICE 'indice i: % indice j: % propietario : %',i,5, anticipos[i][5];
		RAISE NOTICE 'indice i: % indice j: % placa : %',i,6, anticipos[i][6];
		RAISE NOTICE 'indice i: % indice j: % planilla : %',i,7, anticipos[i][7];
		RAISE NOTICE 'indice i: % indice j: % fecha_anticipo : %',i,8, anticipos[i][8];
		RAISE NOTICE 'indice i: % indice j: % valor_anticipo : %',i,9, anticipos[i][9];
		RAISE NOTICE 'indice i: % indice j: % usuario_creacion : %',i,10, anticipos[i][10];
		RAISE NOTICE 'indice i: % indice j: % descripcion : %',i,11, anticipos[i][11];
		RAISE NOTICE 'indice i: % indice j: % reanticipo : %',i,12, anticipos[i][12];


		/************ ACTUALIZAMOS LOS ANTICIPOS Y REANTICIPOS************/
		IF(anticipos[i][12]='N')THEN

			UPDATE etes.manifiesto_carga
			   SET aprobado='N', fecha_aprobacion='0099-01-01 00:00:00'::timestamp without time zone,
				usuario_aprobacion=''
			 WHERE id=anticipos[i][2];

		ELSE

			UPDATE etes.manifiesto_reanticipos
			   SET aprobado='N',
			       fecha_aprobacion='0099-01-01 00:00:00'::timestamp without time zone,
			       usuario_aprobacion=''
			 WHERE  id=anticipos[i][2];

		END IF;


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
ALTER FUNCTION etes.desaprobar_anticipos(text[], character varying)
  OWNER TO postgres;
