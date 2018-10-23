-- Function: apicredit.eg_generar_negocio_credito(integer, character varying, boolean, character varying, character varying, character varying, text[])

-- DROP FUNCTION apicredit.eg_generar_negocio_credito(integer, character varying, boolean, character varying, character varying, character varying, text[]);

CREATE OR REPLACE FUNCTION apicredit.eg_generar_negocio_credito(_numerosolicitud integer, usuario character varying, _financiaval boolean, entidad character varying, _extelectronico character varying, _recfirmas character varying, _array_direcciones text[])
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

BEGIN

     SELECT  into _codNegocio cod_neg FROM solicitud_aval  where numero_solicitud  =_numeroSolicitud;

     IF (_codNegocio is null ) THEN


		/* *****************************************************
		* Se crea el nuevo negocio apartir del liquidador  *****
		*********************************************************/
		IF(entidad='FENALCO_ATL')THEN

		    cod_negocio_nuevo := get_lcod('FENALCO-ATL');

		ELSIF (entidad='FENALCO_BOL') THEN

		    cod_negocio_nuevo := get_lcod('FENALCO_BOL');

		elsif(entidad='MICROCREDITO')THEN

		   cod_negocio_nuevo := get_lcod('NEG_MICROCRED');

		END IF;


		SELECT INTO totalesLiquidacion
			sum(capital) as capital,--valor desembolso
			sum(interes) as interes,
			sum(custodia) as custodia,
			sum(seguro) as seguro,
			sum(remesa) as remesa,
			sum(valor_cuota) as valor_cuota,	--total pagado
			count(0) as numcuota,
			min(fecha) as fecha_pr_cuota,
			sum(valor_aval) as valor_aval
		FROM apicredit.pre_liquidacion_creditos WHERE  numero_solicitud=_numeroSolicitud;


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
				financia_aval
			)
			(
			  SELECT
				 p.identificacion as cod_cli,
				 totalesLiquidacion.capital as valor_negocio,
				 totalesLiquidacion.numcuota as nro_docs,
				 totalesLiquidacion.capital as vr_desembolso,
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
				 case when _financiaval=false then
					(totalesLiquidacion.valor_cuota+totalesLiquidacion.valor_aval)
				      else totalesLiquidacion.valor_cuota end as total_pagado,
				 cod_negocio_nuevo as cod_neg,
				 case when _financiaval=false then totalesLiquidacion.valor_aval else 0.00 end as valor_aval,
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
				 _financiaval as financia_aval
			  FROM solicitud_aval sa
			  inner join (select numero_solicitud,					     tipo, 					     identificacion,					     nombre 			     from solicitud_persona 			     group by numero_solicitud, 			     tipo, 			     identificacion,nombre) p on (sa.numero_solicitud =p.numero_solicitud)
			  where sa.numero_solicitud =_numeroSolicitud and p.tipo='S'
			);


		/* *************************************
		 * Insert documentos_neg_aceptado  *****
		 **************************************/

		INSERT INTO documentos_neg_aceptado(
			      cod_neg, item, fecha, dias, saldo_inicial, capital, interes,valor, saldo_final, creation_date,seguro,custodia, remesa,cuota_manejo)
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
				cuota_manejo
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

		 /* ************************************
		  * Actualizar el formulario   *********
		  **************************************/

		UPDATE solicitud_aval SET
			user_update=usuario,
			last_update=now(),
			cod_neg=cod_negocio_nuevo,
			estado_sol='P',
			id_convenio=recordConvenio.id_convenio
		WHERE numero_solicitud = _numeroSolicitud;

		UPDATE apicredit.pre_solicitudes_creditos SET etapa=3 ,extracto_electronico=_extelectronico , recoge_firmas=_recfirmas
		where numero_solicitud=_numeroSolicitud;


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


		/* **********************************************************
		* Validamos si financia para crear el negocio de aval       *
		************************************************************/

		if(_financiaval=true)then

			raise notice 'inicio financia aval....................';

			_afiliado:=(SELECT afiliado FROM apicredit.pre_solicitudes_creditos  Where numero_solicitud=_numeroSolicitud and reg_status='' and estado_sol='P');

			--REALIZAMOS LA LIQUIDACION DEL VALOR DEL AVAL
			INSERT INTO apicredit.pre_liquidacion_creditos_aval(
			    dstrct, numero_solicitud, fecha, dias, cuota, saldo_inicial,
			    capital, interes, custodia, seguro, remesa, valor_cuota, saldo_final,
			    valor_aval,cuota_manejo, creation_user, creation_date)
			 SELECT
			    'FINV'::varchar as dstrct,
			    _numeroSolicitud as numero_solicitud ,
			    retorno_liq.fecha ::date,
			    retorno_liq.dias,
			    retorno_liq.item,
			    retorno_liq.saldo_inicial,
			    retorno_liq.capital,
			    retorno_liq.interes,
			    retorno_liq.custodia,
			    retorno_liq.seguro,
			    retorno_liq.remesa,
			    retorno_liq.valor as valor_cuota,
			    retorno_liq.saldo_final,
			    0.00::numeric as no_aval,
			    0.00::numeric as cuota_manejo,
			    usuario,
			    NOW()
			    FROM eg_liquidador_api_aval(totalesLiquidacion.valor_aval::numeric,
							  totalesLiquidacion.numcuota::integer,
							  totalesLiquidacion.fecha_pr_cuota::date,
							  recordConvenio.id_convenio::integer,
							  _afiliado::varchar) as retorno_liq;


			IF(entidad='FENALCO_ATL')THEN
			 negocio_aval := get_lcod('FENALCO-ATL');
			ELSIF (entidad='FENALCO_BOL') THEN
			 negocio_aval := get_lcod('FENALCO_BOL');
			END IF;


			SELECT INTO totalesLiquidacion_aval
				sum(capital) as capital,--valor desembolso
				sum(interes) as interes,
				sum(custodia) as custodia,
				sum(seguro) as seguro,
				sum(remesa) as remesa,
				sum(valor_cuota) as valor_cuota,	--total pagado
				count(0) as numcuota,
				min(fecha) as fecha_pr_cuota,
				sum(valor_aval) as valor_aval
			FROM apicredit.pre_liquidacion_creditos_aval WHERE  numero_solicitud=_numeroSolicitud;


			--CREAMOS EL NEGOCIO DE AVAL.

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
				financia_aval
			)
			(
			  SELECT
				cod_cli,
				totalesLiquidacion_aval.capital,
				nro_docs,
				totalesLiquidacion_aval.capital,
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
				(SELECT nit_anombre FROM convenios where id_convenio=n.id_convenio) as nit_tercero,
				totalesLiquidacion_aval.valor_cuota as tot_pagado,
				negocio_aval,
				0::numeric as valor_aval,
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
				cod_negocio_nuevo as negocio_rel,
				false
			  FROM negocios n
			  where cod_neg=cod_negocio_nuevo
			);

			--CLONAMOS LA SOLICITUD DE AVAL
			clonar:=apicredit.eg_clonar_solicitud_aval(_numeroSolicitud,totalesLiquidacion.valor_aval, negocio_aval,usuario);


			/* ************************************
			* Insert documentos_neg_aceptado  *****
			**************************************/

			INSERT INTO documentos_neg_aceptado(
			      cod_neg, item, fecha, dias, saldo_inicial, capital, interes,valor, saldo_final, creation_date,seguro,custodia, remesa)
			(
			 SELECT
				negocio_aval,
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
				remesa
			 FROM apicredit.pre_liquidacion_creditos_aval where numero_solicitud=_numeroSolicitud
			);




			raise notice 'fin financia aval....';

		end if;
	ELSE
		retorno:='false';
		if(_codNegocio is not null)then
		    cod_negocio_nuevo:=_codNegocio;
		else
		    cod_negocio_nuevo:='';
		end if;

	       raise notice 'entra...1111 %',retorno;
	END IF;


	return retorno ||';' || _numeroSolicitud ||';'||cod_negocio_nuevo ;

EXCEPTION
	WHEN function_executed_no_return_statement THEN
		RAISE EXCEPTION 'Se ha superado el maximo de caracteres permitidos.';
		retorno='FAIL' ;
		return retorno;

	WHEN unique_violation THEN
		RAISE EXCEPTION 'Error Insertando en la bd, ya existe en la base de datos.';
		retorno='FAIL' ;
		return retorno;


END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_generar_negocio_credito(integer, character varying, boolean, character varying, character varying, character varying, text[])
  OWNER TO postgres;
