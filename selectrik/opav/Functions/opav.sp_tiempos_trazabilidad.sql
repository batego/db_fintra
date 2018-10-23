-- Function: opav.sp_tiempos_trazabilidad()

-- DROP FUNCTION opav.sp_tiempos_trazabilidad();

CREATE OR REPLACE FUNCTION opav.sp_tiempos_trazabilidad()
  RETURNS SETOF record AS
$BODY$
DECLARE

_first_time boolean := true;
_time_1 timestamp := now()::date;
_time_2 timestamp := now()::date;
_time_r interval := '0'::interval;
_id_solicitud integer:=0;
_tiempos record;




 BEGIN
	--select * from  opav.sp_tiempos_trazabilidad() as (id_solicitud int , id_etapa int , nombre_etapa character varying, tiempo text ) where tiempo> 0
	--Se crea una tabla temporal donde se almacenara las solicitudes las etapas y sus tiempos correspondientes.
	/*CREATE TABLE tem.tiempos_trazabilidad_solicitud AS
	(
		SELECT
			a.id_solicitud ,
			b.id as id_etapa,
			b.nombre_etapa,
			'0'::interval AS tiempo
		from (select id_solicitud from opav.sl_trazabilidad_ofertas group by id_solicitud ) as a
		left join opav.sl_etapas_ofertas  as b
		on (1=1)
		order by 1,2
	);

	--Se crea una tabla temporal donde se almacenara los tiempos en las.
	CREATE TABLE tem.tiempos_trazabilidad AS
	(
		SELECT
			id,
			'0'::interval as tiempo
		FROM opav.sl_etapas_ofertas
	);
	*/
	insert into tem.tiempos_trazabilidad_solicitud (id_solicitud,id_etapa,nombre_etapa,tiempo)
		(SELECT
			a.id_solicitud ,
			b.id as id_etapa,
			b.nombre_etapa,
			'0'::interval AS tiempo
		from (select id_solicitud from opav.sl_trazabilidad_ofertas group by id_solicitud ) as a
		left join opav.sl_etapas_ofertas  as b
		on (1=1)
		order by 1,2);

	insert into tem.tiempos_trazabilidad (id,tiempo)
		SELECT
			id,
			'0'::interval as tiempo
		FROM opav.sl_etapas_ofertas ;


	FOR _tiempos IN

		select
			id_solicitud ,
			id_etapa_oferta,
			creation_date
		from
			opav.sl_trazabilidad_ofertas
		order by
			id_solicitud  ,
			creation_date

	LOOP



		IF(_first_time)
		THEN
			raise notice 'WAST :%', _first_time;
			_first_time:=false;
			_id_solicitud := _tiempos.id_solicitud;
			_time_1:= _tiempos.creation_date;
		END IF;



		IF(_id_solicitud != _tiempos.id_solicitud )
		THEN

			--se actualiza la tabla temporal numero 1 con el id_solicitud con lo tiempos de la tabla temporal numero 2.
			update tem.tiempos_trazabilidad_solicitud
				SET tiempo = B.tiempo
			FROM
				(Select * from tem.tiempos_trazabilidad) as B
			where id_etapa = B.id and id_solicitud = _id_solicitud;

			--se resetea los tiempos de la tabla numero 2 a 0.
			update tem.tiempos_trazabilidad set tiempo = '0'::interval;
			_time_1:= _tiempos.creation_date;
		else

			_time_2:= _tiempos.creation_date;
			_time_r:= (select eg_obtenerhorafecha( _time_2, _time_1));

			raise notice '_time_2 :%', _time_2;
			raise notice '_time_1 :%', _time_1;
			raise notice '_time_r :%', _time_r;

			_time_1:= _time_2;

			--se suma los tiempos en la tabla numero dos;
			update tem.tiempos_trazabilidad set tiempo = tiempo + _time_r where id = _tiempos.id_etapa_oferta;



		END IF;

		_id_solicitud := _tiempos.id_solicitud;


		--RETURN NEXT _tiempos;

	END LOOP;

	update tem.tiempos_trazabilidad_solicitud
		SET tiempo = B.tiempo
	FROM
		(Select * from tem.tiempos_trazabilidad) as B
	where id_etapa = B.id and id_solicitud = _id_solicitud;



	FOR _tiempos IN (SELECT id_solicitud , id_etapa , nombre_etapa , tiempo::text FROM  tem.tiempos_trazabilidad_solicitud order by 1,2)LOOP
		RETURN NEXT _tiempos;
	END LOOP;

	DELETE FROM tem.tiempos_trazabilidad;
	DELETE FROM tem.tiempos_trazabilidad_solicitud;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_tiempos_trazabilidad()
  OWNER TO postgres;
