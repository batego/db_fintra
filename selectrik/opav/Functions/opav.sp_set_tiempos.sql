-- Function: opav.sp_set_tiempos(character varying, integer, integer)

-- DROP FUNCTION opav.sp_set_tiempos(character varying, integer, integer);

CREATE OR REPLACE FUNCTION opav.sp_set_tiempos(_user_update character varying, _estado_fin integer, _id_solicitud integer)
  RETURNS boolean AS
$BODY$
DECLARE

_respuesta boolean := false;
_time_1 timestamp;




 BEGIN

	--select * from  opav.sp_set_tiempos() as (id_solicitud int , id_etapa int , nombre_etapa character varying, tiempo text ) where tiempo> 0

	select
		incio into _time_1
	from
		opav.sl_trazabilidad_ofertas
	where
		id_solicitud = _id_solicitud order by creation_date desc limit 1;

	update
		    opav.sl_trazabilidad_ofertas
	set
		    last_update =now()
		    ,user_update =_user_update
		    ,estado_fin = _estado_fin
		    ,fin= now()
		    ,delta_time =  (select eg_obtenerhorafecha(now()-_time_1))
	where id = (select id from  opav.sl_trazabilidad_ofertas where id_solicitud = _id_solicitud order by creation_date desc limit 1);

	_respuesta:= true;

	return _respuesta;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_set_tiempos(character varying, integer, integer)
  OWNER TO postgres;
