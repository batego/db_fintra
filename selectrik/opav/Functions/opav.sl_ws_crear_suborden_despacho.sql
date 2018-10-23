-- Function: opav.sl_ws_crear_suborden_despacho()

-- DROP FUNCTION opav.sl_ws_crear_suborden_despacho();

CREATE OR REPLACE FUNCTION opav.sl_ws_crear_suborden_despacho()
  RETURNS text AS
$BODY$

DECLARE

	DSPCH varchar;
	Respuesta text;

	rsOCompra record;

	_id_despacho integer;
	_bodega character varying;
	_id_subocs integer;
	_consecutivo integer;
	_subOC character varying;

BEGIN

-- truncate opav.sl_orden_compra_servicio_will ;
-- truncate opav.sl_ocs_detalle_will;
-- truncate opav.sl_despacho_ocs_will;
-- truncate opav.sl_despacho_detalle_will;
-- truncate opav.sl_rel_ocs_factura_migracion;
	Respuesta = 'NEGATIVO';

	FOR rsOCompra IN


		select
			oc.id as id_ocs,
			fiel.cod_ocs ,
			replace(substring(fiel.fecha_movimiento::date,1,7),'-','') as periodo,
			fiel.fecha_movimiento::date as fecha_movimiento,
			fiel.cod_factura ,
			oc.responsable,
			oc.cod_proveedor,
			oc.descripcion,
			oc.bodega,
			sum(fiel.valor_total_christina::numeric) 	as costo_total_compra_fiel
		from 		opav.sl_comparar_oc_entradas_manual_fiel		as fiel
		left join 	opav.sl_orden_compra_servicio 		 		as oc on (oc.cod_ocs = fiel.cod_ocs)
		WHERE 	fiel.cod_factura <> '' and fiel.cod_ocs ilike 'oc%'
		and  fiel.cod_ocs not in ( select ocs from opav.sl_rel_ocs_factura_migracion group by 1)
		and replace(substring(fiel.fecha_movimiento::date,1,7),'-','') < 201802
		and oc.responsable is not null
		group by 1,2,3,4,5,6,7,8,9
		order by fiel.cod_ocs , periodo



	LOOP
		raise notice 'rsOCompra.cod_factura   : %', rsOCompra.cod_factura ;


		--contar cuantas sub_ordenes hay de esta orden de compra, para saber cual es la que sigue
		SELECT INTO _consecutivo count(*)
		FROM opav.sl_rel_ocs_factura_migracion
		WHERE ocs = rsOCompra.cod_ocs;

		--raise notice 'Sub_orden de compra '

		 _subOC:=rsOCompra.cod_ocs||'-' ||(_consecutivo+1);

		--se crea la cabecera de la SUB_ORDEN COMPRA
		INSERT INTO opav.sl_orden_compra_servicio_will(
		    reg_status, dstrct, cod_ocs, responsable, id_solicitud, cod_proveedor,
		    tiposolicitud, bodega, direccion_entrega, descripcion, fecha_actual,
		    fecha_entrega, forma_pago, total_insumos, estado_ocs, impreso,
		    enviado_proveedor, creation_date, creation_user, last_update, user_update)
		SELECT
		    reg_status, dstrct,  _subOC , responsable, id_solicitud, cod_proveedor,
		    tiposolicitud, bodega, direccion_entrega, descripcion, rsOCompra.fecha_movimiento,
		    fecha_entrega, forma_pago, total_insumos, estado_ocs, impreso,
		    enviado_proveedor, now(), rsOCompra.responsable, now(), rsOCompra.responsable
		FROM opav.sl_orden_compra_servicio
		WHERE cod_ocs = rsOCompra.cod_ocs
		RETURNING id INTO _id_subocs;



		--raise notice '_OCS: %',_OCS;



		IF FOUND THEN
		raise notice 'rsOCompra.cod_ocs   : %', rsOCompra.cod_ocs ;
			INSERT INTO opav.sl_ocs_detalle_will(
			    reg_status, dstrct, id_ocs, responsable, lote_ocs, cod_solicitud,
			    codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
			    id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada, costo_unitario_compra, costo_total_compra,
			    insumo_adicional, creation_date, creation_user, last_update, user_update)

			select
				'', 'FINV', _id_subocs, rsOCompra.responsable, '0', '0',
				b.codigo_insumo, c.descripcion, '', '',
				19, 'GLOBAL', b.cantidad_movimiento::numeric,
				(case when (b.cantidad_movimiento::numeric >0) then (b.valor_total_christina::numeric/ b.cantidad_movimiento::numeric) else 0 end) ,
				(case when (b.cantidad_movimiento::numeric >0) then (b.valor_total_christina::numeric) else 0 end),
				'N', now(),  substring(rsOCompra.responsable,0,20), now(),  substring(rsOCompra.responsable,0,20)
			FROM 		opav.sl_orden_compra_servicio 			as a
			inner join  	opav.sl_comparar_oc_entradas_manual_fiel 	as b  on (a.cod_ocs = b.cod_ocs)
			left join 	opav.sl_insumo				as c  on (b.codigo_insumo = c.codigo_material)
			WHERE a.cod_ocs = rsOCompra.cod_ocs and b.cod_factura=rsOCompra.cod_factura ;

				--
