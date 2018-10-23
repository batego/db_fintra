CREATE OR REPLACE FUNCTION insertar_pre_solicitud_libranza()
		RETURNS "trigger" AS $$
DECLARE
		/************************************************************************
		*   AUTHOR JDBERMUDEZ                                                   *
		*   DATE: 16-08-2018                                                    *
		*   DESCRIPTION: inserta la presolicitud de libranza cuando se guarda   *
		*                la informacion del formulario de microcredito.         *
		*************************************************************************/
		num_solicitud INTEGER;
		tel           CHARACTER VARYING;
BEGIN

		IF (new.telefono IS NULL OR new.telefono = '')
		THEN
				tel := new.celular;
		ELSE
				tel := new.telefono;
		END IF;

		IF tg_op = 'INSERT'
		THEN
				--GENERAR Y ASIGNAR EL NUMERO DE SOLICITUD DE LA PRE-SOLICITUD A LA TABLA FILTRO_LIBRANZA
				num_solicitud := get_lcod('SOLICITUD_AVAL');
				new.numero_solicitud := num_solicitud;


				INSERT INTO apicredit.pre_solicitudes_creditos(dstrct,
				                                               numero_solicitud,
				                                               producto,
				                                               entidad,
				                                               valor_cuota,
				                                               valor_aval,
				                                               fecha_credito,
				                                               monto_credito,
				                                               numero_cuotas,
				                                               tipo_identificacion,
				                                               identificacion,
				                                               primer_nombre,
				                                               primer_apellido,
				                                               fecha_nacimiento,
				                                               telefono,
				                                               ingresos_usuario,
				                                               id_convenio,
				                                               estado_sol,
				                                               departamento,
				                                               creation_date,
				                                               creation_user,
				                                               lat,
				                                               lng,
				                                               asesor
				                                              )
				VALUES (new.dstrct,
				        num_solicitud,
				        '01',
				        'LIBRANZA',
				        new.valor_cuota,
				        0,
				        new.creation_date,
				        new.valor_solicitado,
				        new.plazo,
				        'CED',
				        new.identificacion,
				        new.primer_nombre,
				        new.primer_apellido,
				        new.fecha_nacimiento,
				        tel,
				        (new.salario + new.otros_ingresos),
				        new.id_configuracion_libranza,
				        'P',
				        'ATL',
				        new.creation_date,
				        new.creation_user,
				        '11.016615',
				        '-74.831120',
				        new.creation_user
				       );
		ELSEIF tg_op = 'UPDATE'
				THEN
						UPDATE apicredit.pre_solicitudes_creditos
						SET dstrct           = new.dstrct,
								valor_cuota      = new.valor_cuota,
								valor_aval       = 0,
								fecha_credito    = new.last_update,
								monto_credito    = new.valor_solicitado,
								numero_cuotas    = new.plazo,
								identificacion   = new.identificacion,
								primer_nombre    = new.primer_nombre,
								primer_apellido  = new.primer_apellido,
								fecha_nacimiento = new.fecha_nacimiento,
								telefono         = tel,
								ingresos_usuario = (new.salario + new.otros_ingresos),
								id_convenio      = new.id_configuracion_libranza,
								departamento     = 'ATL',
								last_update      = new.last_update,
								user_update      = new.user_update,
								estado_sol       = 'P'
								where numero_solicitud = old.numero_solicitud;
		END IF;

		RETURN new;

END;
$$
LANGUAGE plpgsql
VOLATILE;