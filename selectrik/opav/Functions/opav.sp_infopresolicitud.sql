-- Function: opav.sp_infopresolicitud(character varying)

-- DROP FUNCTION opav.sp_infopresolicitud(character varying);

CREATE OR REPLACE FUNCTION opav.sp_infopresolicitud(codsolicitud character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	result record;
	--_Solicitud record;

 BEGIN

	FOR result IN
		--select * FROM opav.sl_solicitud_ocs
		SELECT
			tiposolicitud,
			(select nombre from opav.sl_tipo_solicitud where id = opav.sl_solicitud_ocs.tiposolicitud) as nombre_tiposol,
			bodega,
			(select descripcion from opav.sl_tipo_bodega where id = opav.sl_solicitud_ocs.tiposolicitud) as nombre_bodega,
			descripcion,
			fecha_actual,
			fecha_entrega,
			id_bodega,
			direccion_entrega
		FROM opav.sl_solicitud_ocs
		WHERE cod_solicitud = CodSolicitud

	LOOP

		--result.responsable = _usuario;
		--result.id_solicitud = _idsolicitud;
		RETURN next result;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_infopresolicitud(character varying)
  OWNER TO postgres;
