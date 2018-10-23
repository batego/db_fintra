-- Function: opav.sp_crearordencs(character varying, character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_crearordencs(character varying, character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_crearordencs(_usuario character varying, _tiposolicitud character varying, _proveedor character varying, _descripcion character varying, _fechaentrega character varying, _direccionentrega character varying, _formapago character varying)
  RETURNS SETOF opav.rs_ordencs AS
$BODY$

DECLARE

	result opav.rs_OrdenCS;

	Sepuede integer;

	OCS varchar;

BEGIN

	result.resultado_accion = 'NEGATIVO';

	--select responsable, cod_solicitud, estado_preocs from opav.sl_preocs group by responsable, cod_solicitud, estado_preocs
	select into Sepuede count(0)
	from (
		select responsable, cod_solicitud, estado_preocs
		from opav.sl_preocs
		where
			responsable = _usuario
			and estado_preocs = 0
			and orden_cs = ''
		group by responsable, cod_solicitud, estado_preocs
	) c;

	raise notice 'Sepuede: %',Sepuede;

	if ( Sepuede > 0 ) then

		if ( _TipoSolicitud = '1' ) then
			OCS := opav.get_lote_ordencs('ORDEN_OC');
		else
			OCS := opav.get_lote_ordencs('ORDEN_OS');
		end if;

		INSERT INTO opav.sl_orden_compra_servicio(
			    reg_status, dstrct, cod_ocs, responsable, id_solicitud, cod_proveedor,
			    tiposolicitud, bodega, direccion_entrega, descripcion, fecha_actual,
			    fecha_entrega, forma_pago, total_insumos, estado_ocs, impreso,
			    enviado_proveedor, creation_date, creation_user, last_update, user_update)
		    VALUES ('', 'FINV', OCS, _usuario, OCS, _Proveedor,
			    _TipoSolicitud::integer, 0, _DireccionEntrega, _Descripcion, now(),
			    _FechaEntrega::date, _FormaPago, 0, '0', '0',
			    '0', now(), _usuario, now(), _usuario);

		IF FOUND THEN

			INSERT INTO opav.sl_ocs_detalle(
				    reg_status, dstrct, id_ocs, responsable, lote_ocs, cod_solicitud,
				    codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
				    id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada, costo_unitario_compra, costo_total_compra,
				    insumo_adicional, creation_date, creation_user, last_update, user_update)
			select '', 'FINV', (select id from opav.sl_orden_compra_servicio where cod_ocs = OCS), _usuario, lote_ocs, cod_solicitud,
			       codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
			       id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada, costo_unitario_compra, costo_total_compra,
			       insumo_adicional, now(), _usuario, now(), _usuario
			from opav.sl_preocs
			where
				responsable = _usuario
				and estado_preocs = 0
				and orden_cs = '';

			IF FOUND THEN

				update opav.sl_preocs
				set
					estado_preocs = '1',
					orden_cs = OCS
				where
					responsable = _usuario
					and estado_preocs = 0
					and orden_cs = '';

				result.resultado_accion = OCS;
			END IF;
		END IF;

	else

		result.resultado_accion = 'NEGATIVO';

	end if;

	RETURN NEXT result;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_crearordencs(character varying, character varying, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
