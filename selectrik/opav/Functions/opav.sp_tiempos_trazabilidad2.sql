-- Function: opav.sp_tiempos_trazabilidad2()

-- DROP FUNCTION opav.sp_tiempos_trazabilidad2();

CREATE OR REPLACE FUNCTION opav.sp_tiempos_trazabilidad2()
  RETURNS SETOF record AS
$BODY$
DECLARE

_tiempos record;




 BEGIN

	update
		opav.sl_trazabilidad_ofertas
	set
		delta_time =  coalesce((select eg_obtenerhorafecha(coalesce(fin,now())::timestamp without time zone,inicio::timestamp without time zone)),'0')::interval;

	FOR _tiempos IN




		SELECT 	id_solicitud,
			id_etapa_oferta ,
			nombre_etapa ,
			estado ,
			nombre_estado ,
			tiempo as real_time,
			SUBSTRING(tiempo,0,strpos(tiempo,':')) AS tiempo_en_horas

		FROM (
		SELECT
			a.id_solicitud,
			a.id_etapa_oferta ,
			b.nombre_etapa ,
			a.estado ,
			c.nombre_estado ,
			sum(a.delta_time) as tiempo
		FROM
			opav.sl_trazabilidad_ofertas AS a
		INNER JOIN opav.sl_etapas_ofertas  AS b
		ON (a.id_etapa_oferta = b.id)
		LEFT JOIN opav.sl_estados_etapas_ofertas AS c
		ON (a.estado = c.id)
		INNER JOIN opav.ofertas as d
		ON (a.id_solicitud = d.id_solicitud and d.nuevo_modulo = 1)
		GROUP BY a.id_solicitud, a.id_etapa_oferta , b.nombre_etapa , a.estado , c.nombre_estado
		ORDER BY a.id_solicitud DESC, a.id_etapa_oferta , b.nombre_etapa , a.estado , c.nombre_estado
		)t

	LOOP






		RETURN NEXT _tiempos;

	END LOOP;



END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_tiempos_trazabilidad2()
  OWNER TO postgres;
