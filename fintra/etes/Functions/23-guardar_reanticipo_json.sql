-- Function: etes.guardar_reanticipo_json(text[], integer, character varying)

-- DROP FUNCTION etes.guardar_reanticipo_json(text[], integer, character varying);

CREATE OR REPLACE FUNCTION etes.guardar_reanticipo_json(reanticipos text[], idproceso integer, usuario character varying)
  RETURNS boolean AS
$BODY$
DECLARE
retorno boolean:=true;
recordManifiesto record;
recordAgenciaTransportadora record;
id_tabla integer:=0;
descuentos text:='';
_planilla text :='';
secuencia integer:=0;

BEGIN

	/****************************************************************************************/
	/*************************       PROCESAMOS EL ARRAY DEL REANTICIPO	    *************/
	/****************************************************************************************/
	FOR i IN 1 .. (array_upper(reanticipos, 1))
	LOOP

		RAISE NOTICE '1.0 INSERTAMOS EL REANTICIPO';

		/********** BUSCAMOS EL ID AGENCIA y TRANSPORTADORA*************/
		SELECT INTO recordAgenciaTransportadora a.id as idAgencia , t.id as idTransportadora FROM etes.agencias a
		INNER JOIN etes.transportadoras t ON (a.id_transportadora=t.id)
		WHERE a.cod_agencia=reanticipos[i][2] AND t.cod_transportadora=reanticipos[i][1]  AND a.reg_status='' AND t.reg_status='' ;

		/********** BUSCAMOS EL ID DEL ANTICIPO PADRE EN LA TABLA MANIFIESTOS *************/
                SELECT INTO recordManifiesto * FROM etes.manifiesto_carga
                WHERE planilla=reanticipos[i][3] AND id_agencia=recordAgenciaTransportadora.idAgencia and  reg_status='' ;

		SELECT INTO secuencia (coalesce(max(secuencia_reanticipo),0) + 1) as secu from etes.manifiesto_reanticipos where id_manifiesto_carga=recordManifiesto.id ;
		_planilla := recordManifiesto.planilla||'_'||secuencia;
		RAISE NOTICE 'RECORD NULO : %', recordManifiesto;
		IF(recordManifiesto IS NOT NULL)THEN
			INSERT INTO etes.manifiesto_reanticipos(
				    id_manifiesto_carga, fecha_reanticipo,fecha_envio_fintra,origen,planilla,secuencia_reanticipo,destino, valor_reanticipo,
				    valor_descuentos_fintra,porc_comision_intermediario, valor_comision_intermediario, valor_desembolsar,
				    creation_date, creation_user, last_update, user_update,
				    banco,sucursal,cedula_titular_cuenta,nombre_titular_cuenta,
				    tipo_cuenta,no_cuenta)
			    VALUES (recordManifiesto.id,reanticipos[i][4]::timestamp without time zone,reanticipos[i][16]::timestamp without time zone ,reanticipos[i][5],_planilla,secuencia,reanticipos[i][6], reanticipos[i][7]::numeric,
				    0.0,reanticipos[i][8]::numeric, reanticipos[i][9]::numeric, 0.0,
				    now(),usuario,'0099-01-01 00:00:00'::timestamp without time zone,'',
				    reanticipos[i][10],reanticipos[i][11],reanticipos[i][12],reanticipos[i][13],
				    reanticipos[i][14],reanticipos[i][15])
				    RETURNING id INTO id_tabla ;

			 /********** CALCULAMOS LOS DESCUENTOS DEL REANTICIPO ***************/

			RAISE NOTICE 'id_tabla: %',id_tabla;
			SELECT INTO descuentos etes.sp_descuentosfintra(id_tabla,'R');
			RAISE NOTICE 'descuentos: %',descuentos;

			/************ ACTUALIZAMOS EL MANIFIESTO DE CARGA*******************/

			UPDATE etes.manifiesto_carga
			   SET last_update=NOW(),
                               user_update=usuario,
			       reanticipo='S'
			 WHERE id=recordManifiesto.id;

			/************ ACTUALIZAMOS LA INFORMACION DE LA CUENTA DEL CONDUCTOR*********/
			UPDATE etes.conductor
			   SET  banco=reanticipos[i][10],
			        sucursal=reanticipos[i][11],
			        cedula_titular_cuenta=reanticipos[i][12],
			        nombre_titular_cuenta=reanticipos[i][13],
			        tipo_cuenta=reanticipos[i][14],
			        no_cuenta=reanticipos[i][15],
			        last_update=now(),
			        user_update=usuario
			 WHERE id=(SELECT id_conductor FROM etes.manifiesto_carga  WHERE  id = recordManifiesto.id AND reg_status !='A');


		ELSE
                        /************* AGREGAMOS LAS PLANILLAS NO PROCESADAS AL EL CAMPO OBSERVACIONES DE LA TRAMA *****************/
			UPDATE etes.trama_anticipos
			   SET
			       observaciones=observaciones||'Planilla: '||reanticipos[i][3]||', '
			WHERE id=Idproceso;


		END IF;

			RAISE NOTICE 'indice i: % indice j: % codigo_empresa : %',i,1, reanticipos[i][1];
			RAISE NOTICE 'indice i: % indice j: % codigo_agencia : %',i,2, reanticipos[i][2];
			RAISE NOTICE 'indice i: % indice j: % planilla : %',i,3, reanticipos[i][3];
			RAISE NOTICE 'indice i: % indice j: % fecha_reanticipo : %',i,4, reanticipos[i][4];
			RAISE NOTICE 'indice i: % indice j: % origen : %',i,5, reanticipos[i][5];
			RAISE NOTICE 'indice i: % indice j: % destino : %',i,6, reanticipos[i][6];
			RAISE NOTICE 'indice i: % indice j: % valor_reanticipo : %',i,7, reanticipos[i][7];
			RAISE NOTICE 'indice i: % indice j: % porc_comision_intermediario : %',i,8, reanticipos[i][8];
			RAISE NOTICE 'indice i: % indice j: % valor_comision_intermediario : %',i,9, reanticipos[i][9];
			RAISE NOTICE 'indice i: % indice j: % banco : %',i,10, reanticipos[i][10];
			RAISE NOTICE 'indice i: % indice j: % sucursal : %',i,11, reanticipos[i][11];
			RAISE NOTICE 'indice i: % indice j: % cedula_titular_cuenta : %',i,12, reanticipos[i][12];
			RAISE NOTICE 'indice i: % indice j: % nombre_titular_cuenta : %',i,13, reanticipos[i][13];
			RAISE NOTICE 'indice i: % indice j: % tipo_cuenta : %',i,14, reanticipos[i][14];
                        RAISE NOTICE 'indice i: % indice j: % no_cuenta : %',i,15, reanticipos[i][15];
			RAISE NOTICE 'indice i: % indice j: % fecha_envio_fintra : %',i,16, reanticipos[i][16];



	END LOOP;

		/************ MARCAMOS LA TRAMA COMO PROCESADA ************/
		UPDATE etes.trama_anticipos
		   SET procesado=true,
		       fecha_fin_proceso=now()
		 WHERE id=Idproceso;


 RETURN retorno;
EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
		retorno:=false ;
		return retorno;
	WHEN unique_violation THEN
		RAISE EXCEPTION'ERROR INSERTANDO EN LA BD, YA EXISTE EL MANIFIESTO DE CARGA EN LA BASE DE DATOS.';
		retorno:=false ;
		return retorno;
        WHEN  null_value_not_allowed  THEN
		RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';
		retorno:=false ;
		return retorno;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.guardar_reanticipo_json(text[], integer, character varying)
  OWNER TO postgres;
