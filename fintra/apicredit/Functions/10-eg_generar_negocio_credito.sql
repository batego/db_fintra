-- Function: apicredit.eg_generar_negocio_credito(integer, integer, character varying, boolean, character varying, character varying, character varying, text[])

-- DROP FUNCTION apicredit.eg_generar_negocio_credito(integer, integer, character varying, boolean, character varying, character varying, character varying, text[]);

CREATE OR REPLACE FUNCTION apicredit.eg_generar_negocio_credito(_uni_negocio integer, _numerosolicitud integer, usuario character varying, _financiaval boolean, entidad character varying, _extelectronico character varying, _recfirmas character varying, _array_direcciones text[])
  RETURNS text AS
$BODY$
DECLARE

 recordConvenio record;
 totalesLiquidacion record;
 totalesLiquidacion_aval record;
 negocio_aval varchar:='';
 cod_negocio_nuevo TEXT :='';
 clonar text:='';
 retorno TEXT :='true';
 _codNegocio varchar:='';
 _afiliado varchar:='';
 _aprobado_score varchar:='';
 _numAprobacionAval varchar;

BEGIN

    SELECT  into _codNegocio cod_neg FROM solicitud_aval  where numero_solicitud  =_numeroSolicitud;
    --raise notice '_codNegocio: %',_codNegocio;

    IF (_codNegocio is null or _codNegocio='' ) THEN


		/* *****************************************************
		* Se crea el nuevo negocio apartir del liquidador  *****
		*********************************************************/
		IF(_uni_negocio=30)THEN  --cambiar por el de productiv0
		    cod_negocio_nuevo := GET_LCOD('CONSUMO FINTRA');
		ELSIF(_uni_negocio=31)THEN
		   cod_negocio_nuevo := GET_LCOD('EDU FINTRA');
		END IF;

		raise notice 'cod_negocio_nuevo: %',cod_negocio_nuevo;
		SELECT INTO totalesLiquidacion
			sum(capital) as capital,--valor desembolso
			sum(interes) as interes,
			sum(custodia) as custodia,
			sum(seguro) as seguro,
			sum(remesa) as remesa,
			sum(valor_cuota) as valor_cuota,	--total pagado
			count(0) as numcuota,
			min(fecha) as fecha_pr_cuota,
			valor_aval
		FROM apicredit.pre_liquidacion_creditos
		WHERE  numero_solicitud=_numeroSolicitud
		GROUP BY valor_aval ;


		SELECT INTO recordConvenio tasa_interes,
			porcentaje_cat,
			valor_capacitacion,
			valor_seguro,
			valor_central,
			cat,
			impuesto,
			id_convenio,
			case when redescuento =true then 'PCR' else 'PSR' end as _tipoproceso
		FROM convenios
		WHERE id_convenio=(SELECT id_convenio FROM apicredit.pre_solicitudes_creditos  Where numero_solicitud=_numeroSolicitud and reg_status='' and estado_sol='P');
		RAISE NOTICE 'Cod neg nuevo %',cod_negocio_nuevo;

		 /* ********************************
		  * Insert negocio principal  *****
		  **********************************/

		INSERT INTO negocios
			(
				cod_cli,
				vr_negocio,
				nro_docs,
				vr_desembolso,
				vr_aval,
				vr_custodia,
				mod_aval,
				mod_custodia,
				porc_remesa,
				mod_remesa,
				create_user,
				fpago,
				tneg,
				cod_tabla,
				dist,
				esta,
				fecha_negocio,
				nit_tercero,
				tot_pagado,
				cod_neg,
				valor_aval,
				valor_remesa,
				tasa,
				cnd_aval,
				id_convenio,
				id_remesa,
				banco_cheque,
				cod_sector,
				cod_subsector,
				estado_neg,
				tipo_proceso,
				actividad,
				negocio_rel,
				financia_aval,
				valor_fianza  --esto es igual al valor del aval se pone en los dos por si a futuro lo utilizamos
			)
			(
			  SELECT
				 p.identificacion as cod_cli,
				 (totalesLiquidacion.capital-totalesLiquidacion.valor_aval) as valor_negocio,
				 totalesLiquidacion.numcuota as nro_docs,
				 (totalesLiquidacion.capital-totalesLiquidacion.valor_aval) as vr_desembolso,
				 0.00 as vr_aval,
				 totalesLiquidacion.custodia as vr_custodia,
				 0::integer as mod_aval,
				 ''::varchar as mod_custodia,
				 0::integer as porc_remesa,
				 1::integer as mod_remesa,
				 usuario as creation_user,
				 '30'::varchar as fpago,
				 sa.tipo_negocio,
				 0::integer as cod_tabla,
				 sa.dstrct,
				 ''::varchar as esta,
				 now()::date as fecha_negocio,
				 sa.afiliado as nit_tercero,
				 totalesLiquidacion.valor_cuota as total_pagado,
				 cod_negocio_nuevo as cod_neg,
				 totalesLiquidacion.valor_aval as valor_aval,
				 totalesLiquidacion.remesa,
				 recordConvenio.tasa_interes,
				 ''::varchar as cnd_aval,
				 recordConvenio.id_convenio,
				 null as id_remesa,
				 ''::varchar AS banco_cheque,
				 sa.cod_sector,
				 sa.cod_subsector,
				 sa.estado_sol as estado_neg,
				 recordConvenio._tipoproceso,
				 'RAD'::varchar AS actividad,
				 ''::varchar as negocio_rel,
				 _financiaval as financia_aval,
				 totalesLiquidacion.valor_aval as valor_fianza
			  FROM solicitud_aval sa
			  inner join (select numero_solicitud,
					     tipo,
					     identificacion,
					     nombre
				     from solicitud_persona
				     group by numero_solicitud,
				     tipo,
				     identificacion,nombre) p on (sa.numero_solicitud =p.numero_solicitud)
			  where sa.numero_solicitud =_numeroSolicitud and p.tipo='S'
			);



		/* *************************************
		 * Insert documentos_neg_aceptado  *****
		 **************************************/

		INSERT INTO documentos_neg_aceptado(
			      cod_neg, item, fecha, dias, saldo_inicial, capital, interes,valor, saldo_final, creation_date,seguro,custodia, remesa,cuota_manejo,valor_aval)
			(
			 SELECT
				cod_negocio_nuevo,
				cuota ,
				fecha,
				dias,
				saldo_inicial,
				capital,
				interes,
				valor_cuota,
				saldo_final,
				now(),
				seguro,
				custodia,
				remesa,
				cuota_manejo,
				valor_aval
			 FROM apicredit.pre_liquidacion_creditos WHERE numero_solicitud =_numeroSolicitud
			);


		 /* ********************************************
		  * Documentos del formulario principal    *****
		  *********************************************/

		INSERT INTO solicitud_documentos(
			    numero_solicitud, num_titulo,valor, fecha,liquidacion,creation_user,creation_date,last_update)

		       (
			 SELECT
				_numeroSolicitud,
				cuota ,
				valor_cuota,
				fecha,
				1,
				usuario,
				now(),
				now()
			FROM apicredit.pre_liquidacion_creditos WHERE numero_solicitud =_numeroSolicitud

		       );

		 /* **********************************************************
		  * ACTUALIZAR EL FORMULARIO DEPENDIENDO DEL QUANTO  *********
		  ***********************************************************/
		_aprobado_score:=(select aprobado_score from solicitud_aval  where numero_solicitud=_numerosolicitud and estado_sol='P');
		IF(_aprobado_score in ('V','R')  AND _uni_negocio=31)THEN --Validacion para aprobar en un minuto

			_numAprobacionAval:=get_lcod('NUMERO_AVAL');

			--1.)Actualizamos el negocio y se deja en estado aprobado.
		        UPDATE negocios SET
				estado_neg=_aprobado_score,
				actividad=(CASE WHEN _aprobado_score='R' THEN 'SOL' ELSE 'DEC' END),
				num_aval=(CASE WHEN  _aprobado_score='R' THEN '' ELSE _numAprobacionAval END),
				aprobado_por='APICREDIT',
				aval_manual='S'
			WHERE cod_neg=cod_negocio_nuevo;

			--2.)Actualizamos la presolicitud de credito.
			UPDATE apicredit.pre_solicitudes_creditos
			     SET etapa=6 ,extracto_electronico=_extelectronico , recoge_firmas=_recfirmas
			where numero_solicitud=_numeroSolicitud;

			--3.)Actualizamos solicitud aval y creamos el cliente.
			UPDATE solicitud_aval SET
				user_update=usuario,
				last_update=now(),
				cod_neg=cod_negocio_nuevo,
				estado_sol=_aprobado_score,
				id_convenio=recordConvenio.id_convenio,
				numero_aprobacion=(CASE WHEN  _aprobado_score='R' THEN '' ELSE _numAprobacionAval END) ,
				agente='APICREDIT'
			WHERE numero_solicitud = _numeroSolicitud;

		ELSE

			UPDATE solicitud_aval SET
				user_update=usuario,
				last_update=now(),
				cod_neg=cod_negocio_nuevo,
				estado_sol='P',
				id_convenio=recordConvenio.id_convenio
			WHERE numero_solicitud = _numeroSolicitud;

			UPDATE apicredit.pre_solicitudes_creditos SET etapa=3 ,extracto_electronico=_extelectronico , recoge_firmas=_recfirmas
			where numero_solicitud=_numeroSolicitud;
		END IF;


		 /* ********************************************************
		  * GUARDAMOS LAS DIRECCIONES DE CORRESPONDENCIA   *********
		  ***********************************************************/
		IF(array_upper(_array_direcciones, 1)> 0)THEN
			FOR i IN 1 .. (array_upper(_array_direcciones, 1)) LOOP

				INSERT INTO apicredit.direcciones_correspondencia(
					    dstrct, numero_solicitud, nombre_direccion, direccion, barrio,
					    departamento, ciudad, complemento, creation_user, creation_date)
				    VALUES ('FINV', _numeroSolicitud,'Direccion '||i, _array_direcciones[i][1],_array_direcciones[i][2],
					    _array_direcciones[i][3], _array_direcciones[i][4], _array_direcciones[i][5], usuario, now());

				RAISE NOTICE 'indice i: % indice j: % direccion : %',i,1, _array_direcciones[i][1];
				RAISE NOTICE 'indice i: % indice j: % barrio : %',i,2, _array_direcciones[i][2];
				RAISE NOTICE 'indice i: % indice j: % departamento : %',i,3, _array_direcciones[i][3];
				RAISE NOTICE 'indice i: % indice j: % ciudad : %',i,4, _array_direcciones[i][4];
				RAISE NOTICE 'indice i: % indice j: % complemento : %',i,5, _array_direcciones[i][5];
			END LOOP;
		END IF;


	ELSE
		retorno:='false';
		if(_codNegocio is not null)then
		    cod_negocio_nuevo:=_codNegocio;
		else
		    cod_negocio_nuevo:='';
		end if;

	       raise notice 'entra...1111 %',retorno;
	END IF;

	return	retorno||';{"numero_solicitud":"'||_numeroSolicitud||'","negocio":"'||cod_negocio_nuevo||'"}';


-- EXCEPTION
-- 	WHEN function_executed_no_return_statement THEN
-- 		RAISE EXCEPTION 'Se ha superado el maximo de caracteres permitidos.';
-- 		retorno='FAIL' ;
-- 		return retorno;
--
-- 	WHEN unique_violation THEN
-- 		RAISE EXCEPTION 'Error Insertando en la bd, ya existe en la base de datos.';
-- 		retorno='FAIL' ;
-- 		return retorno;


END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_generar_negocio_credito(integer, integer, character varying, boolean, character varying, character varying, character varying, text[])
  OWNER TO postgres;
