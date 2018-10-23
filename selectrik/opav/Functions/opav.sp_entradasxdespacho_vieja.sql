-- Function: opav.sp_entradasxdespacho_vieja(character varying, character varying)

-- DROP FUNCTION opav.sp_entradasxdespacho_vieja(character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_entradasxdespacho_vieja(_coddespacho character varying, _user character varying)
  RETURNS text AS
$BODY$

DECLARE

	RsMigacion record;

	_grupo_transaccion numeric;
	_transaccion numeric;

	_IdInv integer;

	Respuesta text;
	LoteResptaPreOCS record;
	RsDespacho record;

	NoMovimiento varchar := '';

BEGIN
	Respuesta = 'POSITIVO';


	raise notice '_CodDespacho: %', _CodDespacho;

	select into RsDespacho * from opav.sl_despacho_ocs where cod_despacho = _CodDespacho;
	raise notice 'RsDespacho: %', RsDespacho;

	NoMovimiento := opav.get_serie_inventario(1);
	raise notice 'NoMovimiento: %', NoMovimiento;

	if ( FOUND ) then

		INSERT INTO opav.sl_inventario(
			    reg_status, dstrct, id_solicitud, id_bodega, id_bodega_destino, id_tipo_movimiento,
			    cod_movimiento, cod_ocs, cod_despacho, cod_proveedor, responsable, observacion,
			    fecha_movimiento, estado_plenitud, estado_traslado_apoteosys,
			    creation_date, creation_user, last_update, user_update)
		    VALUES ('', 'FINV', '', 1, 1, 1,
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
ALTER FUNCTION opav.sp_entradasxdespacho_vieja(character varying, character varying)
  OWNER TO postgres;
