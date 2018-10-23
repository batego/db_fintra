-- Function: eg_generar_negocio_compra_cartera(character varying)

-- DROP FUNCTION eg_generar_negocio_compra_cartera(character varying);

CREATE OR REPLACE FUNCTION eg_generar_negocio_compra_cartera(usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

 recordCarteraSolicitud record;
 recordSolicitud record;
 numeroSolicitud NUMERIC:=1;
 cod_negocio_nuevo TEXT :='';
 retorno TEXT :='FAIL';


BEGIN

	FOR recordCarteraSolicitud in (SELECT * from administrativo.solicitud_aval_cc where procesado='N')
	loop

		/* **********************************************************
		 * Creamos el nuevo formulario a partir de la carga inicial *
		 ************************************************************/

	        numeroSolicitud := get_lcod('SOLICITUD_AVAL');

	        --1.)Insertamos la solicitud aval..
	        INSERT INTO solicitud_aval
		(
			reg_status, dstrct, numero_solicitud, fecha_consulta, valor_solicitado,
			estado_sol, tipo_persona, valor_aprobado, tipo_negocio,afiliado, cod_neg,
			id_convenio, producto, valor_producto, cod_sector, cod_subsector,
			plazo, plazo_pr_cuota, fecha_primera_cuota, creation_date,
			creation_user, last_update, user_update
		)
		(
		SELECT
			reg_status, dstrct, numeroSolicitud, fecha_consulta, valor_solicitado,
			estado_sol, tipo_persona, valor_aprobado, tipo_negocio,afiliado,cod_neg,
			id_convenio , producto, valor_producto, cod_sector, cod_subsector,
			((plazo::numeric)::int )::text,((plazo_pr_cuota::numeric)::int )::text , fecha_primera_cuota, creation_date,
			usuario, last_update, user_update
		FROM administrativo.solicitud_aval_cc
		where (numero_solicitud::numeric)::int = (recordCarteraSolicitud.numero_solicitud::numeric)::int  AND procesado='N'
		);

		raise notice 'solicitud_aval_cc';
		--2.)Insertamos la solicitud persona

		INSERT INTO solicitud_persona
		(
			reg_status, dstrct, numero_solicitud, tipo_persona, tipo,
			codcli, primer_apellido, segundo_apellido, primer_nombre, segundo_nombre,
			nombre, ciudad, genero, estado_civil, direccion, departamento,
			barrio, identificacion, tipo_id, fecha_expedicion_id, ciudad_expedicion_id,
			dpto_expedicion_id, fecha_nacimiento, ciudad_nacimiento, dpto_nacimiento,
			nivel_estudio, profesion, telefono, celular, creation_date, creation_user,
			last_update, user_update
		)
		(
		SELECT
			reg_status, dstrct, numeroSolicitud, tipo_persona, tipo,
			codcli, primer_apellido, segundo_apellido, primer_nombre, segundo_nombre,
			nombre, ciudad, genero, estado_civil, direccion, departamento,
			barrio,((identificacion::numeric)::bigint)::text, tipo_id, fecha_expedicion_id, ciudad_expedicion_id,
			dpto_expedicion_id, fecha_nacimiento, ciudad_nacimiento, dpto_nacimiento,
			nivel_estudio, profesion, telefono, celular, creation_date, usuario,
			last_update, user_update
		FROM administrativo.solicitud_persona_cc
		where (numero_solicitud::numeric)::int = (recordCarteraSolicitud.numero_solicitud::numeric)::int  AND procesado='N'
		);

		raise notice 'solicitud_persona_cc';
		--3.)Insertamos al infromacion del estudiante..
		INSERT INTO solicitud_estudiante
		(
			reg_status, dstrct, numero_solicitud, parentesco_girador,
			universidad, programa, fecha_ingreso_programa, codigo, semestre,
			valor_semestre, tipo_carrera, trabaja, nombre_empresa, creation_date,
			creation_user, last_update, user_update
		)
		(
		SELECT
			reg_status, dstrct,numeroSolicitud, parentesco_girador,
			universidad, programa, fecha_ingreso_programa, codigo,(semestre::numeric)::int ,
			valor_semestre, tipo_carrera, trabaja, nombre_empresa, creation_date,
			usuario,last_update, user_update
		FROM administrativo.solicitud_estudiante_cc
		WHERE  (numero_solicitud::numeric)::int = (recordCarteraSolicitud.numero_solicitud::numeric)::int  AND procesado='N'
		);

		raise notice 'solicitud_estudiante_cc %',numeroSolicitud;
		/* ****************************
		 * Fin nuevo formulario.      *
		 ******************************/

		/* *****************************
		* Se crea el nuevo negocio  ****
		********************************/

		select into recordSolicitud * from administrativo.solicitud_persona_cc
		where tipo='S' AND  (numero_solicitud::numeric)::int =(recordCarteraSolicitud.numero_solicitud::numeric)::int  AND procesado='N' ;

		cod_negocio_nuevo := get_lcod('COMPRA_CARTERA');

		INSERT INTO negocios
				(       cod_cli,vr_negocio,nro_docs,vr_desembolso,vr_aval,
					vr_custodia,mod_aval,  mod_custodia, porc_remesa, mod_remesa,
					create_user,fpago,tneg, cod_tabla, dist,
					esta,fecha_negocio, nit_tercero,tot_pagado,--se calcula con la liquidacion sum(valor_cuota)
					cod_neg, valor_aval, valor_remesa, tasa, cnd_aval, id_convenio,
					cod_sector, cod_subsector, estado_neg, tipo_proceso, actividad,
					negocio_rel,financia_aval,num_ciclo,creation_date
				)
			values (
				((recordSolicitud.identificacion::numeric)::bigint)::text,
				recordCarteraSolicitud.valor_solicitado,
				((recordCarteraSolicitud.plazo::numeric)::bigint)::text,
				recordCarteraSolicitud.valor_solicitado,
				0.0,0.0,1,1,0.00000,1,
				usuario,
				((recordCarteraSolicitud.plazo_pr_cuota::numeric)::bigint)::text,
				recordCarteraSolicitud.tipo_negocio,
				0,
				recordCarteraSolicitud.dstrct,
				1,
				recordCarteraSolicitud.fecha_consulta,
				recordCarteraSolicitud.afiliado,--nit tercero??
				recordCarteraSolicitud.valor_solicitado,--se calcula con la liquidacion sum(valor_cuota)
				cod_negocio_nuevo,
				0.00,
				0.00,
				recordCarteraSolicitud.tasa,
				'',
				recordCarteraSolicitud.id_convenio,
				recordCarteraSolicitud.cod_sector,
				recordCarteraSolicitud.cod_subsector,
				'T',
				'PCR',
				'DES',
				'',
				FALSE,
				(recordCarteraSolicitud.ciclo::numeric)::int,
				NOW()
			);

		raise notice 'Crear negocio';

		/* ***********************
		* fin nuevo negocio  ****
		**************************/

		/* ***********************************************************************
		****** Actualizar el formulario  y creacion del cliente en tabla nit *****
		**************************************************************************/

		UPDATE solicitud_aval SET
			user_update=usuario,
			last_update=now(),
			cod_neg=cod_negocio_nuevo,
			estado_sol='V'
		WHERE numero_solicitud = numeroSolicitud;


		/* ******************************************************************
		* Llenamos la tabla con los negocios pendientes por liquidacion  ****
		*********************************************************************/

		INSERT INTO administrativo.negocios_xliquidacion(
				    numero_solicitud,fecha_consulta, valor_solicitado, valor_aprobado,
				    cod_neg, id_convenio, plazo, plazo_pr_cuota, fecha_primera_cuota,
				    ciclo, tasa, estado,referencia, creation_date, creation_user, last_update,
				    user_update)
			    VALUES (numeroSolicitud,recordCarteraSolicitud.fecha_consulta,recordCarteraSolicitud.valor_solicitado,recordCarteraSolicitud.valor_aprobado,
				    cod_negocio_nuevo, recordCarteraSolicitud.id_convenio, ((recordCarteraSolicitud.plazo::numeric)::int )::text,((recordCarteraSolicitud.plazo_pr_cuota::numeric)::int )::text,recordCarteraSolicitud.fecha_primera_cuota,
				    ((recordCarteraSolicitud.ciclo::numeric)::int )::text, recordCarteraSolicitud.tasa, 'NP',recordCarteraSolicitud.referencia, NOW(), usuario,  '0099-01-01 00:00:00'::timestamp,
				    '');

		/* ***************************************************
		****** Actualizamos cada registro como procesado *****
		******************************************************/
		 --1.)administrativo.solicitud_aval_cc
			UPDATE administrativo.solicitud_aval_cc  SET procesado='S'
			WHERE  numero_solicitud = recordCarteraSolicitud.numero_solicitud  AND procesado='N';
		 --2.)administrativo.solicitud_persona_cc
			UPDATE administrativo.solicitud_persona_cc  SET procesado='S'
			WHERE  numero_solicitud = recordCarteraSolicitud.numero_solicitud  AND procesado='N';
		 --3.)administrativo.solicitud_estudiante_cc
			UPDATE administrativo.solicitud_estudiante_cc  SET procesado='S'
			WHERE  numero_solicitud = recordCarteraSolicitud.numero_solicitud  AND procesado='N';

		retorno:='OK';

	end loop;

	return retorno;

EXCEPTION
	WHEN OTHERS THEN
		RAISE EXCEPTION 'Lo sentimos algo salio mal: %',SQLERRM;
		retorno='FAIL' ;
		return retorno;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_generar_negocio_compra_cartera(character varying)
  OWNER TO postgres;
