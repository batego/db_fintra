-- Function: apicredit.eg_clonar_solicitud_credito(integer, integer, character varying)

-- DROP FUNCTION apicredit.eg_clonar_solicitud_credito(integer, integer, character varying);

CREATE OR REPLACE FUNCTION apicredit.eg_clonar_solicitud_credito(_numerosolicitudpadre integer, nuevonumerosolicitud integer, _userlogin character varying)
  RETURNS text AS
$BODY$
DECLARE
  recordPresolicitudes RECORD;
  _entramite integer:=0;
  retorno text:='';
BEGIN

     --1)Buscamos la presolicitud de credito
	SELECT INTO recordPresolicitudes
                c.numero_solicitud,
		c.producto,
		c.entidad,
                c.afiliado,
                lower(p.payment_name) as name_afiliado,
                p.cod_fenalco as codigo,
	        c.valor_cuota,
                c.valor_aval,
                c.fecha_credito,
                c.monto_credito,
                c.numero_cuotas,
                c.fecha_pago::date,
                c.tipo_identificacion,
                c.identificacion,
                c.fecha_expedicion::date,
                c.primer_nombre,
                c.primer_apellido,
		c.fecha_nacimiento::date,
		c.email,
		c.ingresos_usuario,
                c.id_convenio,
                c.estado_sol,
		case when c.estado_sol='P' THEN 'Pre Aprobado'
		     when c.estado_sol='R' THEN 'Rechazado'
		     when c.estado_sol='B' THEN 'Borrador' end as estado_sol_desc,
                c.empresa,
                c.etapa,
                case when sa.cod_neg is null then '' else sa.cod_neg  end as  cod_neg,
                total_obligaciones_financieras,
                total_gastos_familiares,
                c.financia_aval,
                c.tipo_cliente,
                c.creation_date,
                c.asesor
            from apicredit.pre_solicitudes_creditos c
	    inner join proveedor p on (p.nit=c.afiliado)
	    left join solicitud_aval sa on (sa.numero_solicitud=c.numero_solicitud)
            WHERE  c.numero_solicitud=nuevoNumeroSolicitud  and c.estado_sol='B' ;

	raise notice 'recordPresolicitudes: %',recordPresolicitudes;
        --VALIDAMOS QUE EXISTAN LAS PRE-SOLICITUDES DEL CREDITO
        IF(recordPresolicitudes IS NOT NULL AND _numerosolicitudPadre >0)THEN

		--0.)Validamos las solicitudes en tramite
		/*SELECT INTO _entramite count(*) FROM solicitud_aval sa  INNER JOIN solicitud_persona sp
		    ON(sp.numero_solicitud=sa.numero_solicitud)
		    WHERE identificacion =recordPresolicitudes.identificacion AND estado_sol NOT IN ('A','R','T');*/
		_entramite:=0;
		IF(_entramite = 0 )THEN
			--1.)INSERTAMOS LAS SOLICIUD AVAL
			INSERT INTO solicitud_aval
						(reg_status,
						 dstrct,
						 numero_solicitud,
						 fecha_consulta,
						 valor_solicitado,
						 agente,
						 afiliado,
						 codigo,
						 numero_aprobacion,
						 estado_sol,
						 tipo_persona,
						 valor_aprobado,
						 tipo_negocio,
						 num_tipo_negocio,
						 banco,
						 sucursal,
						 num_chequera,
						 cod_neg,
						 creation_date,
						 creation_user,
						 last_update,
						 user_update,
						 id_convenio,
						 producto,
						 servicio,
						 ciudad_matricula,
						 valor_producto,
						 asesor,
						 cod_sector,
						 cod_subsector,
						 plazo,
						 plazo_pr_cuota,
						 ciudad_cheque,
						 accion_sugerida)
				    (SELECT reg_status,
					    dstrct,
					    nuevoNumeroSolicitud,
					    recordPresolicitudes.creation_date::date,
					    recordPresolicitudes.monto_credito,
					    ''::varchar as agente,
					    recordPresolicitudes.afiliado,
					    recordPresolicitudes.codigo,
					    ''::varchar as numero_aprobacion,
					    'P'::varchar as estado_sol,
					    tipo_persona,
					    recordPresolicitudes.monto_credito,
					    '03'::varchar as tipo_negocio,
					    ''::varchar as num_tipo_negocio,
					    null as banco,
					    ''::varchar as sucursal,
					    ''::varchar as num_chequera,
					     null as negocio,
					    recordPresolicitudes.creation_date,
					    _userLogin as creation_user,
					    '0099-01-01 00:00:00'::timestamp as last_update,
					    ''::varchar as user_update,
					    recordPresolicitudes.id_convenio,
					    recordPresolicitudes.producto,
					    ''::varchar as servicio,
					    ''::varchar as ciudad_matricula,
					    recordPresolicitudes.monto_credito,
					    recordPresolicitudes.asesor,
					    cod_sector,
					    cod_subsector,
					    recordPresolicitudes.numero_cuotas as plazo,
					    '30'::varchar as plazo_pr_cuota,
					    ''::varchar as ciudad_cheque,
					    'APROBAR'::varchar as accion_sugerida
				     FROM   solicitud_aval
				     WHERE  numero_solicitud =_numerosolicitudPadre);


		    --2.) INSERTAMOS SOLICITUD_BIENES
			INSERT INTO solicitud_bienes
					    (reg_status,
					     dstrct,
					     numero_solicitud,
					     tipo,
					     secuencia,
					     tipo_de_bien,
					     hipoteca,
					     a_favor_de,
					     valor_comercial,
					     direccion,
					     creation_date,
					     creation_user,
					     last_update,
					     user_update)
				(SELECT reg_status,
					dstrct,
					nuevoNumeroSolicitud,
					tipo,
					secuencia,
					tipo_de_bien,
					hipoteca,
					a_favor_de,
					valor_comercial,
					direccion,
					recordPresolicitudes.creation_date,
					_userLogin as creation_user,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::varchar as user_update
				 FROM   solicitud_bienes
				 WHERE  numero_solicitud =_numerosolicitudPadre);

			--3.) INSERTAMOS LA SOLICITUD_CUENTAS
			INSERT INTO solicitud_cuentas
					    (reg_status,
					     dstrct,
					     numero_solicitud,
					     consecutivo,
					     tipo,
					     banco,
					     cuenta,
					     fecha_apertura,
					     numero_tarjeta,
					     creation_date,
					     creation_user,
					     last_update,
					     user_update
					)
				(SELECT reg_status,
					dstrct,
					nuevoNumeroSolicitud,
					consecutivo,
					tipo,
					banco,
					cuenta,
					fecha_apertura,
					numero_tarjeta,
					recordPresolicitudes.creation_date,
					_userLogin as creation_user,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::varchar as user_update
				 FROM   solicitud_cuentas
				 WHERE  numero_solicitud = _numerosolicitudPadre);

			--4.) INSERTAMOS LA SOLICITUD_ESTUDIANTE
			INSERT INTO solicitud_estudiante
					    (reg_status,
					     dstrct,
					     numero_solicitud,
					     parentesco_girador,
					     universidad,
					     programa,
					     fecha_ingreso_programa,
					     codigo,
					     semestre,
					     valor_semestre,
					     tipo_carrera,
					     trabaja,
					     nombre_empresa,
					     direccion_empresa,
					     telefono_empresa,
					     salario,
					     creation_date,
					     creation_user,
					     last_update,
					     user_update)
				(SELECT reg_status,
					dstrct,
					nuevoNumeroSolicitud,
					parentesco_girador,
					universidad,
					programa,
					fecha_ingreso_programa,
					codigo,
					semestre,
					valor_semestre,
					tipo_carrera,
					trabaja,
					nombre_empresa,
					direccion_empresa,
					telefono_empresa,
					salario,
					recordPresolicitudes.creation_date,
					_userLogin as creation_user,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::varchar as user_update
				 FROM   solicitud_estudiante
				 WHERE  numero_solicitud = _numerosolicitudPadre);

			--5.) INSERTAMOS LA SOLICITUD_HIJOS
			INSERT INTO solicitud_hijos
					    (reg_status,
					     dstrct,
					     numero_solicitud,
					     tipo,
					     secuencia,
					     nombre,
					     direccion,
					     telefono,
					     edad,
					     email,
					     creation_date,
					     creation_user,
					     last_update,
					     user_update)
				(SELECT reg_status,
					dstrct,
					nuevoNumeroSolicitud,
					tipo,
					secuencia,
					nombre,
					direccion,
					telefono,
					edad,
					email,
					recordPresolicitudes.creation_date,
					_userLogin as creation_user,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::varchar as user_update
				 FROM   solicitud_hijos
				 WHERE  numero_solicitud = _numerosolicitudPadre);

			--6.)INSERTAMOS LA SOLICITUD_LABORAL
			INSERT INTO solicitud_laboral
					    (reg_status,
					     dstrct,
					     numero_solicitud,
					     tipo,
					     ocupacion,
					     actividad_economica,
					     nombre_empresa,
					     nit,
					     direccion,
					     ciudad,
					     departamento,
					     telefono,
					     extension,
					     cargo,
					     fecha_ingreso,
					     tipo_contrato,
					     salario,
					     celular,
					     email,
					     eps,
					     tipo_afiliacion,
					     direccion_cobro,
					     otros_ingresos,
					     concepto_otros_ing,
					     gastos_manutencion,
					     gastos_creditos,
					     gastos_arriendo,
					     creation_date,
					     creation_user,
					     last_update,
					     user_update)
				(SELECT reg_status,
					dstrct,
					nuevoNumeroSolicitud,
					tipo,
					ocupacion,
					actividad_economica,
					nombre_empresa,
					nit,
					direccion,
					ciudad,
					departamento,
					telefono,
					extension,
					cargo,
					fecha_ingreso,
					tipo_contrato,
					recordPresolicitudes.ingresos_usuario,
					celular,
					email,
					eps,
					tipo_afiliacion,
					direccion_cobro,
					otros_ingresos,
					concepto_otros_ing,
					gastos_manutencion,
					recordPresolicitudes.total_obligaciones_financieras,
					gastos_arriendo,
					recordPresolicitudes.creation_date,
					_userLogin as creation_user,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::varchar as user_update
				 FROM   solicitud_laboral
				 WHERE  numero_solicitud = _numerosolicitudPadre);

			--7.) INSERTAMOS LA SOLICITUD_NEGOCIO
			INSERT INTO solicitud_negocio
					    (reg_status,
					     dstrct,
					     numero_solicitud,
					     cod_sector,
					     cod_subsector,
					     nombre,
					     direccion,
					     departamento,
					     ciudad,
					     barrio,
					     telefono,
					     tiempo_local,
					     num_exp_negocio,
					     tiempo_microempresario,
					     num_trabajadores,
					     creation_date,
					     creation_user,
					     last_update,
					     user_update)
				(SELECT reg_status,
					dstrct,
					nuevoNumeroSolicitud,
					cod_sector,
					cod_subsector,
					nombre,
					direccion,
					departamento,
					ciudad,
					barrio,
					telefono,
					tiempo_local,
					num_exp_negocio,
					tiempo_microempresario,
					num_trabajadores,
					recordPresolicitudes.creation_date,
					_userLogin as creation_user,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::varchar as user_update
				 FROM   solicitud_negocio
				 WHERE  numero_solicitud = _numerosolicitudPadre);

			--8.) INSERTAMOS LA SOLICITUD_PERSONA
			INSERT INTO solicitud_persona
					    (reg_status,
					     dstrct,
					     numero_solicitud,
					     tipo_persona,
					     tipo,
					     codcli,
					     primer_apellido,
					     segundo_apellido,
					     primer_nombre,
					     segundo_nombre,
					     nombre,
					     ciudad,
					     genero,
					     estado_civil,
					     direccion,
					     departamento,
					     barrio,
					     identificacion,
					     tipo_id,
					     fecha_expedicion_id,
					     ciudad_expedicion_id,
					     dpto_expedicion_id,
					     fecha_nacimiento,
					     ciudad_nacimiento,
					     dpto_nacimiento,
					     nivel_estudio,
					     profesion,
					     personas_a_cargo,
					     num_de_hijos,
					     total_grupo_familiar,
					     estrato,
					     tiempo_residencia,
					     tipo_vivienda,
					     telefono,
					     celular,
					     email,
					     telefono2,
					     primer_apellido_cony,
					     segundo_apellido_cony,
					     primer_nombre_cony,
					     segundo_nombre_cony,
					     tipo_id_cony,
					     id_cony,
					     empresa_cony,
					     direccion_cony,
					     telefono_cony,
					     salario_cony,
					     celular_cony,
					     email_cony,
					     cargo_cony,
					     ciiu,
					     fax,
					     tipo_empresa,
					     fecha_constitucion,
					     representante_legal,
					     genero_representante,
					     tipo_id_representante,
					     id_representante,
					     firmador_cheques,
					     genero_firmador,
					     tipo_id_firmador,
					     id_firmador,
					     creation_date,
					     creation_user,
					     last_update,
					     user_update)
				(SELECT reg_status,
					dstrct,
					nuevoNumeroSolicitud,
					tipo_persona,
					tipo,
					codcli,
					primer_apellido,
					segundo_apellido,
					primer_nombre,
					segundo_nombre,
					nombre,
					ciudad,
					genero,
					estado_civil,
					direccion,
					departamento,
					barrio,
					identificacion,
					tipo_id,
					fecha_expedicion_id,
					ciudad_expedicion_id,
					dpto_expedicion_id,
					fecha_nacimiento,
					ciudad_nacimiento,
					dpto_nacimiento,
					nivel_estudio,
					profesion,
					personas_a_cargo,
					num_de_hijos,
					total_grupo_familiar,
					estrato,
					tiempo_residencia,
					tipo_vivienda,
					telefono,
					celular,
					email,
					telefono2,
					primer_apellido_cony,
					segundo_apellido_cony,
					primer_nombre_cony,
					segundo_nombre_cony,
					tipo_id_cony,
					id_cony,
					empresa_cony,
					direccion_cony,
					telefono_cony,
					salario_cony,
					celular_cony,
					email_cony,
					cargo_cony,
					ciiu,
					fax,
					tipo_empresa,
					fecha_constitucion,
					representante_legal,
					genero_representante,
					tipo_id_representante,
					id_representante,
					firmador_cheques,
					genero_firmador,
					tipo_id_firmador,
					id_firmador,
					recordPresolicitudes.creation_date,
					_userLogin as creation_user,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::varchar as user_update
				 FROM   solicitud_persona
				 WHERE  numero_solicitud = _numerosolicitudPadre);

			--9.) INSERTAMOS LA SOLICITUD_REFERENCIAS
			INSERT INTO solicitud_referencias
					    (reg_status,
					     dstrct,
					     numero_solicitud,
					     tipo,
					     tipo_referencia,
					     secuencia,
					     nombre,
					     primer_apellido,
					     segundo_apellido,
					     primer_nombre,
					     segundo_nombre,
					     telefono1,
					     telefono2,
					     extension,
					     celular,
					     email,
					     direccion,
					     ciudad,
					     departamento,
					     tiempo_conocido,
					     parentesco,
					     creation_date,
					     creation_user,
					     last_update,
					     user_update)
				(SELECT reg_status,
					dstrct,
					nuevoNumeroSolicitud,
					tipo,
					tipo_referencia,
					secuencia,
					nombre,
					primer_apellido,
					segundo_apellido,
					primer_nombre,
					segundo_nombre,
					telefono1,
					telefono2,
					extension,
					celular,
					email,
					direccion,
					ciudad,
					departamento,
					tiempo_conocido,
					parentesco,
					recordPresolicitudes.creation_date,
					_userLogin as creation_user,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::varchar as user_update
				 FROM   solicitud_referencias
				 WHERE  numero_solicitud = _numerosolicitudPadre);

			--10.) INSERTAMOS LA SOLICITUD_VEHICULO
				INSERT INTO solicitud_vehiculo
					    (reg_status,
					     dstrct,
					     numero_solicitud,
					     tipo,
					     secuencia,
					     marca,
					     tipo_vehiculo,
					     placa,
					     modelo,
					     valor_comercial,
					     cuota_mensual,
					     pignorado_a_favor_de,
					     creation_date,
					     creation_user,
					     last_update,
					     user_update)
				(SELECT reg_status,
					dstrct,
					nuevoNumeroSolicitud,
					tipo,
					secuencia,
					marca,
					tipo_vehiculo,
					placa,
					modelo,
					valor_comercial,
					cuota_mensual,
					pignorado_a_favor_de,
					recordPresolicitudes.creation_date,
					_userLogin as creation_user,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::varchar as user_update
				 FROM   solicitud_vehiculo
				 WHERE  numero_solicitud = _numerosolicitudPadre);

			--11.) GUARDAMOS LA LIQUIDACION DEL NEGOCIO
				INSERT INTO apicredit.pre_liquidacion_creditos(
				    dstrct, numero_solicitud, fecha, dias, cuota, saldo_inicial,
				    capital, interes, custodia, seguro, remesa, valor_cuota, saldo_final,
				    valor_aval,cuota_manejo, creation_user, creation_date)
				 SELECT
				    'FINV'::varchar as dstrct,
				    nuevoNumeroSolicitud as numero_solicitud ,
				    retorno_liq.fecha :: date,
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
				    retorno_liq.no_aval,
				    retorno_liq.cuota_manejo,
				    _userLogin,
				    recordPresolicitudes.creation_date
				    FROM eg_liquidador_api(recordPresolicitudes.monto_credito::numeric,
								recordPresolicitudes.numero_cuotas::integer,
								recordPresolicitudes.fecha_pago::date,
								recordPresolicitudes.id_convenio::integer,
								recordPresolicitudes.afiliado::varchar) as retorno_liq;

			--12.)ACTUALIZAMOS EL ESTADO DE LA PRESOLICITUD.
			UPDATE apicredit.pre_solicitudes_creditos
			  SET estado_sol='P'
			WHERE numero_solicitud=nuevoNumeroSolicitud
			AND reg_status='' AND estado_sol='B';

			--13.)	CREAMOS EL NEGOCIO DEL NUEVO CREDITO
			retorno:= apicredit.eg_generar_negocio_credito(nuevoNumeroSolicitud::integer,
								     _userLogin::character varying,
								     recordPresolicitudes.financia_aval::boolean,
								     recordPresolicitudes.entidad::character varying,
								     'N'::character varying,
								     'N'::character varying,
								     '{}'::text[]) AS retorno_neg;


			UPDATE apicredit.pre_solicitudes_creditos SET etapa=4 ,extracto_electronico='N' , recoge_firmas='N'
			WHERE numero_solicitud=nuevoNumeroSolicitud;


		ELSE
			retorno:='ENTRAMITE';
		END IF;

	ELSE
		retorno:='NULL';
	END IF;

	return retorno;

EXCEPTION
	WHEN unique_violation THEN
	RAISE EXCEPTION 'Error Insertando en la bd, ya existe en la base de datos.';
	retorno='FAIL' ;
	return retorno;


END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.eg_clonar_solicitud_credito(integer, integer, character varying)
  OWNER TO postgres;
