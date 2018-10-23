-- Function: opav.sl_cotizacion_oc_dblink_hc(character varying)

-- DROP FUNCTION opav.sl_cotizacion_oc_dblink_hc(character varying);

CREATE OR REPLACE FUNCTION opav.sl_cotizacion_oc_dblink_hc(id_solicitud_ character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE


 rs_1 record;




 BEGIN
	FOR rs_1 IN

		 SELECT sl_cotizacion_oc_dblink.tipo_insumo, sl_cotizacion_oc_dblink.codigo_material, sl_cotizacion_oc_dblink.descripcion, sl_cotizacion_oc_dblink.id_unidad_insumo, sl_cotizacion_oc_dblink.nombre_unidad_medida, sl_cotizacion_oc_dblink.costo_unitario, sl_cotizacion_oc_dblink.total_pedido, sl_cotizacion_oc_dblink.insumo_adicional, sl_cotizacion_oc_dblink.id_accion, sl_cotizacion_oc_dblink.id_solicitud, sl_cotizacion_oc_dblink.cod_cotizacion, sl_cotizacion_oc_dblink.nit_responsable, sl_cotizacion_oc_dblink.responsable
		   FROM dblink('dbname=selectrik port=5432 host=localhost user=postgres password=bdversion17'::text, '
			SELECT
				''MATERIAL'' as tipo_insumo,
				cot.codigo_material,
				mat.descripcion,
				''18''::INTEGER as id_unidad_insumo,
				mat.medida as nombre_unidad_medida,
				cot.precio as costo_unitario,
				cot.cantidad as total_pedido,
				''N''::varchar as insumo_adicional,
				cot.id_accion,
				ofe.id_solicitud,
				cod_cotizacion,
				ofe.responsable as nit_responsable,
				usu_resp.idusuario as responsable
			FROM opav.cotizaciondets cot
			INNER JOIN opav.material 		mat ON (mat.cod_material = cot.codigo_material)
			INNER JOIN opav.acciones 		acc on (acc.id_accion = cot.id_accion)
			INNER JOIN opav.ofertas 		ofe on (ofe.id_solicitud = acc.id_solicitud)
			--left JOIN usuarios 			usu_resp on (usu_resp.nit = ofe.responsable)
			left JOIN usuario_view_dblink 			usu_resp on (usu_resp.nit = ofe.responsable)
			where ofe.id_solicitud = '|| id_solicitud_ ||'and  acc.contratista= ''CC011'' and cot.creation_date::date >= ''2017-08-01''::date and cot.reg_status = '''' --and usu_resp.estado = ''A''
		'::text) sl_cotizacion_oc_dblink(tipo_insumo character varying, codigo_material character varying, descripcion character varying, id_unidad_insumo integer, nombre_unidad_medida character varying, costo_unitario numeric, total_pedido numeric, insumo_adicional character varying, id_accion character varying, id_solicitud character varying, cod_cotizacion character varying, nit_responsable character varying, responsable character varying)
	loop
		RETURN NEXT rs_1;
	end loop;



END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_cotizacion_oc_dblink_hc(character varying)
  OWNER TO postgres;
