-- Function: etes.agregar_novedad(text[], integer, character varying)

-- DROP FUNCTION etes.agregar_novedad(text[], integer, character varying);

CREATE OR REPLACE FUNCTION etes.agregar_novedad(novedad text[], idproceso integer, usuario character varying)
  RETURNS boolean AS
$BODY$
DECLARE

recordAgenciaTransportadora record;
recordNovedad record;
idProserv integer:=0;
recordManifiesto record;
totalVenta numeric:=0;
retorno boolean:=true;

BEGIN

	FOR i IN 1 .. (array_upper(novedad, 1))
	LOOP

		/********** BUSCAMOS EL ID DEL TIPO NOVEDAD *************/
		SELECT INTO recordNovedad n.id as idNovedad,n.id_tipo_novedad,n.cod_novedad,n.descripcion,tn.descripcion as descripcion_novedad  FROM etes.novedades n
		INNER JOIN etes.tipo_novedad tn on (n.id_tipo_novedad=tn.id )
		INNER JOIN etes.productos_servicios_transp pst on (tn.id_proserv= pst.id )
		WHERE n.cod_novedad=novedad[i][5] AND pst.codigo_proserv=novedad[i][3] AND n.id_tipo_novedad=novedad[i][4]::integer;


		/********** BUSCAMOS EL ID AGENCIA y TRANSPORTADORA*************/
		SELECT INTO recordAgenciaTransportadora a.id as idAgencia , t.id as idTransportadora FROM etes.agencias a
		INNER JOIN etes.transportadoras t ON (a.id_transportadora=t.id)
		WHERE a.cod_agencia=novedad[i][2] AND t.cod_transportadora=novedad[i][1]  AND a.reg_status='' AND t.reg_status='' ;


		/********** BUSCAMOS EL ID DEL ANTICIPO NO TRANSFERIDO PADRE EN LA TABLA MANIFIESTOS  *************/
		SELECT INTO recordManifiesto * FROM etes.manifiesto_carga
		WHERE planilla=novedad[i][6] AND id_agencia=recordAgenciaTransportadora.idAgencia and  reg_status='';

		RAISE NOTICE 'recordManifiesto :%', recordManifiesto.id;

		/**************** INSERTAMOS LA NOVEDA *************/
                PERFORM * FROM etes.novedades_manifiesto where id_novedad=recordNovedad.idNovedad AND id_manifiesto_carga=recordManifiesto.id AND cod_novedad=novedad[i][5] ;
			IF(NOT FOUND AND recordManifiesto.id IS NOT NULL) THEN
				RAISE NOTICE 'ENTRO';

				/**************** PREGUNTAMOS SI LA NOVEDAD INSERTADA ES DE ANULACION Y SE ACTULIZA EL MANIFIESTO*************/
				IF(recordNovedad.descripcion='ANULADO')THEN
				  if((select count(0) from etes.manifiesto_carga  where id=recordManifiesto.id AND reg_status='' and cxc_corrida = '')=1)then
					SELECT INTO totalVenta coalesce(sum(total_venta),0)  FROM etes.ventas_eds where id_manifiesto_carga=recordManifiesto.id AND reg_status='';
					IF(totalVenta = 0) THEN
						UPDATE etes.manifiesto_carga
						   SET usuario_anulacion = usuario,
						       fecha_anulacion=now(),
						       reg_status='A'
						WHERE id = recordManifiesto.id AND planilla=novedad[i][6] AND id_agencia=recordAgenciaTransportadora.idAgencia and cxc_corrida = '';

						--Anulamos todos los reanticipos de asociados al padre.
						UPDATE etes.manifiesto_reanticipos
						   SET usuario_anulacion = usuario,
						       fecha_anulacion=now(),
						       reg_status='A'
						 WHERE id_manifiesto_carga=recordManifiesto.id and cxc_corrida = '';


						INSERT INTO etes.novedades_manifiesto(
							id_novedad, id_manifiesto_carga, cod_novedad, descripcion,
							creation_user, creation_date)
						VALUES (recordNovedad.idNovedad, recordManifiesto.id, novedad[i][5],novedad[i][8],
							usuario, now());
					ELSE

						UPDATE etes.trama_anticipos
						   SET observaciones=observaciones||'Planilla '||novedad[i][6]||', no puede ser anulada porque existen ventas relacionadas a este documento.'
						WHERE id=Idproceso;

						retorno :=false;

					END IF;
				   else

					UPDATE etes.trama_anticipos
						   SET observaciones=observaciones||'Planilla '||novedad[i][6]||', no puede ser anulada porque ya fue facturada.'
					WHERE id=Idproceso;

					retorno :=false;

				   end if;
				ELSE

					INSERT INTO etes.novedades_manifiesto(
						id_novedad, id_manifiesto_carga, cod_novedad, descripcion,
						creation_user, creation_date)
					VALUES (recordNovedad.idNovedad, recordManifiesto.id, novedad[i][5],novedad[i][8],
						usuario, now());

				END IF;
			ELSE
				/************* AGREGAMOS LAS PLANILLAS NO PROCESADAS AL EL CAMPO OBSERVACIONES DE LA TRAMA *****************/
				UPDATE etes.trama_anticipos
				   SET observaciones=observaciones||'Planilla no encontrada o anulada: '||novedad[i][6]||', '
				WHERE id=Idproceso;

				retorno :=false;

			END IF;

		/*RAISE NOTICE 'indice i: % indice j: % codigo_empresa  : %',i,1, novedad[i][1];
		RAISE NOTICE 'indice i: % indice j: % codigo_agencia : %',i,2, novedad[i][2];
		RAISE NOTICE 'indice i: % indice j: % codigo_producto : %',i,3, novedad[i][3];
		RAISE NOTICE 'indice i: % indice j: % tipo_novedad : %',i,4, novedad[i][4];
		RAISE NOTICE 'indice i: % indice j: % codigo_novedad : %',i,5, novedad[i][5];
		RAISE NOTICE 'indice i: % indice j: % planilla : %',i,6, novedad[i][6];
		RAISE NOTICE 'indice i: % indice j: % placa : %',i,7, novedad[i][7];
		RAISE NOTICE 'indice i: % indice j: % descripcion : %',i,8, novedad[i][8]; */

        END LOOP;

	/************ MARCAMOS LA TRAMA COMO PROCESADA ************/
	UPDATE etes.trama_anticipos
	   SET procesado=true,
	       fecha_fin_proceso=now()
	 WHERE id=Idproceso;

return retorno;

EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
	WHEN unique_violation THEN
		RAISE EXCEPTION'ERROR INSERTANDO EN LA BD, YA EXISTE LA NOVEDAD EN LA BASE DE DATOS.';
        WHEN  null_value_not_allowed  THEN
		RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.agregar_novedad(text[], integer, character varying)
  OWNER TO postgres;