-- 			INSERT INTO opav.sl_ocs_detalle_will(
-- 			    reg_status, dstrct, id_ocs, responsable, lote_ocs, cod_solicitud,
-- 			    codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
-- 			    id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada, costo_unitario_compra, costo_total_compra,
-- 			    insumo_adicional, creation_date, creation_user, last_update, user_update)
--
-- 			select
-- 				'', 'FINV', _id_subocs, rsOCompra.responsable, COALESCE(bb.lote_ocs,'0'), COALESCE(bb.cod_solicitud,'0'),
-- 				b.codigo_insumo, c.descripcion, '', '',
-- 				coalesce(bba.id_unidad_medida,19), coalesce(bba.nombre_unidad_insumo, 'GLOBAL'), b.cantidad_movimiento::numeric,
-- 				(case when (b.cantidad_movimiento::numeric >0) then (b.valor_total_christina::numeric/ b.cantidad_movimiento::numeric) else 0 end) ,
-- 				(case when (b.cantidad_movimiento::numeric >0) then (b.valor_total_christina::numeric) else 0 end),
-- 				'N', now(),  substring(rsOCompra.responsable,0,20), now(),  substring(rsOCompra.responsable,0,20)
-- 			FROM 		opav.sl_orden_compra_servicio 			as a
-- 			inner join  	opav.sl_comparar_oc_entradas_manual_fiel 	as b  on (a.cod_ocs = b.cod_ocs)
-- 			LEFT JOIN	(select
-- 						id_ocs, lote_ocs , cod_solicitud
-- 					from 	opav.sl_ocs_detalle
-- 					where user_update not ilike '%-%'
-- 					group by 1,2,3) 	 			as bb on (a.id = bb.id_ocs)
-- 			left JOIN	(select
-- 						id_ocs,id_unidad_medida, nombre_unidad_insumo,codigo_insumo
-- 					from 	opav.sl_ocs_detalle
-- 					where user_update not ilike '%-%'
-- 					group by 1,2,3,4) 	 			as bba on (a.id = bba.id_ocs and bba.codigo_insumo = b.codigo_insumo)
-- 			left join 	opav.sl_insumo					as c  on (b.codigo_insumo = c.codigo_material)
-- 			WHERE a.cod_ocs = rsOCompra.cod_ocs and b.cod_factura=rsOCompra.cod_factura ;

