-- Function: sp_saveactionrq(integer, integer, character varying, character varying, integer, integer)

-- DROP FUNCTION sp_saveactionrq(integer, integer, character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION sp_saveactionrq(rqis integer, idtask integer, descriptask character varying, usuarioatiende character varying, tipotarea integer, estadorq integer)
  RETURNS character varying AS
$BODY$
--RETURNS void AS $$

DECLARE

	RecordRq record;
	EstadoTskRq record;

	HorasEstimadas record; --double precision; --numeric := 0;
	HorasReproceso numeric := 0;
	MetaEficacia numeric := 0;
	_EstadoRq numeric := 0;

	NumeroIngreso varchar := '';
	HoraCompleta varchar := '';
	fecha_hoy date;
	_FchCierre timestamp without time zone; --date;

	mcad TEXT := 'BAD';

BEGIN

	SELECT INTO RecordRq * FROM requisicion WHERE id = Rqis;
	--HorasEstimadas = (now()::date - RecordRq.fch_radicacion::date) * 8.5;
	SELECT into HorasEstimadas date_part('days', now() - RecordRq.fch_radicacion) as dias, date_part('hours', now() - RecordRq.fch_radicacion) as horas, date_part('minute', now() - RecordRq.fch_radicacion) as minutos, date_part('second', now() - RecordRq.fch_radicacion) as segundos;
	--raise notice 'Hora: % Minutos: %, Segundos: %', HorasEstimadas.horas, HorasEstimadas.minutos, HorasEstimadas.segundos;

	HoraCompleta = overlay('00' placing HorasEstimadas.horas from 3-length(HorasEstimadas.horas) for length(HorasEstimadas.horas)) ||':'|| overlay('00' placing HorasEstimadas.minutos from 3-length(HorasEstimadas.minutos) for length(HorasEstimadas.minutos)) ||':'|| overlay('00' placing substring(HorasEstimadas.segundos,1,2) from 3-length(substring(HorasEstimadas.segundos,1,2)) for length(substring(HorasEstimadas.segundos,1,2)));

	if ( HorasEstimadas.dias > 0 ) then
		HorasEstimadas.horas = (HorasEstimadas.dias * 8.5) + HorasEstimadas.horas;
	end if;
	--raise notice 'HorasEstimadas es: % Hoy: %, fch_radicacion: %, HoraCompleta: %', HorasEstimadas.minutos, now(), RecordRq.fch_radicacion, HoraCompleta;

	SELECT INTO MetaEficacia meta_eficacia FROM tipo_requisicion WHERE id = RecordRq.id_estado_requisicion;
	HorasReproceso = @(MetaEficacia - HorasEstimadas.horas);
	raise notice 'HorasReproceso es: %', HorasReproceso;

	SELECT INTO EstadoTskRq * FROM estado_tareas_requisicion WHERE id = EstadoRq;

	--INSERTAMOS LA TAREA O ACTIVIDAD
	IF ( IdTask = 0 ) THEN

		raise notice 'PRIMERO';
		INSERT INTO tareas_requisicion(
			id_requisicion, id_usuario_atiende, id_tipo_tarea,
			descripcion, fecha_inicio_estimada, fecha_fin_estimada, horas_estimadas,
			fecha_culminacion, horas_reproceso, id_estado_tarea, creation_date, creation_user)
		VALUES (Rqis, (SELECT id_usuario FROM rel_proceso_interno_usuario where login = UsuarioAtiende and proceso_principal = 'S'), TipoTarea,
			DescripTask, RecordRq.fch_radicacion, now(), HorasEstimadas.horas,
			now(), HorasReproceso, EstadoTskRq.id, now(), UsuarioAtiende);

		IF FOUND THEN
			mcad = 'OK';
		ELSE
			mcad = 'BAD';
		END IF;

	ELSE
		raise notice 'SEGUNDO';
		raise notice 'Pasa por Uno';

		UPDATE tareas_requisicion
		SET
			descripcion = DescripTask,
			last_update = now(),
			user_update = UsuarioAtiende,
			id_estado_tarea = EstadoTskRq.id
		WHERE id = IdTask;

		IF FOUND THEN mcad = 'OK'; ELSE mcad = 'BAD'; END IF;

	END IF;

	raise notice 'TERCERO, mcad: %', mcad;

	IF ( mcad = 'OK' ) THEN

		IF ( EstadoTskRq.id = 1 ) THEN
			_FchCierre = now();
			_EstadoRq = 1;

		ELSIF ( EstadoTskRq.id = 2 ) THEN
			_FchCierre = now();
			_EstadoRq = 2;
		ELSE
			_FchCierre = null;
			_EstadoRq = 1;

		END IF;

		UPDATE requisicion
		SET
			tipo_tarea = 2, --Este campo solo se actualizará con los parametros 1: TERMINADO ó 2: PENDIENTE.
			fch_cierre = _FchCierre,
			id_estado_requisicion = _EstadoRq  --EstadoRq
		WHERE id = Rqis;

	END IF;

	RETURN mcad;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_saveactionrq(integer, integer, character varying, character varying, integer, integer)
  OWNER TO postgres;
