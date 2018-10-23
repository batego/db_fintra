-- Function: etes.anular_anticipos_transferencia(text[], character varying)

-- DROP FUNCTION etes.anular_anticipos_transferencia(text[], character varying);

CREATE OR REPLACE FUNCTION etes.anular_anticipos_transferencia(anticipos text[], usuario character varying)
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
			   SET usuario_anulacion = usuario,
			       fecha_anulacion=now(),
			       reg_status='A'
			WHERE id = anticipos[i][2]::integer AND planilla=anticipos[i][7];

			INSERT INTO etes.novedades_manifiesto(
				id_novedad, id_manifiesto_carga, cod_novedad, descripcion,
				creation_user, creation_date)
			VALUES ((select id from etes.novedades where id_tipo_novedad=1 and cod_novedad='03'),
			        anticipos[i][2]::integer, '03','SE ANULA ANTICIPO TRANSFERENCIA',
				usuario, now());

		ELSE

			UPDATE etes.manifiesto_reanticipos
			   SET reg_status='A',
			       last_update=now(),
			       user_update=usuario
			WHERE id=anticipos[i][2]::integer;


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
ALTER FUNCTION etes.anular_anticipos_transferencia(text[], character varying)
  OWNER TO postgres;
