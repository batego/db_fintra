-- Function: opav.sp_entradasxdespacho(character varying, character varying)

-- DROP FUNCTION opav.sp_entradasxdespacho(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_entradasxdespacho(_coddespacho character varying, _user character varying)
  RETURNS text AS
$BODY$

DECLARE

	RsMigacion record;

	_grupo_transaccion numeric;
	_transaccion numeric;

	_IdInv integer;
	_Bodega integer;

	Respuesta text;
	LoteResptaPreOCS record;
	RsDespacho record;

	NoMovimiento varchar := '';
	_Id_solicitud varchar := '';

BEGIN
	Respuesta = 'POSITIVO';


	raise notice '_CodDespacho: %', _CodDespacho;

	select into RsDespacho * from opav.sl_despacho_ocs where cod_despacho = _CodDespacho;
	raise notice 'RsDespacho: %', RsDespacho;

	NoMovimiento := opav.get_serie_inventario(1);
	raise notice 'NoMovimiento: %', NoMovimiento;

	SELECT ocs.bodega,
	       coalesce(sc.id_solicitud, '') INTO _Bodega,
				    _Id_solicitud
	FROM opav.sl_orden_compra_servicio 	AS ocs
	INNER JOIN opav.sl_despacho_ocs 	AS dp  ON (ocs.cod_ocs 		= dp.cod_ocs)
	INNER JOIN opav.sl_ocs_detalle 		AS ocd ON (ocs.id 		= ocd.id_ocs)
	LEFT JOIN opav.sl_solicitud_ocs 	AS sc  ON (ocd.cod_solicitud 	= sc.cod_solicitud)
	WHERE dp.cod_despacho = _coddespacho
	LIMIT 1;

	if ( FOUND ) then

		INSERT INTO opav.sl_inventario(
			    reg_status, dstrct, id_solicitud, id_bodega, id_bodega_destino, id_tipo_movimiento,
			    cod_movimiento, cod_ocs, cod_despacho, cod_proveedor, responsable, observacion,
			    fecha_movimiento, estado_plenitud, estado_traslado_apoteosys,
			    creation_date, creation_user, last_update, user_update)
		    VALUES ('', 'FINV', _Id_solicitud, _Bodega,null, 1,
			    NoMovimiento, RsDespacho.cod_ocs, _CodDespacho, RsDespacho.cod_proveedor, _User, 'ENTRADA A INVENTARIO',
			    RsDespacho.fecha_entrega, 0, 0,
			    now(), _User, now(), _User)
		RETURNING id INTO _IdInv;

		--select into _IdInv id from opav.sl_inventario where cod_movimiento = NoMovimiento;
		raise notice '_IdInv: %', _IdInv;

		INSERT INTO opav.sl_inventario_detalle(
			    reg_status, dstrct, id_inventario, codigo_insumo, descripcion_insumo,
			    referencia_externa, observacion_xinsumo, id_unidad_medida, nombre_unidad_insumo,
			    cantidad, costo_unitario_compra, costo_total_compra, cantidad_recibida, costo_recibido, id_estado_recepcion,
			    creation_date, creation_user, last_update, user_update)
			select '', 'FINV', _IdInv, codigo_insumo, descripcion_insumo,
			       referencia_externa, '', id_unidad_medida, nombre_unidad_insumo,
			       cantidad_recibida, costo_unitario_recibido, costo_total_recibido, cantidad_recibida, costo_total_recibido, 1,
			       now(), _User, now(), _User
			from opav.sl_despacho_detalle
			where id_despacho in (select id from opav.sl_despacho_ocs where cod_despacho = _CodDespacho);
	end if;


	RETURN Respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_entradasxdespacho(character varying, character varying)
  OWNER TO postgres;
