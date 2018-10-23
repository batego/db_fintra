-- Function: opav.sp_devolversolicitud(character varying)

-- DROP FUNCTION opav.sp_devolversolicitud(character varying);

CREATE OR REPLACE FUNCTION opav.sp_devolversolicitud(_codsc character varying)
  RETURNS SETOF opav.rs_devolverscs AS
$BODY$

DECLARE

	result opav.rs_deleteocs;
	RsGeneral record;

	CodSolicitudSalida varchar := '';
	ValidarProceso integer := 0;

 BEGIN

	--PREGUNTAMOS SI CADA UNA DE LAS SOLICITUDES, TIENE COMPRAS ASOCIADAS.
	select into ValidarProceso count(0) as tutu from (
		select cod_solicitud, orden_cs
		,(select count(0) from opav.sl_ocs_detalle where id_ocs in (select id from opav.sl_orden_compra_servicio where cod_ocs = opav.sl_preocs.orden_cs) and cantidad_solicitada > 0) as valido
		from opav.sl_preocs
		where cod_solicitud = _CodSC
		group by cod_solicitud, orden_cs
		order by cod_solicitud
	) c
	where valido > 0;

	raise notice 'ValidarProceso: %', ValidarProceso;

	--una sola compra - devuelve todo
	IF ( ValidarProceso in (0,1) ) THEN

		raise notice '0.0';

		UPDATE opav.sl_presolicitud_ocs
		SET
		    insumos_solicitados = insumos_solicitados - tabla1.total_pedido
		    ,insumos_disponibles = insumos_disponibles + tabla1.total_pedido
		    ,solicitado_temporal = tabla1.total_pedido
		FROM (

		    select s_ocs_det.codigo_insumo, s_ocs_det.total_pedido, s_ocs_det.id_unidad_medida, s_ocs_det.insumo_adicional
		    from opav.sl_solicitud_ocs_detalle s_ocs_det
		    where s_ocs_det.id_solicitud_ocs = (SELECT id FROM opav.sl_solicitud_ocs WHERE cod_solicitud = _CodSC)

		) tabla1
		WHERE opav.sl_presolicitud_ocs.codigo_insumo = tabla1.codigo_insumo
		and opav.sl_presolicitud_ocs.id_unidad_medida = tabla1.id_unidad_medida
		and opav.sl_presolicitud_ocs.insumo_adicional = tabla1.insumo_adicional
		and id_solicitud_ocs = (SELECT id FROM opav.sl_solicitud_ocs WHERE cod_solicitud = _CodSC);

		IF ( FOUND ) THEN
			raise notice 'A';
			UPDATE opav.sl_presolicitud_ocs SET id_solicitud_ocs = 0, estado_presolicitud = 1, cod_solicitud_devolucion = _CodSC WHERE id_solicitud_ocs = (SELECT id FROM opav.sl_solicitud_ocs WHERE cod_solicitud = _CodSC);

			IF ( FOUND ) THEN
				raise notice 'B';
				UPDATE opav.sl_solicitud_ocs SET estado_solicitud = 2 WHERE cod_solicitud = _CodSC;

				IF ( FOUND ) THEN
					raise notice 'C';
					DELETE FROM opav.sl_solicitud_ocs_detalle WHERE id_solicitud_ocs in (SELECT id FROM opav.sl_solicitud_ocs WHERE cod_solicitud = _CodSC);
					result.respta := 'POSITIVO'; --
				END IF;

			END IF;
		ELSE

			UPDATE opav.sl_solicitud_ocs SET estado_solicitud = 2 WHERE cod_solicitud = _CodSC;

			IF ( FOUND ) THEN
				raise notice 'D';
				DELETE FROM opav.sl_solicitud_ocs_detalle WHERE id_solicitud_ocs in (SELECT id FROM opav.sl_solicitud_ocs WHERE cod_solicitud = _CodSC);
				result.respta := 'POSITIVO'; --
			END IF;

		END IF;

	ELSIF ( ValidarProceso > 1 ) THEN

		UPDATE opav.sl_solicitud_ocs SET estado_solicitud = 3 WHERE cod_solicitud = _CodSC;
		IF ( FOUND ) THEN
			result.respta := 'POSITIVO';
		ELSE
			result.respta := 'NEGATIVO';
		END IF;

	END IF;

	RETURN NEXT result;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_devolversolicitud(character varying)
  OWNER TO postgres;
