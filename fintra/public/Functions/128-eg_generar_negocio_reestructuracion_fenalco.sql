-- Function: eg_generar_negocio_reestructuracion_fenalco(integer, character varying)

-- DROP FUNCTION eg_generar_negocio_reestructuracion_fenalco(integer, character varying);

CREATE OR REPLACE FUNCTION eg_generar_negocio_reestructuracion_fenalco(idrop integer, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

 recordConvenio record;
 totalesLiquidacion record;
 recordCliente record;
 numeroSolicitud NUMERIC :=1;
 numeroSolAnterior NUMERIC :=1 ;
 negocio_padre varchar:='';
 cod_negocio_nuevo TEXT :='';
 valor_negocio NUMERIC :=0;
 cmc_fenalco varchar:='';
 recordBuscarConvenio record;
 recordDiferidos record;
 recorPrefijosFacturas record;
 contador_ing_fenalco integer := 0;
 retorno TEXT :='OK';
 grupoTransaccion integer :=0;
 transaccionDetalle integer :=0;
 cuentaCXC varchar:='';
 cuentaInteres varchar:='';
 totalDebito NUMERIC:=0;
 ciclo integer:=0;


BEGIN


 /* ********************************************************
  * Obtenemos numero de solicitud para el nuevo formulario *
  *********************************************************/
  SELECT INTO negocio_padre negocio FROM  recibo_oficial_pago where id = idRop;
  SELECT INTO valor_negocio sum(capital) FROM liquidacion_reestructuracion_fenalco WHERE  id_rop=idRop;
  numeroSolicitud := get_lcod('SOLICITUD_AVAL');
  SELECT INTO numeroSolAnterior numero_solicitud FROM solicitud_aval  where  cod_neg = negocio_padre ;




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
				now(),usuario,now(),'',dstrct, id_convenio,
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
                SELECT  reg_status,numeroSolicitud,
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
                SELECT  reg_status,numeroSolicitud,
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


 INSERT INTO solicitud_estudiante
            (
                reg_status,numero_solicitud,
                parentesco_girador,universidad,programa,fecha_ingreso_programa,
                codigo,semestre,valor_semestre,tipo_carrera,
                trabaja,nombre_empresa,direccion_empresa,telefono_empresa,salario,
                creation_date,creation_user,last_update,user_update,dstrct
            )
            (
                SELECT  reg_status,numeroSolicitud,
			parentesco_girador,universidad,programa,fecha_ingreso_programa,
			codigo,semestre,valor_semestre,tipo_carrera,
			trabaja,nombre_empresa,direccion_empresa,telefono_empresa,salario,
			NOW(),creation_user,NOW(),'',dstrct
		FROM solicitud_estudiante WHERE  numero_solicitud = numeroSolAnterior
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
    IF(negocio_padre LIKE 'FA%')THEN
      cod_negocio_nuevo := get_lcod('FENALCO-ATL');
      cmc_fenalco:='FA';
    ELSIF (negocio_padre LIKE 'NG%') THEN
      cod_negocio_nuevo := get_lcod('FENALCO-ATL');
      cmc_fenalco:='FA';
    ELSE
     cod_negocio_nuevo := get_lcod('FENALCO_BOL');
     cmc_fenalco:='NB';
    END IF;



	SELECT INTO totalesLiquidacion
		sum(capital) as capital,--valor desembolso
		sum(interes) as interes,
		sum(custodia) as custodia,
		sum(seguro) as seguro,
		sum(remesa) as remesa,
		sum(valor_cuota) as valor_cuota,	--total pagado
                count(0) as numcuota,
                min(fecha) as fecha_pr_cuota
	FROM liquidacion_reestructuracion_fenalco WHERE id_rop =idRop;


        SELECT INTO recordConvenio tasa_interes,
		porcentaje_cat,
		valor_capacitacion,
		valor_seguro,
		valor_central,
		cat,
		impuesto,
		id_convenio
 	FROM convenios
	WHERE id_convenio=(SELECT id_convenio FROM negocios Where cod_neg=negocio_padre);


 /* ************************************
  * Insert negocio fenalco         *****
  **************************************/

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
			valor_negocio,
			totalesLiquidacion.numcuota,
			totalesLiquidacion.capital,
			0,
			totalesLiquidacion.custodia,
			mod_aval,
                        mod_custodia,
                        porc_remesa,
                        mod_remesa,
			usuario,
			(totalesLiquidacion.fecha_pr_cuota::date - now()::date),
			tneg,
			cod_tabla,
			dist,
			esta,
			now(),
                        nit_tercero,
			totalesLiquidacion.valor_cuota,
			cod_negocio_nuevo,
			0,
			totalesLiquidacion.remesa,
			recordConvenio.tasa_interes ,
			cnd_aval,
			recordConvenio.id_convenio,
			null,
			banco_cheque,
                        cod_sector,
                        cod_subsector,
			'T',
                        tipo_proceso,
                        'DES',
                        '',
                        false

		FROM negocios  WHERE cod_neg= negocio_padre


		);

 RAISE NOTICE 'Cod neg nuevo %',cod_negocio_nuevo ;
 /* ************************************
  * Insert documentos_neg_aceptado  *****
  **************************************/

 INSERT INTO documentos_neg_aceptado(
              cod_neg, item, fecha, dias, saldo_inicial, capital, interes,valor, saldo_final, creation_date,seguro,custodia, remesa)
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
		remesa
	 FROM liquidacion_reestructuracion_fenalco WHERE id_rop =idRop

	);


 /* ************************************
  * Documentos del formulario    *****
  **************************************/

 INSERT INTO solicitud_documentos(
            numero_solicitud, num_titulo,valor, fecha,liquidacion,creation_user,creation_date,last_update)

       (
         SELECT
		numeroSolicitud,
		cuota ,
		valor_cuota,
		fecha,
		1,
		usuario,
		now(),
		now()
	FROM liquidacion_reestructuracion_fenalco WHERE id_rop =idRop

       );



 /* ************************************
  * Actualizar el formulario   *********
  **************************************/

	UPDATE solicitud_aval SET
		user_update=usuario,
		last_update=now(),
		cod_neg=cod_negocio_nuevo,
		estado_sol='T',
		id_convenio=recordConvenio.id_convenio
	WHERE numero_solicitud = numeroSolicitud;


  /* ****************************************
  * Crear Relacion negocio viejo con nuevo *
  ******************************************/

 INSERT INTO rel_negocios_reestructuracion(negocio_base, negocio_reestructuracion, saldo_capital, saldo_interes, saldo_cat, saldo_seguro, intxmora, gac, creation_user)
    VALUES (negocio_padre, cod_negocio_nuevo, 0, 0, 0, 0, 0, 0, usuario);

  /* **********************************
  * Crear Intereses diferidos fenalco *
  *************************************/

	SELECT INTO recordBuscarConvenio
		reg_status, dstrct, id_convenio, nombre, descripcion, nit_convenio,
		factura_tercero, nit_tercero, tasa_interes, cuenta_interes, valor_custodia,
		cuenta_custodia, prefijo_negocio, prefijo_cxp, cuenta_cxp, hc_cxp,
		descuenta_gmf, cuota_gmf, prefijo_nc_gmf, cuenta_gmf,cuenta_gmf2, porcentaje_gmf2, cuenta_gmf2,descuenta_aval,
		prefijo_nc_aval, cuenta_aval, prefijo_diferidos, cuenta_diferidos,
		hc_diferidos, creation_user, user_update, creation_date, last_update,
		porcentaje_gmf,porcentaje_gmf2, impuesto, cuenta_ajuste, prefijo_endoso, hc_endoso, intermediario_aval,nit_mediador, aval_tercero,
		 central, capacitacion, seguro, nit_central, nit_capacitador, nit_asegurador, prefijo_cxc_interes, prefijo_cxp_central,
		cuenta_central, cuenta_com_central,  prefijo_cxc_cat,cuenta_cat, cuenta_capacitacion, cuenta_seguro, cuenta_com_seguro,
		valor_central,valor_com_central , porcentaje_cat, valor_capacitacion, valor_seguro,porcentaje_com_seguro,
		monto_minimo, monto_maximo, plazo_maximo, tipo, redescuento, aval_anombre, cxp_avalista,  nit_anombre, prefijo_cxc_aval,
		hc_cxc_aval,cuenta_cxc_aval, cctrl_db_cxc_aval, cctrl_cr_cxc_aval,cctrl_iva_cxc_aval, prefijo_cxp_avalista, hc_cxp_avalista,
		cuenta_cxp_avalista, cat
	FROM    convenios
	WHERE   id_convenio=recordConvenio.id_convenio;

	contador_ing_fenalco:=0;
	FOR recordDiferidos IN  SELECT dna.fecha,dna.interes,neg.cod_cli FROM  documentos_neg_aceptado dna
				 INNER JOIN negocios neg on(dna.cod_neg=neg.cod_neg)
				 WHERE dna.reg_status!='A' AND dna.cod_neg=cod_negocio_nuevo ORDER BY dna.fecha
	LOOP

		INSERT INTO ing_fenalco(dstrct,cod,codneg,valor,nit,creation_user,base,fecha_doc,cmc)
			VALUES('FINV',get_lcod_ing(recordBuscarConvenio.prefijo_diferidos,contador_ing_fenalco),cod_negocio_nuevo,round(recordDiferidos.interes),recordDiferidos.cod_cli,usuario,'COL',recordDiferidos.fecha,cmc_fenalco);

                contador_ing_fenalco:=contador_ing_fenalco+1;

	END LOOP;

        UPDATE series
	set last_number=last_number+1
	where document_type = 'IF'
	and reg_status='';


  /* **********************************
  *     Contabilizamos EL Negocio     *
  *************************************/
        SELECT INTO recordCliente  codcli,nomcli,nit FROM cliente where nit=(SELECT COD_CLI FROM negocios where cod_neg=cod_negocio_nuevo);
	SELECT INTO grupoTransaccion nextval('con.comprobante_grupo_transaccion_seq');
	totalDebito:=totalesLiquidacion.capital + totalesLiquidacion.interes;

	INSERT INTO con.comprobante(
	    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
	    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
	    total_items, moneda, fecha_aplicacion, aprobador, last_update,
	    user_update, creation_date, creation_user, base, usuario_aplicacion,
	    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
	VALUES ('', 'FINV', 'NEG', cod_negocio_nuevo, grupoTransaccion, 'OP',
		replace(substring(now(),1,7),'-',''), NOW()::date, 'NEGOCIO No'||cod_negocio_nuevo,recordCliente.nit, totalDebito, totalDebito,
		3, 'PES', NOW(),'', '0099-01-01',
		'',  NOW(), usuario, '', usuario,
		'001', '', 0, '', '');

	/******************************************
	*****CREAMOS EL DETELLE DEL COMPROBANTE***/
	--items 1
        SELECT INTO cuentaCXC cuenta_cxc FROM convenios_cxc where titulo_valor='03' and id_convenio=(SELECT id_convenio FROM negocios where cod_neg=cod_negocio_nuevo);
	SELECT INTO transaccionDetalle nextval('con.comprodet_transaccion_seq');
	INSERT INTO con.comprodet(
	    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
	    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
	    tercero, documento_interno, last_update, user_update, creation_date,
	    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
	    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
	    tipo_referencia_3, referencia_3)
	VALUES ('', 'FINV', 'NEG',cod_negocio_nuevo,grupoTransaccion,transaccionDetalle,
	    replace(substring(now(),1,7),'-',''), cuentaCXC, '', 'CARTERA NEGOCIO PADRE', totalDebito, 0,
	    recordCliente.nit, cod_negocio_nuevo, '0099-01-01', '', NOW(),
	    usuario, '', 'NEG', cod_negocio_nuevo, 'N/A',0,
	    '', '', '', '',
	    '', '');


	--items 2
	SELECT INTO transaccionDetalle nextval('con.comprodet_transaccion_seq');
	INSERT INTO con.comprodet(
	    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
	    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
	    tercero, documento_interno, last_update, user_update, creation_date,
	    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
	    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
	    tipo_referencia_3, referencia_3)
	VALUES ('', 'FINV', 'NEG',cod_negocio_nuevo,grupoTransaccion,transaccionDetalle,
	    replace(substring(now(),1,7),'-',''), '13050910', '', 'CUENTA PUENTE CARTERA NUEVA', 0, totalesLiquidacion.capital,
	    recordCliente.nit, cod_negocio_nuevo, '0099-01-01', '', NOW(),
	    usuario, '', 'NEG', cod_negocio_nuevo, 'N/A',0,
	    '', '', '', '',
	    '', '');

       	--items 3
        SELECT INTO cuentaInteres cuenta_interes from convenios where id_convenio =(SELECT id_convenio FROM negocios where cod_neg=cod_negocio_nuevo);
	SELECT INTO transaccionDetalle nextval('con.comprodet_transaccion_seq');
	INSERT INTO con.comprodet(
	    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
	    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
	    tercero, documento_interno, last_update, user_update, creation_date,
	    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
	    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
	    tipo_referencia_3, referencia_3)
	VALUES ('', 'FINV', 'NEG',cod_negocio_nuevo,grupoTransaccion,transaccionDetalle,
	    replace(substring(now(),1,7),'-',''), cuentaInteres, '', 'INTERESES ANTICIPADO DE PADRE', 0, totalesLiquidacion.interes,
	    recordCliente.nit, cod_negocio_nuevo, '0099-01-01', '', NOW(),
	    usuario, '', 'NEG', cod_negocio_nuevo,'N/A',0,
	    '', '', '', '',
	    '', '');

	--ACTUALIZAMOS EL NEGOCIO CONTABILIZADO Y LO ASIGNAMOS A UN CICLO.
        SELECT INTO ciclo CASE WHEN date_part('DAY', totalesLiquidacion.fecha_pr_cuota)='02' THEN 1
			       WHEN date_part('DAY', totalesLiquidacion.fecha_pr_cuota)='12' THEN 2
			       WHEN date_part('DAY', totalesLiquidacion.fecha_pr_cuota)='17' THEN 3
			       WHEN date_part('DAY', totalesLiquidacion.fecha_pr_cuota)='22' THEN 4
			   END ;

	UPDATE negocios SET
	       fecha_ap=now(),
               aprobado_por=usuario,
	       fecha_cont=now(),
	       user_cont=usuario,
	       no_transacion =grupoTransaccion,
	       num_ciclo=ciclo
	WHERE cod_neg=cod_negocio_nuevo  ;


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
ALTER FUNCTION eg_generar_negocio_reestructuracion_fenalco(integer, character varying)
  OWNER TO postgres;
