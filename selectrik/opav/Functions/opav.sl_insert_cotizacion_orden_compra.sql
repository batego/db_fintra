-- Function: opav.sl_insert_cotizacion_orden_compra(character varying)

-- DROP FUNCTION opav.sl_insert_cotizacion_orden_compra(character varying);

CREATE OR REPLACE FUNCTION opav.sl_insert_cotizacion_orden_compra(id_solicitud_ character varying)
  RETURNS text AS
$BODY$

DECLARE

EXISTE VARCHAR;
ID_COTIZACION VARCHAR := '';
INFO_SOLICITUD record;
DETALLE_COTIZACION RECORD;
resultado text := 'ok';
ID_SC INTEGER;

BEGIN
	/*====SE VERIFICA SI LA COTICION YA EXISTE EN LA TABLA DE ORDEN DE COMPRA=====*/
	select INTO EXISTE coalesce((select 'SI'::VARCHAR from opav.sl_solicitud_ocs WHERE id_solicitud = id_solicitud_),'NO');

	select INTO INFO_SOLICITUD *
	from usuario_view_dblink usu
	inner join  ofertas  ofe on (ofe.responsable = usu.nit)
	where id_solicitud = id_solicitud_;
	raise notice 'ID_COTIZACION %',ID_COTIZACION;

	SELECT INTO ID_COTIZACION coalesce (
	(
		select cod_cotizacion from opav.sl_cotizacion_oc_dblink_hc(id_solicitud_) as
			(tipo_insumo character varying, codigo_material character varying, descripcion character varying, id_unidad_insumo integer,
			nombre_unidad_medida character varying, costo_unitario numeric, total_pedido numeric, insumo_adicional character varying,
			id_accion character varying, id_solicitud character varying, cod_cotizacion character varying, nit_responsable character varying,
			responsable character varying) limit 1),'');
	raise notice 'ID_COTIZACION %',ID_COTIZACION;
	IF(EXISTE = 'NO' )THEN

		/*====SE INSERTA EN LA CABECERA SEGUN LA TABLA DE COTIZACION REALIZADA EN SELECTRIK=====*/
		insert into opav.sl_solicitud_ocs (cod_solicitud, responsable, id_solicitud,tiposolicitud, bodega, descripcion, fecha_actual, estado_solicitud, cot_tercerizada, creation_user)
		values ( opav.get_serie_solicitud_ocs(1),INFO_SOLICITUD.idusuario, id_solicitud_, 1, 1, INFO_SOLICITUD.descripcion, now(), 1, ID_COTIZACION, 'ADMIN')
		RETURNING id INTO ID_SC;

		raise notice 'ID_SC %',ID_SC;
		/*====SE INSERTA EL DETALLE SEGUN LA TABLA DE COTIZACION REALIZADA EN SELECTRIK=====*/
		insert into opav.sl_solicitud_ocs_detalle (id_solicitud_ocs, responsable, id_solicitud,tipo_insumo, codigo_insumo, descripcion_insumo,
		id_unidad_medida, nombre_unidad_insumo,costo_unitario, total_pedido, insumo_adicional, creation_date,creation_user)
		select ID_SC, coalesce(responsable,'No Existe'), id_solicitud_, tipo_insumo, codigo_material, descripcion, id_unidad_insumo, nombre_unidad_medida, costo_unitario,
		total_pedido, insumo_adicional, now(),'ADMIN'
		from (
			select * from opav.sl_cotizacion_oc_dblink_hc(id_solicitud_) as
			(tipo_insumo character varying, codigo_material character varying, descripcion character varying, id_unidad_insumo integer,
			nombre_unidad_medida character varying, costo_unitario numeric, total_pedido numeric, insumo_adicional character varying,
			id_accion character varying, id_solicitud character varying, cod_cotizacion character varying, nit_responsable character varying,
			responsable character varying)) as a
		where a.id_solicitud = id_solicitud_;

	END IF;



	return resultado;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_insert_cotizacion_orden_compra(character varying)
  OWNER TO postgres;
