-- Function: opav.sp_insertar_insumo_adicional(character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_insertar_insumo_adicional(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_insertar_insumo_adicional(id_insumo_ character varying, id_unidad_medida_ character varying, id_relacion_cotizacion_detalle_apu_ character varying, usuario_ character varying)
  RETURNS character varying AS
$BODY$
DECLARE

 rs_1 record;
 rs_2 record;
 insumo record;
 resultado varchar:='OK';



 BEGIN



		--SE OBTIENEN LOS DATOS DEL INSUMO ADICIONAL

		SELECT INTO rs_1
			a.id as  id_insumo,
			d.nombre_insumo as tipo_insumo,
			a.descripcion as descripcion_insumo

		FROM
			opav.sl_insumo AS a
		INNER JOIN
			opav.sl_rel_cat_sub AS b
			ON (a.id_subcategoria = b.id)
		INNER JOIN
			opav.sl_categoria AS c
			ON (b.id_categoria = c.id)
		INNER JOIN
			opav.sl_tipo_insumo AS d
			ON (c.id_tipo_insumo= d.id)

		WHERE
			a.id = id_insumo_;

		RAISE NOTICE 'rs_1:% ',rs_1;



		--SE OBTIENEN UNIDAD DE MEDIDA

		select INTO rs_2
		id,
		nombre_unidad
		from
		unidad_medida_general
		where
		id = id_unidad_medida_;

		RAISE NOTICE 'rs_2:% ',rs_2;
		
--		
--  select * from opav.sl_wbs_ejecucion where id_solicitud =
--   (select 
--    id_solicitud
--   from opav.sl_wbs_ejecucion 
--   where  id_relacion_cotizacion_detalle_apu=  3738113 --id_relacion_cotizacion_detalle_apu_
--   group by id_solicitud) and id_directorio_estados=0 and id_insumo = 5248 -- id_insumo_
--   and unidad_medida_insumo = 18 --id_unidad_medida_		
--		
--		
		
		
	  select into insumo *
	  from opav.sl_wbs_ejecucion
	  where id_solicitud =
		   (select 
		    id_solicitud
		   from opav.sl_wbs_ejecucion 
		   where  id_relacion_cotizacion_detalle_apu=  id_relacion_cotizacion_detalle_apu_
		   group by id_solicitud) 
	   and id_directorio_estados = 0 and id_insumo = id_insumo_
	   and unidad_medida_insumo = id_unidad_medida_	;	

		--INSERTAMOS EL INSUMO ADICIONAL
		INSERT INTO opav.sl_wbs_ejecucion (
										   id_solicitud,  			id_area,id_disciplina, 				  id_disciplina_area,
										   id_capitulo,   			id_actividad, 		 				  id_actividades_capitulo,
										   id_rel_actividades_apu,  id_relacion_cotizacion_detalle_apu,   id_cotizacion,
										   id_apu,			        unidad_medida_apu,   				  nombre_unidad_medida_apu,
										   cantidad_apu,	   		id_insumo,		  					  tipo_insumo,
										   descripcion_insumo, 		unidad_medida_insumo, 				  nombre_unidad_insumo,
										   cantidad_insumo,         rendimiento_insumo,                   valor_insumo,
										   costo_personalizado,     cantidad_insumo_total,                valor_insumo_total,
										   perc_contratista,        valor_contratista,                    perc_esquema,
										   valor_esquema,           creation_date,                        creation_user,
										   id_directorio_estados
										   )
									select 
										   a.id_solicitud,			 a.id_area,							  a.id_disciplina,
										   a.id_disciplina_area,	 a.id_capitulo,						  a.id_actividad,
									       a.id_actividades_capitulo,a.id_rel_actividades_apu,			  0,
									       id_cotizacion,			 id_apu,unidad_medida_apu, 	          nombre_unidad_medida_apu,
									       cantidad_apu,			 rs_1.id_insumo,					  rs_1.tipo_insumo,
									       rs_1.descripcion_insumo,  rs_2.id,                             rs_2.nombre_unidad,
									       insumo.cantidad_insumo,   insumo.rendimiento_insumo,           insumo.valor_insumo,
									       insumo.costo_personalizado,insumo.cantidad_insumo_total,       insumo.valor_insumo_total,
									       insumo.perc_contratista,	 insumo.valor_contratista,            insumo.perc_esquema,
									       insumo.valor_esquema,	 now()::date,       	              usuario_,
									       2		    		      		       
		from opav.sl_wbs_ejecucion as a
		where a.id_relacion_cotizacion_detalle_apu = id_relacion_cotizacion_detalle_apu_;

		RETURN resultado;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_insertar_insumo_adicional(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
