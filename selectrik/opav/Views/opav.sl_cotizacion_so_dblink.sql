-- View: opav.sl_cotizacion_so_dblink

-- DROP VIEW opav.sl_cotizacion_so_dblink;

CREATE OR REPLACE VIEW opav.sl_cotizacion_so_dblink AS
 SELECT sl_cotizacion_so_dblink.tipo_insumo, sl_cotizacion_so_dblink.codigo_material, sl_cotizacion_so_dblink.id_unidad_insumo, sl_cotizacion_so_dblink.nombre_unidad_medida, sl_cotizacion_so_dblink.costo_unitario, sl_cotizacion_so_dblink.total_pedido, sl_cotizacion_so_dblink.insumo_adicional, sl_cotizacion_so_dblink.id_solicitud, sl_cotizacion_so_dblink.cod_orden, sl_cotizacion_so_dblink.proveedor_nit
   FROM dblink('dbname=provint port=5432 host=181.57.229.83 user=postgres password=bdversion17'::text, '
	SELECT
		''MATERIAL'' as tipo_insumo,
		codigo_producto as codigo_material,
		''18''::INTEGER as id_unidad_insumo,
		tipo_unidad as nombre_unidad_medida,
		vlr_unitario as costo_unitario,
		cantidad as total_pedido,
		''N''::varchar as insumo_adicional,
		ordencompra.multiservicio as id_solicitud,
		ordencompra.cod_orden,
		orden.proveedor_nit
	FROM ordencompra ordencompra
	inner join orden on (orden.consecutivo = ordencompra.cod_orden)
	WHERE  ordencompra.reg_status = ''''
	--and ordencompra.multiservicio in (select multiservicio from tem.MS2017)v
	and ordencompra.documento_cxp != '''' ;
'::text) sl_cotizacion_so_dblink(tipo_insumo character varying, codigo_material character varying, id_unidad_insumo integer, nombre_unidad_medida character varying, costo_unitario numeric, total_pedido numeric, insumo_adicional character varying, id_solicitud character varying, cod_orden character varying, proveedor_nit character varying);

ALTER TABLE opav.sl_cotizacion_so_dblink
  OWNER TO postgres;
