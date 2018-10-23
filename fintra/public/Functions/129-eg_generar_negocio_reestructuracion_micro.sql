-- Function: eg_generar_negocio_reestructuracion_micro(character varying, character varying, numeric, numeric, integer, date, character varying, numeric, numeric, numeric, numeric, numeric, numeric)

-- DROP FUNCTION eg_generar_negocio_reestructuracion_micro(character varying, character varying, numeric, numeric, integer, date, character varying, numeric, numeric, numeric, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION eg_generar_negocio_reestructuracion_micro(negocio_padre character varying, usuario character varying, convenio numeric, valor_negocio numeric, numcuota integer, fecha_pr_cuota date, tipo_cuotas character varying, saldocapital numeric, saldointeres numeric, saldocat numeric, saldoseguro numeric, int_x_mora numeric, gacobranza numeric)
  RETURNS text AS
$BODY$
DECLARE

 recordConvenio record;
 totalesLiquidacion record;
 numeroSolicitud NUMERIC :=1;
 numeroSolAnterior NUMERIC :=1 ;
 cod_negocio_nuevo TEXT :='';
 retorno TEXT :='OK';


BEGIN


 /* ********************************************************
  * Obtenemos numero de solicitud para el nuevo formulario
  *********************************************************/
  numeroSolicitud := get_lcod('SOLICITUD_AVAL');
  SELECT INTO numeroSolAnterior numero_solicitud FROM solicitud_aval  where  cod_neg = negocio_padre ;

 RAISE NOTICE 'Numero solicitud %',numeroSolicitud ;


 /* ********************************************************
  * Insertamos la solicitud para el nuevo formulario.
  *********************************************************/

  INSERT INTO solicitud_aval(reg_status,numero_solicitud,fecha_consulta,
                valor_solicitado,agente,afiliado,codigo,estado_sol,tipo_persona,
                creation_date,creation_user,last_update,user_update,dstrct, id_convenio,
                producto,servicio,ciudad_matricula, valor_producto, asesor,
                cod_sector, cod_subsector, plazo, plazo_pr_cuota, tipo_negocio,
                num_tipo_negocio, banco,renovacion,fecha_primera_cuota)

            (SELECT reg_status, numeroSolicitud, now(),
				valor_negocio ,agente,afiliado,codigo,'P',tipo_persona,
				now(),usuario,now(),'',dstrct, convenio,
				producto,servicio,ciudad_matricula, valor_negocio, asesor,
				cod_sector, cod_subsector, plazo, plazo_pr_cuota, tipo_negocio,
				num_tipo_negocio, banco,renovacion,fecha_primera_cuota

		FROM solicitud_aval  where numero_solicitud = numeroSolAnterior );



  INSERT INTO solicitud_vehiculo
            (
                reg_status,numero_solicitud,
                tipo,secuencia,marca,tipo_vehiculo,
                placa,modelo,valor_comercial,cuota_mensual,pignorado_a_favor_de,
                creation_date,creation_user,last_update,user_update,dstrct
            )

            (
		SELECT reg_status,numeroSolicitud,
			tipo,secuencia,marca,tipo_vehiculo,
			placa,modelo,valor_comercial,cuota_mensual,pignorado_a_favor_de,
			now(),usuario ,now(),'',dstrct

		FROM solicitud_vehiculo
		WHERE numero_solicitud = numeroSolAnterior

            );


 INSERT INTO solicitud_bienes
            (
                reg_status,numero_solicitud,
                tipo,secuencia,tipo_de_bien,
                hipoteca,a_favor_de,valor_comercial,direccion,
                creation_date,creation_user,last_update,user_update,dstrct
            )

            (

		SELECT reg_status,numeroSolicitud,
				tipo,secuencia,tipo_de_bien,
				hipoteca,a_favor_de,valor_comercial,direccion,
				now(),usuario,now(),'',dstrct
		FROM solicitud_bienes  where numero_solicitud = numeroSolAnterior
            );


 INSERT INTO solicitud_referencias
            (
                reg_status,numero_solicitud,
                tipo,tipo_referencia,secuencia,nombre,
                primer_apellido,segundo_apellido,primer_nombre,segundo_nombre,
                telefono1,telefono2,extension,celular,
                ciudad,departamento,tiempo_conocido,parentesco,email,direccion,
                creation_date,creation_user,last_update,user_update,dstrct
            )

            (

		SELECT          reg_status,numeroSolicitud,
				tipo,tipo_referencia,secuencia,nombre,
				primer_apellido,segundo_apellido,primer_nombre,segundo_nombre,
				telefono1,telefono2,extension,celular,
				ciudad,departamento,tiempo_conocido,parentesco,email,direccion,
				now(),usuario,now(),'',dstrct

		FROM solicitud_referencias  where numero_solicitud = numeroSolAnterior
            );


 INSERT INTO solicitud_persona
            (
                reg_status,numero_solicitud,
                tipo_persona,tipo,codcli,
                identificacion,tipo_id,fecha_expedicion_id,ciudad_expedicion_id,dpto_expedicion_id,
                fecha_nacimiento,ciudad_nacimiento,dpto_nacimiento,
                nivel_estudio,profesion,personas_a_cargo,num_de_hijos,total_grupo_familiar,estrato,tiempo_residencia,
                primer_apellido,segundo_apellido,primer_nombre,segundo_nombre,
                ciiu,fax,tipo_empresa,fecha_constitucion,representante_legal,genero_representante,tipo_id_representante,id_representante,
                firmador_cheques,genero_firmador,tipo_id_firmador,id_firmador,telefono2,primer_apellido_cony,segundo_apellido_cony,
                primer_nombre_cony,segundo_nombre_cony,tipo_id_cony,id_cony,empresa_cony,direccion_cony,telefono_cony,cargo_cony,salario_cony,celular_cony,email_cony,
                ciudad,departamento,genero,email,estado_civil,direccion,barrio,tipo_vivienda,telefono,celular,nombre,
                creation_date,creation_user,last_update,user_update,dstrct
            )

            (
                SELECT     reg_status,numeroSolicitud,
			tipo_persona,tipo,codcli,
			identificacion,tipo_id,fecha_expedicion_id,ciudad_expedicion_id,dpto_expedicion_id,
			fecha_nacimiento,ciudad_nacimiento,dpto_nacimiento,
			nivel_estudio,profesion,personas_a_cargo,num_de_hijos,total_grupo_familiar,estrato,tiempo_residencia,
			primer_apellido,segundo_apellido,primer_nombre,segundo_nombre,
			ciiu,fax,tipo_empresa,fecha_constitucion,representante_legal,genero_representante,tipo_id_representante,id_representante,
			firmador_cheques,genero_firmador,tipo_id_firmador,id_firmador,telefono2,primer_apellido_cony,segundo_apellido_cony,
			primer_nombre_cony,segundo_nombre_cony,tipo_id_cony,id_cony,empresa_cony,direccion_cony,telefono_cony,cargo_cony,salario_cony,celular_cony,email_cony,
			ciudad,departamento,genero,email,estado_civil,direccion,barrio,tipo_vivienda,telefono,celular,nombre,
			now(),usuario,now(),'',dstrct

		FROM solicitud_persona     where numero_solicitud = numeroSolAnterior

	    );

 INSERT INTO solicitud_laboral
            (
                reg_status,numero_solicitud,
                tipo,ocupacion,actividad_economica,
                nombre_empresa,nit,
                direccion,ciudad,departamento,telefono,
                extension,cargo,fecha_ingreso,tipo_contrato,
                salario,otros_ingresos,concepto_otros_ing,
                gastos_manutencion,gastos_creditos,gastos_arriendo,celular, email,eps,tipo_afiliacion,
                creation_date,creation_user,last_update,user_update,dstrct, direccion_cobro
            )

            (
                SELECT    reg_status,numeroSolicitud,
			tipo,ocupacion,actividad_economica,
			nombre_empresa,nit,
			direccion,ciudad,departamento,telefono,
			extension,cargo,fecha_ingreso,tipo_contrato,
			salario,otros_ingresos,concepto_otros_ing,
			gastos_manutencion,gastos_creditos,gastos_arriendo,celular, email,eps,tipo_afiliacion,
			now(),usuario,now(),'',dstrct, direccion_cobro

		FROM   solicitud_laboral  where numero_solicitud = numeroSolAnterior
            );


 INSERT INTO solicitud_hijos
            (
                reg_status,numero_solicitud,
                tipo,secuencia,nombre,
                direccion,telefono,
                edad,email,creation_date,creation_user,last_update,user_update,dstrct
            )

            (
                SELECT reg_status,numeroSolicitud,
			tipo,secuencia,nombre,
			direccion,telefono,
			edad,email,now(),usuario,now(),'',dstrct

		FROM  solicitud_hijos where numero_solicitud = numeroSolAnterior
            );

 INSERT INTO solicitud_negocio
            (
                reg_status,numero_solicitud,
                nombre,direccion,departamento,ciudad,
                barrio,telefono,cod_sector, cod_subsector,
                num_exp_negocio,tiempo_local,tiempo_microempresario, num_trabajadores,
                creation_date,creation_user,last_update,user_update,dstrct
            )

            (
                SELECT reg_status,numeroSolicitud,
			nombre,direccion,departamento,ciudad,
			barrio,telefono,cod_sector, cod_subsector,
			num_exp_negocio,tiempo_local,tiempo_microempresario, num_trabajadores,
			now(),usuario,now(),'',dstrct

		FROM  solicitud_negocio where numero_solicitud = numeroSolAnterior
            );


  INSERT INTO solicitud_cuentas
            (
                reg_status,numero_solicitud,
                consecutivo,tipo,banco,cuenta,fecha_apertura,numero_tarjeta,
                 creation_date,creation_user,last_update,user_update,dstrct
            )

            (
		SELECT  reg_status,numeroSolicitud,
			consecutivo,tipo,banco,cuenta,fecha_apertura,numero_tarjeta,
			NOW(),creation_user,NOW(),'',dstrct
		FROM solicitud_cuentas where numero_solicitud = numeroSolAnterior
            );


 /* *******************************************************
  * Fin nuevo formulario.
  *********************************************************/

 /* *******************************************************
  * Se crea el nuevo negocio apartir del liquidador  *****
  *********************************************************/

    cod_negocio_nuevo := get_lcod('NEG_MICROCRED');
    RAISE NOTICE 'Cod neg nuevo %',cod_negocio_nuevo ;

    SELECT into  totalesLiquidacion
		sum(valor) as valor_cuota,
		sum(capital) as capital,
		sum(seguro) as seguro,
		sum(capacitacion) as capacitacion
	FROM eg_simulador_liquidacion_micro(valor_negocio::numeric,numcuota::integer,fecha_pr_cuota::date, tipo_cuotas::character varying ,convenio::character varying );


--SELECT * from eg_generar_negocio_reestructuracion_micro('MC02933','EDGARGM87',10,'1000000', 10,'2014-09-22'::date,'CPFCTV' )
--select * from eg_simulador_liquidacion_micro(2686665,12,'2014-09-22'::date, 'CPFCTV','10')



        SELECT INTO recordConvenio tasa_interes,
		porcentaje_cat,
		valor_capacitacion,
		valor_seguro,
		valor_central,
		cat,
		impuesto
 	FROM convenios
	WHERE id_convenio= convenio;


 /* ************************************
  * Insert negocio microcredito  *****
  **************************************/

	INSERT INTO negocios
		(

		    cod_cli,
		    vr_negocio,
		    nro_docs,
		    vr_desembolso,
		    create_user,
		    fpago,
		    tneg,
		    dist,
		    fecha_negocio,
		    tot_pagado,
		    cod_neg,
		    tasa,
		    id_convenio,
		    estado_neg,
		    porcentaje_cat,
		    valor_capacitacion,
		    valor_central,
		    valor_seguro,
		    nit_tercero,
		    fecha_liquidacion,
		    tipo_cuota,
		    tipo_proceso,
		    actividad
		)
		(
		  SELECT
			cod_cli,
			valor_negocio,
			numcuota,
			totalesLiquidacion.capital,
			usuario,
			(fecha_pr_cuota - now()::date),
			tneg,
			dist,
			now(),
			totalesLiquidacion.valor_cuota,
			cod_negocio_nuevo,
			recordConvenio.tasa_interes ,
			convenio,
			'P',
			recordConvenio.porcentaje_cat,
			totalesLiquidacion.capacitacion,
			recordConvenio.valor_central,
			totalesLiquidacion.seguro,
			nit_tercero,
			now(),
			tipo_cuotas,
			tipo_proceso,
			'ANA'

		FROM negocios  WHERE cod_neg= negocio_padre


		);



 /* ************************************
  * Insert documentos_neg_aceptado  *****
  **************************************/

 INSERT INTO documentos_neg_aceptado(
            cod_neg, item, fecha, dias, saldo_inicial, capital, interes, valor, saldo_final,no_aval, capacitacion, cat, seguro)
	(
	 SELECT
		cod_negocio_nuevo,
		item ,
		fecha,
		dias,
		saldo_inicial,
		capital,
		interes,
		valor,
		saldo_final,
		0,
		capacitacion,
		cat,
		seguro
	 FROM eg_simulador_liquidacion_micro(valor_negocio::numeric,numcuota::integer,fecha_pr_cuota::date, tipo_cuotas::character varying ,convenio::character varying )

	);


 /* ************************************
  * Documentos del formulario    *****
  **************************************/

 INSERT INTO solicitud_documentos(
            numero_solicitud, num_titulo,valor, fecha,liquidacion,creation_user,creation_date,last_update)

       (
         SELECT
		numeroSolicitud,
		item ,
		valor,
		fecha,
		1,
		usuario,
		now(),
		now()
	 FROM eg_simulador_liquidacion_micro(valor_negocio::numeric,numcuota::integer,fecha_pr_cuota::date, tipo_cuotas::character varying ,convenio::character varying )

       );


 /* ************************************
  * Actualizar el formulario   *********
  **************************************/

	UPDATE solicitud_aval SET
		user_update=usuario,
		last_update=now(),
		cod_neg=cod_negocio_nuevo,
		estado_sol='P',
		id_convenio=convenio
	WHERE numero_solicitud = numeroSolicitud;


  /* ****************************************
  * Crear Relacion negocio viejo con nuevo *
  ******************************************/

 INSERT INTO rel_negocios_reestructuracion(negocio_base, negocio_reestructuracion, saldo_capital, saldo_interes, saldo_cat, saldo_seguro, intxmora, gac, creation_user)
    VALUES (negocio_padre, cod_negocio_nuevo, saldocapital, saldointeres, saldocat, saldoseguro, int_x_mora, gacobranza, usuario);




return retorno ||';' || numeroSolicitud ||';'||cod_negocio_nuevo ;

EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'La institución no puede ser borrada, existen dependencias para este registro.';
		retorno='FAIL' ;
		return retorno;

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
ALTER FUNCTION eg_generar_negocio_reestructuracion_micro(character varying, character varying, numeric, numeric, integer, date, character varying, numeric, numeric, numeric, numeric, numeric, numeric)
  OWNER TO postgres;
