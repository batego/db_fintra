-- Function: opav.sp_wbs_copia(integer, integer, character varying)

-- DROP FUNCTION opav.sp_wbs_copia(integer, integer, character varying);

CREATE OR REPLACE FUNCTION opav.sp_wbs_copia(_id_solicitud_viejo integer, _id_solicitud_nuevo integer, _usuario character varying)
  RETURNS character varying AS
$BODY$
DECLARE
 _id_accion_viejo integer;
 _id_accion_nuevo integer;
 _sl_areas_proyecto record;
 _id_areas_proyecto integer;
 _sl_disciplinas_areas record;
 _id_disciplinas_areas integer;
 _sl_capitulos_disciplinas record;
 _id_capitulos_disciplinas integer;
 _sl_actividades_capitulos record;
 _id_actividades_capitulos integer;
 _sl_actividades record;
 _id_actividades integer;
 _sl_rel_actividades_apu record;
 _id_rel_actividades_apu integer;
 _sl_apu record;
 _id_apu integer;
 _id_apu_det integer;
 _id_cotizacion integer;
 _wast integer;




 resultado varchar := 'OK';


BEGIN
	-- SELECT sp_wbs_copia(924408, 924735 , 'WSIADO');
      RAISE NOTICE 'Id_Solicitud Vieja : %', _id_solicitud_viejo;
      RAISE NOTICE 'Id_Solicitud Nueva : %', _id_solicitud_nuevo;

      _id_accion_viejo := (select id_accion from opav.acciones where id_solicitud = _id_solicitud_viejo and accion_principal = 1);
      _id_accion_nuevo := (select id_accion from opav.acciones where id_solicitud = _id_solicitud_nuevo and accion_principal = 1);

      RAISE NOTICE 'Id_accion Vieja : %', _id_accion_viejo;
      RAISE NOTICE 'Id_accion Nueva : %', _id_accion_nuevo;


	/*INSERT INTO opav.sl_cotizacion (
		id_accion,no_cotizacion,cod_cli,nonmbre_cliente, vigencia_cotizacion,
		forma_visualizacion, modalidad_comercial,
		material, mano_obra, equipos, herramientas, transporte, tramites,
		valor_cotizacion, valor_descuento, subtotal, perc_iva, valor_iva,
		administracion, imprevisto, utilidad, perc_aiu, valor_aiu, perc_administracion,
		perc_imprevisto, perc_utilidad, total, anticipo, perc_anticipo,
		valor_anticipo, retegarantia, perc_retegarantia, creation_date,
		creation_user, perc_descuento, presupuesto_terminado,
		perc_rentabilidad_contratista, valor_rentabilidad_contratista,
		perc_rentabilidad_esquema, valor_rentabilidad_esquema, distribucion_rentabilidad_esquema,
		iva_compensar)

	SELECT
		_id_accion_nuevo as id_accion, no_cotizacion, cod_cli, nonmbre_cliente,
		vigencia_cotizacion, forma_visualizacion, modalidad_comercial,
		material, mano_obra, equipos, herramientas, transporte, tramites,
		valor_cotizacion, valor_descuento, subtotal, perc_iva, valor_iva,
		administracion, imprevisto, utilidad, perc_aiu, valor_aiu, perc_administracion,
		perc_imprevisto, perc_utilidad, total, anticipo, perc_anticipo,
		valor_anticipo, retegarantia, perc_retegarantia, now()::date as creation_date ,
		_usuario as creation_user, perc_descuento, presupuesto_terminado,
		perc_rentabilidad_contratista, valor_rentabilidad_contratista,
		perc_rentabilidad_esquema, valor_rentabilidad_esquema, distribucion_rentabilidad_esquema,
		iva_compensar
		FROM opav.sl_cotizacion
	WHERE
		id_accion = _id_accion_viejo
	RETURNING id INTO _id_cotizacion;*/

      /*************************************INSERTAR LAS AREAS DEL PROYECTO**************************************************/
      FOR _sl_areas_proyecto IN

            SELECT _id_solicitud_nuevo as id_solicitud, id as id_viejo ,nombre_area , now()::date as creation_date ,_Usuario as creation_user
            FROM opav.sl_areas_proyecto
            WHERE id_solicitud = _id_solicitud_viejo and reg_status = ''

      LOOP

            INSERT INTO opav.sl_areas_proyecto (id_solicitud, nombre_area , creation_date, creation_user)
            VALUES (_sl_areas_proyecto.id_solicitud, _sl_areas_proyecto.nombre_area , _sl_areas_proyecto.creation_date, _sl_areas_proyecto.creation_user )
            RETURNING id INTO _id_areas_proyecto;

            RAISE NOTICE 'id_area_proyecto Nuevo : %', _id_areas_proyecto;
            RAISE NOTICE 'id_area_proyecto viejo : %', _sl_areas_proyecto.id_viejo;


            /*************************************INSERTAR EN LA TABLA sl_disciplinas_areas QUE RELACIONA LAS DISCIPLINAS CON LAS AREAS**************************************************/

            FOR _sl_disciplinas_areas IN

                  SELECT _id_areas_proyecto as id_area_proyecto, id as id_viejo , id_disciplina ,now()::date as creation_date ,_Usuario as creation_user
                  FROM opav.sl_disciplinas_areas
                  WHERE id_area_proyecto = _sl_areas_proyecto.id_viejo and reg_status = ''

            LOOP

                  INSERT INTO opav.sl_disciplinas_areas (id_area_proyecto, id_disciplina, creation_date, creation_user)
                  VALUES (_sl_disciplinas_areas.id_area_proyecto , _sl_disciplinas_areas.id_disciplina , _sl_disciplinas_areas.creation_date, _sl_disciplinas_areas.creation_user )
                  RETURNING id INTO _id_disciplinas_areas;

                  RAISE NOTICE '_id_disciplinas_areas Nuevo : %', _id_disciplinas_areas;
                  RAISE NOTICE '_id_disciplinas_areas Viejo : %', _sl_disciplinas_areas.id_viejo;


                  /*************************************INSERTAR CAPITULOS DISCIPLINAS**************************************************/

                  FOR _sl_capitulos_disciplinas IN

                        SELECT _id_disciplinas_areas AS id_disciplinas_area, id as id_viejo , descripcion , now()::date as creation_date ,_Usuario as creation_user
                        FROM opav.sl_capitulos_disciplinas
                        WHERE id_disciplina_area = _sl_disciplinas_areas.id_viejo and reg_status = ''

                  LOOP

                        INSERT INTO opav.sl_capitulos_disciplinas (id_disciplina_area, descripcion, creation_date, creation_user)
                        VALUES (_sl_capitulos_disciplinas.id_disciplinas_area , _sl_capitulos_disciplinas.descripcion , _sl_capitulos_disciplinas.creation_date, _sl_capitulos_disciplinas.creation_user )
                        RETURNING id INTO _id_capitulos_disciplinas;

                        RAISE NOTICE '_sl_capitulos_disciplinas Nuevo : %', _id_capitulos_disciplinas;
                        RAISE NOTICE '_id_capitulos_disciplinas Viejo : %', _sl_capitulos_disciplinas.id_viejo;


                        /*************************************INSERTAR LAS ACTIVIDADES Y LA RELACION CON LOS CAPITULOS DISCIPLINAS**************************************************/

                        FOR _sl_actividades_capitulos IN

                              SELECT _id_capitulos_disciplinas as id_capitulos_disciplinas , A.id as id_capitulos_disciplinas_viejo, A.id_actividad AS id_actividad_viejo , B.descripcion , now()::date as creation_date ,_Usuario as creation_user
                              FROM opav.sl_actividades_capitulos AS A
                              INNER JOIN opav.sl_actividades AS B
                              ON (A.id_actividad = B.id)
                              WHERE A.id_capitulo = _sl_capitulos_disciplinas.id_viejo AND A.reg_status = '' AND B.reg_status = ''

                        LOOP

                              INSERT INTO opav.sl_actividades (descripcion, creation_date, creation_user)
                              VALUES ( _sl_actividades_capitulos.descripcion , _sl_actividades_capitulos.creation_date, _sl_actividades_capitulos.creation_user )
                              RETURNING id INTO _id_actividades;

                              RAISE NOTICE 'id_actividades Nuevo : %', _id_actividades;

                              INSERT INTO opav.sl_actividades_capitulos (id_capitulo, id_actividad, creation_date, creation_user)
                              VALUES (_sl_actividades_capitulos.id_capitulos_disciplinas , _id_actividades , _sl_actividades_capitulos.creation_date, _sl_actividades_capitulos.creation_user )
                              RETURNING id INTO _id_actividades_capitulos;

                              RAISE NOTICE '_id_actividades_capitulos Nuevo : %', _id_actividades_capitulos;
                              RAISE NOTICE '_id_actividades_capitulos Viejo : %', _sl_actividades_capitulos.id_capitulos_disciplinas_viejo;



                              /*************************************************************************************************************************************/
				_wast:=0;
                              FOR _sl_rel_actividades_apu IN

                                    SELECT
                                            _id_actividades_capitulos as id_actividades_capitulos,
                                            a.id as id_sl_rel_actividades_apu_viejo,
                                            a.id_apu as a_id_apu_viejo,
                                            a.cantidad as a_cantidad,
                                            a.estado as a_estado,
                                           'PROYECTO_' || b.nombre as b_nombre,
                                            b.id_unidad_medida as b_unidad_medida,
                                            b.nits_propietario as b_nits_propietario,
                                            b.tipo_apu as   b_tipo_apu,
                                            c.id as c_id_apu_det_viejo,
                                            c.id_insumo as c_id_insumo,
                                            c.id_unidad_medida as c_id_unidad_medida,
                                            c.id_tipo_insumo as c_id_tipo_insumo,
                                            c.cantidad as c_cantidad,
                                            c.rendimiento as c_rendimiento,
                                            now()::date as creation_date ,
                                            _Usuario as creation_user
                                    FROM opav.sl_rel_actividades_apu AS a
                                    INNER JOIN opav.sl_apu AS b
                                    ON (a.id_apu = b.id)
                                    INNER JOIN  opav.sl_apu_det AS c
                                    ON (c.id_apu = b.id )
                                    WHERE A.id_actividad_capitulo = _sl_actividades_capitulos.id_capitulos_disciplinas_viejo AND A.reg_status = '' AND B.reg_status = '' AND C.reg_status = ''

                              LOOP

                                    _id_apu:= coalesce((select id_apu_nuevo from tem.sl_apu_ where id_apu_viejo = _sl_rel_actividades_apu.a_id_apu_viejo),0);
					RAISE NOTICE '**********************%', _id_apu;

                                    IF (_id_apu = 0) THEN

					RAISE NOTICE '****LLEGO********LLEGO********LLEGO********LLEGO********LLEGO********LLEGO********LLEGO********LLEGO****';
					INSERT INTO opav.sl_apu (nombre, id_unidad_medida , nits_propietario , tipo_apu, creation_date, creation_user)
					VALUES ( _sl_rel_actividades_apu.b_nombre , _sl_rel_actividades_apu.b_unidad_medida , _sl_rel_actividades_apu.b_nits_propietario , 'PROYECTO' ,_sl_rel_actividades_apu.creation_date, _sl_rel_actividades_apu.creation_user )
					RETURNING id INTO _id_apu;

					RAISE NOTICE '_id_apu Nuevo : %', _id_apu;
					RAISE NOTICE '_id_apu Viejo : %', _sl_rel_actividades_apu.a_id_apu_viejo;


					INSERT INTO opav.sl_rel_grupo_apu (id_apu , id_grupo_apu , creation_date, creation_user)
					SELECT _id_apu, id_grupo_apu, _sl_rel_actividades_apu.creation_date, _sl_rel_actividades_apu.creation_user
					FROM opav.sl_rel_grupo_apu
					WHERE id_apu = _sl_rel_actividades_apu.a_id_apu_viejo;


					INSERT INTO tem.sl_apu_ (id_solicitud , id_apu_viejo , id_apu_nuevo)
					VALUES(_id_solicitud_viejo , _sl_rel_actividades_apu.a_id_apu_viejo , _id_apu);

                                    END IF;

					INSERT INTO opav.sl_apu_det (id_apu, id_insumo , id_unidad_medida , id_tipo_insumo,  cantidad , rendimiento, creation_date, creation_user)
					VALUES ( _id_apu , _sl_rel_actividades_apu.c_id_insumo , _sl_rel_actividades_apu.c_id_unidad_medida , _sl_rel_actividades_apu.c_id_tipo_insumo ,  _sl_rel_actividades_apu.c_cantidad , _sl_rel_actividades_apu.c_rendimiento , _sl_rel_actividades_apu.creation_date, _sl_rel_actividades_apu.creation_user )
					RETURNING id INTO _id_apu_det;

					RAISE NOTICE '_id_apu_det Nuevo : %', _id_apu_det;

				    RAISE NOTICE 'llego*****2';

				    IF (_wast <> _sl_rel_actividades_apu.id_sl_rel_actividades_apu_viejo) THEN
					    INSERT INTO opav.sl_rel_actividades_apu (id_actividad_capitulo, id_apu , cantidad , estado ,creation_date, creation_user)
					    VALUES ( _sl_rel_actividades_apu.id_actividades_capitulos , _id_apu , _sl_rel_actividades_apu.a_cantidad , _sl_rel_actividades_apu.a_estado ,_sl_rel_actividades_apu.creation_date, _sl_rel_actividades_apu.creation_user )
					    RETURNING id INTO _id_rel_actividades_apu;

					    RAISE NOTICE 'id_rel_actividades_apu Nuevo : %', _id_rel_actividades_apu;
					    _wast:= _sl_rel_actividades_apu.id_sl_rel_actividades_apu_viejo;
                                    END IF;





                              END LOOP;

                        END LOOP;

                  END LOOP;

            END LOOP;

      END LOOP;

      delete from tem.sl_apu_ where id_solicitud = _id_solicitud_viejo;

RETURN resultado;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_wbs_copia(integer, integer, character varying)
  OWNER TO postgres;
