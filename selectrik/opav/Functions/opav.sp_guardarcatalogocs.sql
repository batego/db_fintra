-- Function: opav.sp_guardarcatalogocs(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_guardarcatalogocs(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_guardarcatalogocs(_usuario character varying, _idsolicitud character varying, _tipoinsumo character varying, _codigoinsumo character varying, _descripcioninsumo character varying, _nombreunidadinsumo character varying, _cantidad character varying, _codsolicitud character varying)
  RETURNS SETOF opav.rs_rtacatalogocs AS
$BODY$

DECLARE

	result opav.rs_RtaCatalogOCS;

	Sepuede record;
	_Rs record;
	RsContaInsumos record;

	_ContaPlaza integer := 0;
	_IdUnidadMedida integer;
	EsNuevo integer := 0;

	OCS varchar;
	_NombreUnidadMedida varchar := '';
	insumo_normal varchar := '';
	insumo_add varchar := '';
	es_adicional varchar := '';
	_CdSltud varchar := '';



BEGIN

	result.resultado_accion = 'NEGATIVO';

	select into EsNuevo count(0) from opav.sl_presolicitud_ocs where responsable = _usuario and id_solicitud = _idsolicitud and cod_solicitud_devolucion = _CodSolicitud;
	if ( EsNuevo = 0 ) then _CdSltud = ''; elsif ( EsNuevo > 0 ) then _CdSltud = _CodSolicitud; end if;

	SELECT into Sepuede
		coalesce(count(0),0) as cantidad_insumos,
		coalesce(sum(insumos_total),0) as total_insumos
		,lote_presol
	FROM opav.sl_presolicitud_ocs
	WHERE responsable = _usuario
	and id_solicitud = _idSolicitud
	and id_solicitud_ocs = 0
	and cod_solicitud_devolucion = _CdSltud
	group by lote_presol;

	raise notice 'cantidad_insumos: %',Sepuede.cantidad_insumos;
	--Sepuede.cantidad_insumos = -1;

	if ( Sepuede.cantidad_insumos > 0 ) then

		/*
		select into ContaInsumos count(0) as cuenta_xunidad from (
			select insumo_adicional, count(0) as cuenta_xunidad
			from opav.sl_presolicitud_ocs
			where responsable = _usuario and id_solicitud = _idSolicitud
			and id_solicitud_ocs = 0
			and codigo_insumo = _CodigoInsumo
			group by insumo_adicional
		) c;*/

		FOR RsContaInsumos IN

			select insumo_adicional, count(0) as cuenta_xunidad
			from opav.sl_presolicitud_ocs
			where responsable = _usuario
				and id_solicitud = _idSolicitud
				and id_solicitud_ocs = 0
				and codigo_insumo = _CodigoInsumo
				and cod_solicitud_devolucion = _CdSltud
			group by insumo_adicional

		LOOP

			_ContaPlaza = _ContaPlaza + 1;
			if ( RsContaInsumos.insumo_adicional = 'N' ) then
				es_adicional := 'N';
			else
				es_adicional := 'S';
			end if;

		END LOOP;

		raise notice 'cuenta_xunidad: %', RsContaInsumos.cuenta_xunidad;
		raise notice '_ContaPlaza: %', _ContaPlaza;
		raise notice 'es_adicional: %', es_adicional;

		if ( _ContaPlaza = 0 ) then

			raise notice 'A';
			_IdUnidadMedida = 19;
			_NombreUnidadMedida = 'GLOBAL';

			INSERT INTO opav.sl_presolicitud_ocs(
				reg_status, dstrct, lote_presol, responsable, id_solicitud,
				tipo_insumo,
				codigo_insumo,
				descripcion_insumo, id_unidad_medida,
				nombre_unidad_insumo, costo_personalizado,
				insumos_total, insumos_disponibles, solicitado_temporal, insumo_adicional, cod_solicitud_devolucion,
				creation_date, creation_user, last_update, user_update)
			VALUES(
				'','FINV', Sepuede.lote_presol, _usuario, _idSolicitud,
				_TipoInsumo,
				_CodigoInsumo,
				_DescripcionInsumo, _IdUnidadMedida,
				_NombreUnidadMedida, 1,
				_Cantidad::numeric, _Cantidad::numeric, _Cantidad::numeric, 'S', _CdSltud,
				now(), _usuario, now(), _usuario
			);

			IF FOUND THEN
				result.resultado_accion = 'POSITIVO';
			ELSE
				result.resultado_accion = 'NEGATIVO';
			END IF;


		elsif ( _ContaPlaza = 1 and es_adicional = 'N' ) then

			raise notice 'B';
			select into _Rs * from opav.sl_presolicitud_ocs where responsable = _usuario and id_solicitud = _idSolicitud and codigo_insumo = _CodigoInsumo and cod_solicitud_devolucion = _CdSltud;
			raise notice 'id_unidad_medida: %',_Rs.id_unidad_medida;
			raise notice 'nombre_unidad_insumo: %',_Rs.nombre_unidad_insumo;

			_IdUnidadMedida = _Rs.id_unidad_medida;
			_NombreUnidadMedida = _Rs.nombre_unidad_insumo;

			INSERT INTO opav.sl_presolicitud_ocs(
				reg_status, dstrct, lote_presol, responsable, id_solicitud,
				tipo_insumo,
				codigo_insumo,
				descripcion_insumo, id_unidad_medida,
				nombre_unidad_insumo, costo_personalizado,
				insumos_total, insumos_disponibles, solicitado_temporal, insumo_adicional, cod_solicitud_devolucion,
				creation_date, creation_user, last_update, user_update)
			VALUES(
				'','FINV', Sepuede.lote_presol, _usuario, _idSolicitud,
				_TipoInsumo,
				_CodigoInsumo,
				_DescripcionInsumo, _IdUnidadMedida,
				_NombreUnidadMedida, 1,
				_Cantidad::numeric, _Cantidad::numeric, _Cantidad::numeric, 'S', _CdSltud,
				now(), _usuario, now(), _usuario
			);

			IF FOUND THEN
				result.resultado_accion = 'POSITIVO';
			ELSE
				result.resultado_accion = 'NEGATIVO';
			END IF;

		elsif ( _ContaPlaza = 1 and es_adicional = 'S' ) then

			raise notice 'C';
			UPDATE opav.sl_presolicitud_ocs
			SET
				insumos_total = insumos_total + _Cantidad::numeric,
				insumos_disponibles = insumos_disponibles + _Cantidad::numeric,
				solicitado_temporal = solicitado_temporal + _Cantidad::numeric
			WHERE responsable = _usuario
			      AND id_solicitud = _idSolicitud
			      AND codigo_insumo = _CodigoInsumo
			      and cod_solicitud_devolucion = _CdSltud
			      AND insumo_adicional = 'S';

			IF FOUND THEN
				result.resultado_accion = 'POSITIVO';
			ELSE
				result.resultado_accion = 'NEGATIVO';
			END IF;

		elsif ( _ContaPlaza > 1 ) then

			raise notice 'D';
			UPDATE opav.sl_presolicitud_ocs
			SET
				insumos_total = insumos_total + _Cantidad::numeric,
				insumos_disponibles = insumos_disponibles + _Cantidad::numeric,
				solicitado_temporal = solicitado_temporal + _Cantidad::numeric
			WHERE responsable = _usuario
			      AND id_solicitud = _idSolicitud
			      AND codigo_insumo = _CodigoInsumo
			      and cod_solicitud_devolucion = _CdSltud
			      AND insumo_adicional = 'S';

			IF FOUND THEN
				result.resultado_accion = 'POSITIVO';
			ELSE
				result.resultado_accion = 'NEGATIVO';
			END IF;

		end if;

	else

		result.resultado_accion = 'NEGATIVO';

	end if;

	RETURN NEXT result;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_guardarcatalogocs(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
