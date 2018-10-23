-- Function: opav.sp_whatido(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_whatido(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_whatido(_usuario character varying, _idsolicitud character varying, tiposol character varying, bodegallevar character varying, _descripcion character varying, _fecha_entrega character varying, _direccion_entrega character varying, _id_bodega character varying)
  RETURNS SETOF opav.rs_respuesta_wid AS
$BODY$

DECLARE

	result opav.rs_respuesta_wid;

	EstadoPresolicitud integer;

	_FechaEntrega date := _fecha_entrega::date;
	_TipoSolicitud integer := TipoSol::integer;
	_Bodega integer := BodegaLlevar::integer;
	_Id_Bodega integer := _id_bodega::integer;

	RsptaPrgnt varchar := '';
	CodSol varchar;

BEGIN

	FOR result IN

		select ''::varchar as resultado_operacion

	LOOP

		--SELECT * FROM opav.sl_solicitud_ocs

		SELECT INTO EstadoPresolicitud
			--coalesce(estado_presolicitud,9)
			count(0)
		FROM opav.sl_solicitud_ocs
		WHERE responsable = _usuario
		and id_solicitud = _IdSolicitud
		and estado_solicitud in (0,2);

		if ( EstadoPresolicitud = 0 ) then

			CodSol = opav.get_serie_solicitud_ocs(_TipoSolicitud);

			--CREAMOS POR PRIMERA VEZ
			INSERT INTO opav.sl_solicitud_ocs(
				reg_status, dstrct, cod_solicitud, responsable, id_solicitud,
				tiposolicitud, bodega, descripcion, fecha_actual, fecha_entrega,
				total_insumos, estado_presolicitud, estado_solicitud, creation_date,
				creation_user, last_update, user_update, direccion_entrega, id_bodega)
			VALUES ('', 'FINV', CodSol, _usuario, _IdSolicitud,
				_TipoSolicitud, _Bodega, _descripcion, now(), _FechaEntrega,
				0, 0, 0, now(),
				_usuario, now(), _usuario, _direccion_entrega, _Id_Bodega);

			RsptaPrgnt = CodSol;

		else

			--MANDAMOS MENSAJE DE QUE YA
			RsptaPrgnt = 'EXISTE';

		end if;

		--raise notice 'FechaNegocioCalcular: %', FechaNegocioCalcular;

		result.resultado_operacion = RsptaPrgnt;

		RETURN NEXT result;

	END LOOP;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_whatido(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
