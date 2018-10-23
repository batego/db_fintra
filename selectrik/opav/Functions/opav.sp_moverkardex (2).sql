-- Function: opav.sp_moverkardex(character varying, character varying)

-- DROP FUNCTION opav.sp_moverkardex(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_moverkardex(sub_oc_ character varying, despacho_ character varying)
  RETURNS character varying AS
$BODY$

DECLARE

	_item record;
	_oc record;
	_mensaje text := '';
	_id_solicitud varchar;


BEGIN
	select sc.id_solicitud into _id_solicitud
	from opav.sl_orden_compra_servicio 	as oc
	inner join opav.sl_ocs_detalle 		as oc_d on (oc.id = oc_d.id_ocs)
	inner join opav.sl_solicitud_ocs 	as sc 	on (oc_d.cod_solicitud = sc.cod_solicitud)
	where cod_ocs = sub_oc_ limit 1;

	select * into _oc
	from opav.sl_orden_compra_servicio where COD_OCS =sub_oc_ limit 1;


	--raise notice 'la sub_orden de compra %', _oc;
	--update opav.sl_despacho_ocs set cod_ocs = sub_oc_ where cod_despacho = despacho_;

	FOR _item in

		select
				codigo_insumo , id_unidad_medida , cantidad_recibida , dp.responsable , descripcion_insumo
		from 		opav.sl_despacho_ocs  		as dp
		inner join 	opav.sl_despacho_detalle  	as dpd 	on (dp.id = dpd.id_despacho)
		where dp.cod_despacho =despacho_  and traslado_bodega <> 1

	loop

		perform * from opav.sl_kardex where cod_material = _item.codigo_insumo  and unidad = _item.id_unidad_medida and id_bodega = _oc.bodega and id_solicitud = _id_solicitud;

		IF FOUND THEN

			UPDATE opav.sl_kardex set cantidad = (_item.cantidad_recibida + cantidad::numeric(10,4))::numeric(10,4), user_update = _item.responsable, last_update = now() where  cod_material = _item.codigo_insumo  and unidad = _item.id_unidad_medida;
			raise notice 'entro update';

		else
			INSERT INTO opav.sl_kardex(
				     id_bodega, cod_material, unidad, cantidad, creation_date,
				    creation_user, descripcion_material, id_solicitud)
			    VALUES (  _oc.bodega , _item.codigo_insumo , _item.id_unidad_medida , _item.cantidad_recibida ,
			    now() ,_item.responsable , _item.descripcion_insumo, _id_solicitud);
			    raise notice 'entro insert';
		END IF;

		UPDATE opav.sl_despacho_ocs set  traslado_bodega  = 1  , fecha_traslado_bodega = now()  where cod_despacho = despacho_;
	end loop;

	RETURN 'OK';
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_moverkardex(character varying, character varying)
  OWNER TO postgres;
