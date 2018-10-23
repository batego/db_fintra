-- Function: opav.sp_set_wbs_ejecucion_0(integer)

-- DROP FUNCTION opav.sp_set_wbs_ejecucion_0(integer);

CREATE OR REPLACE FUNCTION opav.sp_set_wbs_ejecucion_0(integer)
  RETURNS character varying AS
$BODY$
DECLARE
 _id_solicitud ALIAS FOR $1;
 resultado varchar:='OK';

BEGIN
--select opav.sp_set_wbs_ejecucion_0(924776) as resultado

--select * from opav.sl_wbs_ejecucion where id_solicitud = 924776 and valor_insumo_actual !=0
	--Setiamos valores a 0.
	update opav.sl_wbs_ejecucion
	SET
		cantidad_apu_actual = 0 ,
		valor_insumo_actual= 0 ,
		cantidad_apu_ejecutado = 0,
		cantidad_insumo_actual = 0 ,
		cantidad_insumo_ejecutado = 0 ,
		valor_insumo_ejecutado = 0,
		id_directorio_estados = 0,
		porc_avance_apu = 0
	where id_solicitud = _id_solicitud and id_directorio_estados = 0;

	--Deletiamos los registros de insumos adicionales.

	delete from opav.sl_wbs_ejecucion where id_solicitud = _id_solicitud and id_directorio_estados = 2;

	--Setiamos cantidad_insumo_ejecutado, valor_insumo_ejecutado

	UPDATE
		opav.sl_wbs_ejecucion AS A
	SET
		cantidad_insumo_ejecutado = COALESCE(B.cantidad_insumo_ejecutado,0),
		valor_insumo_ejecutado = COALESCE(B.valor_insumo_ejecutado,0)
	FROM
		(
			select
                                    id_relacion_cotizacion_detalle_apu,
                                    sum(cantidad_insumo_total) as cantidad_insumo_ejecutado ,
                                    sum(valor_insumo_total) as valor_insumo_ejecutado
                            from
                                    opav.sl_lote_ejecucion_detalle
                            where
                                    id_solicitud  = _id_solicitud

                            group by
                                    id_relacion_cotizacion_detalle_apu
                                    ) as B
	where
		A.id_solicitud = _id_solicitud AND
		A.id_relacion_cotizacion_detalle_apu  = B.id_relacion_cotizacion_detalle_apu ;




 RETURN resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_set_wbs_ejecucion_0(integer)
  OWNER TO postgres;
