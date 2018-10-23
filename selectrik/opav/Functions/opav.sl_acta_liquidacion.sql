-- Function: opav.sl_acta_liquidacion(character varying, character varying)

-- DROP FUNCTION opav.sl_acta_liquidacion(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sl_acta_liquidacion(id_solicitud_ character varying, lotes character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE

_id_accion numeric;
_id_cotizacion numeric;
_cotos_indirectos numeric;
_ivaCompensar numeric;
_perc_iva_compensar numeric;
_iva_material numeric;
_nombre_distribucion varchar := '';
 cotizacion record;
 rs_1 record;




 BEGIN

--select sum(w.total ) from (select * from opav.sl_acta_liquidacion('924241') as (id_area int, nombre_area character varying,id_capitulo int,nombre_capitulo character varying, id_apu int,nombre_apu text, unidad_medida_apu character varying,cantidad_apu numeric,id_insumo int,tipo_insumo character varying,descripcion_insumo text,unidad_medidad_insumo int,nombre_unidad_insumo character varying,cantidad_insumo numeric,rendimiento_insumo numeric,valor_unitario numeric, total numeric)) as w;

		--SE OBTIENE LA ACCION PRINCIPAL RELACIONADA CON EL ID_SOLICITUD. _ID_ACCION
		SELECT
			id_accion INTO _id_accion
		from
			opav.acciones
		where
			id_solicitud = id_solicitud_
			and accion_principal = 1;

		--SE OBTIENE EL VALOR TOTAL DE LA ADMINISTRACION. _COTOS_INDIRECTOS
		SELECT
			 coalesce(sum(valor_total),0) INTO _cotos_indirectos
		from
			opav.sl_costos_admon_proyecto
		where
			num_solicitud = id_solicitud_ AND reg_status = '';


		--SE INGRESAN EN EL RECORD RS_1 LOS CAMPOS SUBTOTAL,VALOR_COTIZACION,PERC_ADMINISTRACION,PERC_IMPREVISTO,PERC_UTILIDAD,SUBTOTAL/VALOR_COTIZACION AS TOTALCOMISION QUE SE ENCUENTRAN GUARDADOS EN LA COTIZACION.

		SELECT INTO rs_1
			subtotal,valor_cotizacion,perc_administracion,perc_imprevisto,perc_utilidad,subtotal/valor_cotizacion as totalcomision
		FROM
			opav.sl_cotizacion
		WHERE
			id_accion = _id_accion;


		--OBTENEMOS LA DISTRIBUCION ASOCIADA A LA SOLICITUD
		SELECT INTO _nombre_distribucion trim(distribucion_rentabilidad_esquema) FROM opav.sl_cotizacion where id_accion = _id_accion;

			RAISE NOTICE '_nombre_distribucion:% ',_nombre_distribucion;

		--OBTENEMOS EL _IVACOMPENSAR
		SELECT INTO _perc_iva_compensar round((((0.1588*a.porc_eca/100)+0.0044)+1),4)
		FROM opav.tipo_distribucion_eca a
		LEFT JOIN tablagen b on (a.tipo= b.dato)
		LEFT JOIN tablagen c on (b.table_code = c.table_code)
		WHERE c.table_type ilike ('%tipo_ofert%') and b.reg_status =''
		AND (b.table_code || ' (' || (a.porc_opav + a.porc_fintra + a.porc_interventoria + a.porc_provintegral)::numeric(6,3) || ' - ' || (a.porc_eca)::numeric(6,3) || ')') = 	_nombre_distribucion;

			RAISE NOTICE '_perc_iva_compensar:% ',_perc_iva_compensar;

		--SE OBTIENE EL VALOR DEL IVA_DEL MATERIAL DEL PROYECTO _IVA_MATERIAL
		select coalesce
			(
				(SELECT
				sum(i.valor_esquema *0.19)::numeric(19,2) as IVA_MATERIAL
				FROM opav.sl_relacion_cotizacion_detalle_apu AS i
				INNER JOIN opav.sl_rel_actividades_apu AS f ON (i.id_rel_actividades_apu = f.id)
				INNER JOIN opav.sl_apu AS aa ON (f.id_apu = aa.id)
				INNER JOIN opav.sl_apu_det AS ab ON (aa.id = ab.id_apu and ab.id_insumo = i.id_insumo and ab.id_unidad_medida = i.id_unidad_medida)
				INNER JOIN opav.sl_actividades_capitulos AS e ON (f.id_actividad_capitulo = e.id)
				INNER JOIN opav.sl_capitulos_disciplinas AS d ON (e.id_capitulo = d.id)
				INNER JOIN opav.sl_disciplinas_areas as c ON (d.id_disciplina_area = c.id)
				INNER JOIN opav.sl_areas_proyecto AS b ON (c.id_area_proyecto = b.id)
				INNER JOIN unidad_medida_general AS un ON (aa.id_unidad_medida = un.id)
				WHERE
					i.reg_status=''
				AND
					ab.id_tipo_insumo = 1
				AND
					b.id_solicitud = id_solicitud_),
			0) INTO _iva_material;

		RAISE NOTICE '_iva_material:% ',_iva_material;
		RAISE NOTICE '_cotos_indirectos:% ',_cotos_indirectos;



	--MODALIDAD ES 0 IVA 1 AIU
	if((select modalidad_comercial from opav.sl_cotizacion where id_accion = _id_accion)='0' )
	THEN
		_perc_iva_compensar:=1;
		_cotos_indirectos:=coalesce((_cotos_indirectos/(rs_1.subtotal))+1,1);

	ELSE
		_ivaCompensar := coalesce((rs_1.subtotal+_cotos_indirectos+_iva_material)*(_perc_iva_compensar-1),0);
		_perc_iva_compensar:=coalesce((_ivaCompensar/(rs_1.subtotal+_iva_material))+1,1);
		_cotos_indirectos:=coalesce((_cotos_indirectos/(rs_1.subtotal+_iva_material+_ivaCompensar))+1,1);

	END IF;





	FOR cotizacion IN
	SELECT
            ofe.nombre_proyecto ,
            cli.nomcli  ,
            lote.creation_date::date as Fecha_informe ,
            now()::date AS fecha_impresion ,
            lote.no_lote ,
            lote.descripcion as lote_descripcion,
            areas.id as id_area,
            areas.nombre_area as nombre_area ,
            disci.id as id_disciplina ,
            disci.nombre as nombre_disciplina ,
            cap.id as id_capitulo ,
            cap.descripcion as nombre_capitulo,
            act.id as id_actividad,
            act.descripcion,
            lote_de.id_apu,
            apu.nombre as descripcion_apu,
            w.cantidad_apu_contratada,
            lote_de.unidad_medida_apu,
            round(coalesce(lote_de.cantidad_apu,0),2) as cantidad_apu,
            round(coalesce(lote_de.porc_avance_apu,0),2) as porc_avance_apu,
            round((coalesce(lote_de.cantidad_apu,0)* coalesce(lote_de.porc_avance_apu,0)/100),2) as cantidad_equivalente,
            round(sum((lote_de.cantidad_insumo * lote_de.rendimiento_insumo * lote_de.costo_personalizado)* (
									CASE WHEN cot.modalidad_comercial = 1
									then (
										(CASE WHEN lote_de.tipo_insumo = 'MATERIAL'
											THEN 1.19
										ELSE 1
										END)
										*_perc_iva_compensar
										)
									ELSE 1
									END )
									*_cotos_indirectos),0) as costo_unitario





            FROM
            opav.sl_lote_ejecucion AS lote
            INNER JOIN
            opav.sl_lote_ejecucion_detalle  AS lote_de
            ON (lote.id = lote_de.id_lote_ejecucion )

            INNER JOIN
            opav.ofertas AS ofe
            ON ( lote_de.id_solicitud = ofe.id_solicitud)
            LEFT JOIN
            cliente AS cli
            ON ( ofe.id_cliente  = cli.codcli )
            INNER JOIN
            opav.sl_areas_proyecto AS areas
            ON ( lote_de.id_area = areas.id  )
            INNER JOIN
            opav.sl_disciplinas AS disci
            ON ( lote_de.id_disciplina  = disci.id)
            INNER JOIN
            opav.sl_capitulos_disciplinas  AS cap
            ON ( lote_de.id_capitulo = cap.id  )
            INNER JOIN
            opav.sl_actividades AS act
            ON ( lote_de.id_actividad = act.id  )
            INNER JOIN
            opav.sl_apu AS apu
            ON (lote_de.id_apu = apu.id)

            INNER JOIN
            (
            select
            b.id_apu ,
            b.unidad_medida_apu ,
            sum(cantidad_apu) as cantidad_apu_contratada

            from
            (

            select
            id_apu ,
            unidad_medida_apu ,
            cantidad_apu
            from
            opav.sl_wbs_ejecucion

            where
            id_solicitud =  id_solicitud_
            GROUP BY
            id_apu ,
            unidad_medida_apu ,
            cantidad_apu

            ) as b

            GROUP BY
            id_apu ,
            unidad_medida_apu

            ) AS w
            ON (w.id_apu = lote_de.id_apu and w.unidad_medida_apu = lote_de.unidad_medida_apu)

            where lote.id_solicitud = id_solicitud_ and lote.id in (40,39,38,37,36,35,34,33,22,21)


            group by
            ofe.nombre_proyecto ,
            cli.nomcli  ,


            lote.descripcion ,
            areas.id,
            areas.nombre_area ,
            disci.id ,
            disci.nombre ,
            cap.id ,
            cap.descripcion ,
            act.id ,
            act.descripcion,
            lote_de.id_apu,
            apu.nombre,
	lote.creation_date,
	lote.no_lote ,
            lote_de.unidad_medida_apu,
            lote_de.cantidad_apu,
            lote_de.porc_avance_apu,
            w.cantidad_apu_contratada

            order by
            apu.nombre,
            lote.no_lote

	LOOP

	RETURN NEXT cotizacion;

	END LOOP;

	raise notice '_id_accion :%', _id_accion;
	raise notice 'rs_1 :%', rs_1;
	raise notice '_cotos_indirectos :%', _cotos_indirectos;
	raise notice '_ivaCompensar :%', _ivaCompensar;
	raise notice 'perc_iva_compensar :%', _perc_iva_compensar;
	raise notice 'cotizacion :%', cotizacion;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_acta_liquidacion(character varying, character varying)
  OWNER TO postgres;
