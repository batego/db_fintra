-- Function: opav.sp_createpreocs(character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_createpreocs(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_createpreocs(modocompra character varying, usuario character varying, codigosolicitud character varying, codinsumo character varying)
  RETURNS SETOF opav.rs_create_preocs AS
$BODY$

DECLARE

	result opav.rs_create_preocs;
	rsInfoPreOCS record;

	Sepuede integer;

	LoteOCS varchar := '';

 BEGIN

	result.respta = 'NEGATIVO';

	raise notice 'ModoCompra: %',ModoCompra;

	if ( ModoCompra = 1 ) then

		--select responsable, cod_solicitud, estado_preocs from opav.sl_preocs group by responsable, cod_solicitud, estado_preocs
		select into Sepuede count(0)
		from (
			select responsable, cod_solicitud, estado_preocs
			from opav.sl_preocs
			where responsable = Usuario and estado_preocs = 0
			group by responsable, cod_solicitud, estado_preocs
		) c;

		raise notice 'Sepuede: %',Sepuede;

		if ( Sepuede = 0 ) then

			LoteOCS := opav.get_lote_presolicitud('PRE_PREOCS');

			--MODO COMPRA DE SOLICITUD
			INSERT INTO opav.sl_preocs(
				reg_status, dstrct, lote_ocs, responsable, modo_compra, cod_solicitud,
				tipo_insumo, codigo_insumo, descripcion_insumo, id_unidad_medida,
				nombre_unidad_insumo, cantidad_total, cantidad_solicitada, cantidad_disponible,
				referencia_externa, observacion_xinsumo,
				cantidad_temporal, costo_presupuestado, costo_unitario_compra, costo_total_compra,
				insumo_adicional, creation_date, creation_user, last_update, user_update)
			select
				'', 'FINV', LoteOCS, Usuario, ModoCompra, CodigoSolicitud,
				tipo_insumo, codigo_insumo, descripcion_insumo, id_unidad_medida,
				nombre_unidad_insumo, total_saldo, 0, total_saldo, --total_pedido | total_saldo,
				referencia_externa, observacion_xinsumo,
				0, costo_unitario, costo_unitario, 0,
				insumo_adicional, now(), Usuario, now(), Usuario
			from opav.sl_solicitud_ocs_detalle
			where id_solicitud_ocs = (select id from opav.sl_solicitud_ocs where cod_solicitud = CodigoSolicitud)
			and estado_item = 'N';

			--if ( found ) then result.respta = 'POSITIVO'; end if;
			if ( found ) then

				update opav.sl_solicitud_ocs
				set sol_add = 'S'
				where cod_solicitud = CodigoSolicitud;

				update opav.sl_solicitud_ocs_detalle
				set item_add = 'S'
				where id_solicitud_ocs = (select id from opav.sl_solicitud_ocs where cod_solicitud = CodigoSolicitud)
				and estado_item = 'N';

				if ( found ) then result.respta = 'POSITIVO'; end if;

			else
				result.respta = 'NEGATIVO';
				raise notice 'B';
			end if;

		else

			result.respta = 'NEGATIVO';
			raise notice 'A';

		end if;

	elsif ( ModoCompra = 2 ) then

		select into Sepuede count(0)
		from (
			select responsable, cod_solicitud, estado_preocs
			from opav.sl_preocs
			where responsable = Usuario and estado_preocs = 0
			group by responsable, cod_solicitud, estado_preocs
		) c;

		raise notice 'Sepuede: %',Sepuede;
		if ( Sepuede = 0 ) then

			LoteOCS := opav.get_lote_presolicitud('PRE_PREOCS');

			INSERT INTO opav.sl_preocs(
				reg_status, dstrct, lote_ocs, responsable, modo_compra, cod_solicitud,
				tipo_insumo, codigo_insumo, descripcion_insumo, id_unidad_medida,
				nombre_unidad_insumo, cantidad_total, cantidad_solicitada, cantidad_disponible,
				referencia_externa, observacion_xinsumo,
				cantidad_temporal, costo_presupuestado, costo_unitario_compra,
				costo_total_compra, creation_date, creation_user, last_update, user_update)
			select
			'', 'FINV', LoteOCS, Usuario, ModoCompra, CodigoSolicitud,
			tipo_insumo, codigo_insumo, descripcion_insumo, id_unidad_medida,
			nombre_unidad_insumo, total_saldo, 0, total_saldo, --total_pedido | total_saldo,
			referencia_externa, observacion_xinsumo,
			0, costo_unitario, costo_unitario,
			0, now(), Usuario, now(), Usuario
			from opav.sl_solicitud_ocs_detalle
			where id_solicitud_ocs = (select id from opav.sl_solicitud_ocs where cod_solicitud = CodigoSolicitud)
			and codigo_insumo = CodInsumo
			and estado_item = 'N';

			--if ( found ) then result.respta = 'POSITIVO'; end if;
			if ( found ) then

				update opav.sl_solicitud_ocs_detalle
				set item_add = 'S'
				where id_solicitud_ocs = (select id from opav.sl_solicitud_ocs where cod_solicitud = CodigoSolicitud)
				and codigo_insumo = CodInsumo
				and estado_item = 'N';

				if ( found ) then result.respta = 'POSITIVO'; end if;

			else
				result.respta = 'NEGATIVO';
			end if;

		else

			--PREGUNTA SI HAY REGISTROS Y DESPUES INSERTA
			select into rsInfoPreOCS lote_ocs, responsable, cod_solicitud, estado_preocs
			from opav.sl_preocs
			where responsable = Usuario and estado_preocs = 0
			group by lote_ocs, responsable, cod_solicitud, estado_preocs;

			if ( FOUND ) then

				--MODO COMPRA DE INSUMOS
				INSERT INTO opav.sl_preocs(
					reg_status, dstrct, lote_ocs, responsable, modo_compra, cod_solicitud,
					tipo_insumo, codigo_insumo, descripcion_insumo, id_unidad_medida,
					nombre_unidad_insumo, cantidad_total, cantidad_solicitada, cantidad_disponible,
					referencia_externa, observacion_xinsumo,
					cantidad_temporal, costo_presupuestado, costo_unitario_compra,
					costo_total_compra, creation_date, creation_user, last_update, user_update)
				select
				'', 'FINV', rsInfoPreOCS.lote_ocs, Usuario, ModoCompra, CodigoSolicitud,
				tipo_insumo, codigo_insumo, descripcion_insumo, id_unidad_medida,
				nombre_unidad_insumo, total_saldo, 0, total_saldo, --total_pedido | total_saldo,
				referencia_externa, observacion_xinsumo,
				0, costo_unitario, costo_unitario,
				0, now(), Usuario, now(), Usuario
				from opav.sl_solicitud_ocs_detalle
				where id_solicitud_ocs = (select id from opav.sl_solicitud_ocs where cod_solicitud = CodigoSolicitud)
				and codigo_insumo = CodInsumo
				and estado_item = 'N';

				if ( found ) then

					update opav.sl_solicitud_ocs_detalle
					set item_add = 'S'
					where id_solicitud_ocs = (select id from opav.sl_solicitud_ocs where cod_solicitud = CodigoSolicitud)
					and codigo_insumo = CodInsumo
					and estado_item = 'N';

					if ( found ) then result.respta = 'POSITIVO'; end if;

				else
					result.respta = 'NEGATIVO';
				end if;

			else
				result.respta = 'NEGATIVO';
			end if;

		end if;

	end if;

	RETURN NEXT result;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_createpreocs(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
