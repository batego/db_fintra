-- Function: opav.sp_moverkardex(character varying)

-- DROP FUNCTION opav.sp_moverkardex(character varying);

CREATE OR REPLACE FUNCTION opav.sp_moverkardex(sub_oc_ character varying)
  RETURNS character varying AS
$BODY$

DECLARE

	_item record;

BEGIN

	--raise notice 'la sub_orden de compra %', sub_oc_;

	FOR _item in
		select *
		FROM 		opav.sl_orden_compra_servicio 		AS OC
		INNER JOIN 	opav.sl_ocs_detalle			AS OCD 		ON (OC.id		=	OCD.id_ocs)
		where OC.COD_OCS =sub_oc_ and cantidad_solicitada >0
	loop

		perform * from opav.sl_kardex where cod_material = _item.codigo_insumo  and unidad = _item.id_unidad_medida;

		IF FOUND THEN
			UPDATE opav.sl_kardex set cantidad = (_item.cantidad_solicitada + cantidad::numeric(10,4))::numeric(10,4), user_update = _item.responsable, last_update = now() where  cod_material = _item.codigo_insumo  and unidad = _item.id_unidad_medida;
		else
			INSERT INTO opav.sl_kardex(
				     id_bodega, cod_material, unidad, cantidad, creation_date,
				    creation_user, descripcion_material)
			    VALUES ( _item.bodega, _item.codigo_insumo, _item.id_unidad_medida, _item.cantidad_solicitada, now(),
					_item.responsable, _item.descripcion_insumo);
			raise notice 'Negativo====>>>> %', _item;
		END IF;

	end loop;

	RETURN 'OK';
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_moverkardex(character varying)
  OWNER TO postgres;
