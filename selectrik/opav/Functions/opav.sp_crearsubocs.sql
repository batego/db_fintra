-- Function: opav.sp_crearsubocs(character varying)

-- DROP FUNCTION opav.sp_crearsubocs(character varying);

CREATE OR REPLACE FUNCTION opav.sp_crearsubocs(_mdispatch character varying)
  RETURNS text AS
$BODY$

DECLARE

	Rs_Dsptch record;
	RsEmp record;

	Sepuede integer;
	_IdOrdenCS integer;
	NoCSchild integer := 0;
	NewOCS integer := 0;

	_OCS varchar;
	_OrdenCS varchar := '';
	Respuesta text;


BEGIN

	Respuesta = 'NEGATIVO';

	--CONTAR LAS OC QUE VAN PARA SUMAR EL CONSECUTIVO
	SELECT INTO Rs_Dsptch * FROM opav.sl_despacho_ocs WHERE cod_despacho = _mDispatch;

	_OrdenCS = Rs_Dsptch.cod_ocs||'-';
	raise notice '_OrdenCS: %',_OrdenCS;

	SELECT INTO NoCSchild count(0)
	FROM opav.sl_orden_compra_servicio
	WHERE cod_ocs ilike _OrdenCS||'%';

	NewOCS = NoCSchild+1;
	_OCS := _OrdenCS||NewOCS::varchar;
	raise notice '_OCS: %',_OCS;

	INSERT INTO opav.sl_orden_compra_servicio(
		    reg_status, dstrct, cod_ocs, responsable, id_solicitud, cod_proveedor,
		    tiposolicitud, bodega, direccion_entrega, descripcion, fecha_actual,
		    fecha_entrega, forma_pago, total_insumos, estado_ocs, impreso,
		    enviado_proveedor, creation_date, creation_user, last_update, user_update, no_despacho)
	    SELECT
		    reg_status, dstrct, _OCS, responsable, id_solicitud, cod_proveedor,
		    tiposolicitud, bodega, direccion_entrega, descripcion, fecha_actual,
		    fecha_entrega, forma_pago, total_insumos, estado_ocs, impreso,
		    enviado_proveedor, now(), Rs_Dsptch.responsable, now(), Rs_Dsptch.responsable, _mDispatch
	    FROM opav.sl_orden_compra_servicio
	    WHERE cod_ocs = Rs_Dsptch.cod_ocs
	RETURNING id INTO _IdOrdenCS;

	IF FOUND THEN

		raise notice 'A';
		SELECT INTO RsEmp * FROM opav.sl_ocs_detalle WHERE id_ocs in (select id from opav.sl_orden_compra_servicio where cod_ocs = Rs_Dsptch.cod_ocs) AND cantidad_solicitada > 0 limit 1;

		INSERT INTO opav.sl_ocs_detalle(
			    reg_status, dstrct, id_ocs, responsable, lote_ocs, cod_solicitud,
			    codigo_insumo, descripcion_insumo, referencia_externa, observacion_xinsumo,
			    id_unidad_medida, nombre_unidad_insumo, cantidad_solicitada, costo_unitario_compra, costo_total_compra,
			    insumo_adicional, creation_date, creation_user, last_update, user_update)
		select '', 'FINV', _IdOrdenCS, Rs_Dsptch.responsable, RsEmp.lote_ocs, RsEmp.cod_solicitud,
		       codigo_insumo, descripcion_insumo, referencia_externa, '',
		       id_unidad_medida, nombre_unidad_insumo, cantidad_recibida, costo_unitario_recibido, costo_total_recibido,
		       'N', now(), Rs_Dsptch.responsable, now(), Rs_Dsptch.responsable
		from opav.sl_despacho_detalle
		where id_despacho in (select id from opav.sl_despacho_ocs where cod_despacho = _mDispatch);

		IF FOUND THEN
			raise notice 'B';
			Respuesta = _OCS;
		END IF;
	END IF;

	RETURN Respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_crearsubocs(character varying)
  OWNER TO postgres;
