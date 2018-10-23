-- View: opav.sl_bodega_acciones_view_dblink

-- DROP VIEW opav.sl_bodega_acciones_view_dblink;

CREATE OR REPLACE VIEW opav.sl_bodega_acciones_view_dblink AS
 SELECT sl_bodega_acciones.id, sl_bodega_acciones.id_solicitud, sl_bodega_acciones.id_accion, sl_bodega_acciones.reg_status, sl_bodega_acciones.tipo_bodega, sl_bodega_acciones.descripcion, sl_bodega_acciones.id_contratista, sl_bodega_acciones.cod_ciudad, sl_bodega_acciones.direccion, sl_bodega_acciones.nombre_contacto, sl_bodega_acciones.cargo_contacto, sl_bodega_acciones.telefono1_contacto, sl_bodega_acciones.telefono2_contacto
   FROM dblink('dbname=selectrik port=5432 host=localhost user=postgres password=bdversion7'::text, '
			select
			  bod.id,
			  acc.id_solicitud,
			  acc.id_accion,
			  bod.reg_status,
			  bod.tipo_bodega,
			  bod.descripcion,
			  bod.id_contratista,
			  bod.cod_ciudad,
			  bod.direccion,
			  bod.nombre_contacto,
			  bod.cargo_contacto,
			  bod.telefono1_contacto,
			  bod.telefono2_contacto

			from opav.sl_bodega_terc    as bod
			inner join opav.acciones    as acc  on (bod.id_contratista = acc.contratista)
			where acc.reg_status = '''' acc.contratista != ''CC011''
			;
		'::text) sl_bodega_acciones(id integer, id_solicitud integer, id_accion integer, reg_status character varying, tipo_bodega integer, descripcion character varying, id_contratista character varying, cod_ciudad character varying, direccion character varying, nombre_contacto character varying, cargo_contacto character varying, telefono1_contacto character varying, telefono2_contacto character varying);

ALTER TABLE opav.sl_bodega_acciones_view_dblink
  OWNER TO postgres;
