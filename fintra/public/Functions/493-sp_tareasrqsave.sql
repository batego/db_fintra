-- Function: sp_tareasrqsave(integer, character varying, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION sp_tareasrqsave(integer, character varying, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_tareasrqsave(rqis integer, usuarioatiende character varying, tipotarea integer, idtask integer, descriptask character varying, fchinicioestimada character varying, fchfinestimada character varying, horasestimadas character varying, fchculminacion character varying, horasreproceso character varying, creationuser character varying)
  RETURNS character varying AS
$BODY$
--RETURNS void AS $$

DECLARE

	ValidarEstado record;

	BolsaRop numeric := 0;
	_Reproceso numeric := 0;
	_HorasReproceso numeric := 0;
	_DiffDate numeric := 0;

	_EstadoTarea integer := 1;
	_EstadoRq integer := 1;

	NumeroIngreso varchar := '';

	_FchInicioEstimada timestamp without time zone;
	_FchFinEstimada timestamp without time zone;
	_FchCulminacion timestamp without time zone;

	fecha_hoy date;
	_FchCierre timestamp without time zone;

	mcad TEXT := 'BAD';

BEGIN

	--VALIDAMOS QUE:
	--a) No haya sido aprobada por la gerencia.
	--b) Cambiamos el estado de la requisicion completamente.
	--c) Estado de la tarea
	--d) ...

	_HorasReproceso = HorasReproceso::numeric;
	raise notice '_HorasReproceso: %', _HorasReproceso;

	--INSERTAMOS LA TAREA O ACTIVIDAD
	IF ( IdTask = 0 ) THEN

		_FchInicioEstimada = (FchInicioEstimada || ' 08:00:00')::timestamp without time zone;
		_FchFinEstimada = (FchFinEstimada || ' 18:00:00')::timestamp without time zone;
		_FchCulminacion = (FchCulminacion || ' 18:00:00')::timestamp without time zone;

		raise notice '_FchInicioEstimada: %, _FchFinEstimada: %', _FchInicioEstimada, _FchFinEstimada;

		INSERT INTO tareas_requisicion(
			id_requisicion, id_usuario_atiende, id_tipo_tarea,
			descripcion, fecha_inicio_estimada, fecha_fin_estimada, horas_estimadas,
			fecha_culminacion, horas_reproceso, id_estado_tarea, creation_date, creation_user)
		VALUES (Rqis, (SELECT id_usuario FROM rel_proceso_interno_usuario where login = UsuarioAtiende and proceso_principal = 'S'), TipoTarea,
			DescripTask, _FchInicioEstimada::timestamp without time zone, _FchFinEstimada::timestamp without time zone, HorasEstimadas,
			_FchCulminacion, _HorasReproceso, 1, now(), CreationUser);

		IF FOUND THEN mcad = 'OK'; ELSE mcad = 'BAD'; END IF;

	ELSE
		--El campo: id_estado_tarea, se actualizará si éste tiene fecha de culminación

		--raise notice 'FchCulminacion: %', FchCulminacion;
		IF ( FchCulminacion != '0099-01-01' ) THEN

			_DiffDate = (select FchCulminacion::date - FchInicioEstimada::date)*8.5::numeric;
			--raise notice '_DiffDate: %', _DiffDate;
			if ( (_DiffDate - HorasEstimadas::numeric ) > 0 ) then

				SELECT INTO _Reproceso abs(HorasEstimadas::numeric - ((FchCulminacion::date - FchInicioEstimada::date)::numeric*8.5));
				--raise notice 'FchCulminacion: %, FchInicioEstimada: %', FchCulminacion::date, FchInicioEstimada::date;
				--raise notice 'HorasEstimadas: %, Resta: %', HorasEstimadas, (FchCulminacion::date - FchInicioEstimada::date)::numeric;
				_HorasReproceso = _Reproceso;
			else
				_HorasReproceso = 0;
			end if;
			_EstadoTarea = 2;
			_FchCulminacion = (FchCulminacion || ' 18:00:00')::timestamp without time zone;
		ELSE
			_HorasReproceso = 0;
			_EstadoTarea = 1;
			_FchCulminacion = '0099-01-01 18:00:00';
		END IF;

		--raise notice '_HorasReproceso: %', _HorasReproceso;

		_FchInicioEstimada = (FchInicioEstimada || ' 08:00:00')::timestamp without time zone;
		_FchFinEstimada = (FchFinEstimada || ' 18:00:00')::timestamp without time zone;

		UPDATE tareas_requisicion
		SET
			descripcion = DescripTask,
			fecha_inicio_estimada = _FchInicioEstimada::timestamp without time zone, --FchInicioEstimada::date,
			fecha_fin_estimada = _FchFinEstimada::timestamp without time zone, --FchFinEstimada::date,
			horas_estimadas = HorasEstimadas,
			fecha_culminacion = _FchCulminacion::timestamp without time zone, --FchCulminacion::date,
			horas_reproceso = _HorasReproceso,
			last_update = now(),
			user_update = CreationUser,
			id_estado_tarea = _EstadoTarea
		WHERE id = IdTask;

		IF FOUND THEN mcad = 'OK'; ELSE mcad = 'BAD'; END IF;

	END IF;

	IF ( mcad = 'OK' ) THEN

		SELECT INTO ValidarEstado
			count(0) as total_tareas,
			(select count(0) from tareas_requisicion where id_requisicion = Rqis and fecha_culminacion not in ('0099-01-01 18:00:00','0099-01-01 00:00:00')) as tareas_resueltas
		FROM tareas_requisicion tr
		WHERE id_requisicion = Rqis;

		IF ( ValidarEstado.total_tareas = ValidarEstado.tareas_resueltas ) THEN
			_EstadoRq = 2; _FchCierre = now();
		ELSE
			_EstadoRq = 1; _FchCierre = null;
		END IF;

		UPDATE requisicion
		SET
			tipo_tarea = 1,
			orden_priorizacion = (case when requisicion.orden_priorizacion = 0 then (select MAX(orden_priorizacion)+1 from requisicion rq WHERE rq.id_proceso_interno = requisicion.id_proceso_interno) else requisicion.orden_priorizacion end),
			fecha_inicio_estimado = (select min(fecha_inicio_estimada) from tareas_requisicion where id_requisicion = Rqis),
			fecha_fin_estimado = (select max(fecha_fin_estimada) from tareas_requisicion where id_requisicion = Rqis),
			horas_trabajo = (select sum(horas_estimadas::numeric) from tareas_requisicion where id_requisicion = Rqis),
			id_estado_requisicion = _EstadoRq,
			fch_cierre = _FchCierre
		WHERE id = Rqis;

	END IF;


	RETURN mcad;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_tareasrqsave(integer, character varying, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