--
--
--
-- 			INSERT INTO opav.sl_ocs_detalle_will(
-- 			    reg_status, dstrct, id_ocs, responsable, lote_ocs, cod_solicitud,
-- 			    codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
-- 			    id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada, costo_unitario_compra, costo_total_compra,
-- 			    insumo_adicional, creation_date, creation_user, last_update, user_update)
--
-- 			select
-- 				'', 'FINV', _id_subocs, rsOCompra.responsable, bb.lote_ocs, bb.cod_solicitud,
-- 				b.codigo_insumo, c.descripcion, '', '',
-- 				bb.id_unidad_medida, bb.nombre_unidad_insumo, b.cantidad_movimiento::numeric,
-- 				(case when (b.cantidad_movimiento::numeric >0) then (b.valor_total_christina::numeric/ b.cantidad_movimiento::numeric) else 0 end) ,
-- 				(case when (b.cantidad_movimiento::numeric >0) then (b.valor_total_christina::numeric) else 0 end),
-- 				'N', now(),  substring(rsOCompra.responsable,0,20), now(),  substring(rsOCompra.responsable,0,20)
-- 			FROM 		opav.sl_orden_compra_servicio 			as a
-- 			inner join  	opav.sl_comparar_oc_entradas_manual_fiel_3 	as b  on (a.cod_ocs = b.cod_ocs)
-- 			INNER JOIN	(select
-- 						id_ocs,
-- 						lote_ocs ,
-- 						cod_solicitud,
-- 						id_unidad_medida,
-- 						nombre_unidad_insumo,
-- 						--costo_unitario_compra,
-- 						codigo_insumo
-- 					from 	opav.sl_ocs_detalle
-- 					where user_update not ilike '%-%'
-- 					group by 1,2,3,4,5,6) 	 			as bb on (a.id = bb.id_ocs and bb.codigo_insumo = b.codigo_insumo) --and b.costo_unitario_compra::numeric = bb.costo_unitario_compra::numeric)
-- 			left join 	opav.sl_insumo					as c  on (b.codigo_insumo = c.codigo_material)
-- 			WHERE a.cod_ocs = rsOCompra.cod_ocs and b.cod_factura=rsOCompra.cod_factura ;

		END IF;

		update opav.sl_orden_compra_servicio
		set
			pasar_apoteosys = 'N',
			estado_apoteosys = 'N',
			estado_inclusion = 'N'
		where cod_ocs=rsOCompra.cod_ocs;

		DSPCH := opav.get_lote_despacho('DESPACHO_NO_17'); --Tienes que modificarlo para que arranque en el 20xx; Crear uno para la migracion!

		_BODEGA = (SELECT CASE WHEN (rsOCompra.BODEGA = 1) THEN 'BODEGA PRINCIPAL' ELSE 'BODEGA PROYECTO' END);

		INSERT INTO opav.sl_despacho_ocs_will(
		reg_status, dstrct, cod_despacho, cod_ocs, cod_proveedor,
		responsable, direccion_entrega, descripcion, fecha_actual, fecha_entrega,
		estado_despacho, creation_date, creation_user, last_update, user_update)
		VALUES ('', 'FINV', DSPCH, _subOC, rsOCompra.cod_proveedor,
		rsOCompra.responsable, _bodega, rsOCompra.descripcion ,rsOCompra.fecha_movimiento, now(),
		0, now(), rsOCompra.responsable, now(), rsOCompra.responsable||'-')
		returning id into _id_despacho;



		IF FOUND THEN

			INSERT INTO opav.sl_despacho_detalle_will(
				reg_status, dstrct, id_despacho, id_ocs_detalle, responsable,
				codigo_insumo, descripcion_insumo, referencia_externa, id_unidad_medida,
				nombre_unidad_insumo, cantidad_recibida, costo_unitario_recibido, costo_total_recibido,
				creation_date, creation_user, last_update, user_update)
			SELECT '' , 'FINV' , _id_despacho , ocd.id , ocd.responsable ,
				ocd.codigo_insumo , ocd.descripcion_insumo , ocd.referencia_externa , ocd.id_unidad_medida ,
				ocd.nombre_unidad_insumo , ocd.cantidad_solicitada , ocd.costo_unitario_compra , (ocd.cantidad_solicitada* ocd.costo_unitario_compra)::numeric(15,4) ,
				now(), substring(ocd.responsable,0,15)  , now() , substring(ocd.responsable,0,15)
			FROM opav.sl_ocs_detalle_will as ocd
			WHERE id_ocs = _id_subocs;

		END IF;

		raise notice 'rsOCompra.cod_ocs  :%', rsOCompra.cod_ocs ;
		raise notice '_subOC  :%',_subOC ;
		raise notice 'DSPCH  :%', DSPCH ;
		raise notice 'rsOCompra.cod_factura  :%', rsOCompra.cod_factura;
		raise notice 'rsOCompra.periodo  :%', rsOCompra.periodo ;
		raise notice 'rsOCompra.responsable  :%', rsOCompra.responsable;

		insert into opav.sl_rel_ocs_factura_migracion(ocs , sub_ocs , despacho , factura , periodo , creation_date , creation_user) values
			(rsOCompra.cod_ocs ,_subOC , DSPCH ,  rsOCompra.cod_factura ,   rsOCompra.periodo,  now() ,rsOCompra.responsable  );


	END LOOP;

	RETURN Respuesta;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_ws_crear_suborden_despacho()
  OWNER TO postgres;
