-- Function: arreglar_clientes_ws_tsp_new()

-- DROP FUNCTION arreglar_clientes_ws_tsp_new();

CREATE OR REPLACE FUNCTION arreglar_clientes_ws_tsp_new()
  RETURNS text AS
$BODY$DECLARE
  _respuesta TEXT;
  _informe TEXT;
  _minutos_pasados INTEGER;
  _nombre_tabla character varying(100);
  _nombre_campo character varying(100);
  _group RECORD;
  _caso TEXT;
BEGIN
 	_respuesta:='';
	_informe:='';
 	_caso:='';
	FOR _group IN
	SELECT /*INTO minutos*/ ((difdias*24*60)+(difhoras*60)+difminutos) AS minutos_pasados,
		nombre_tabla, nombre_campo
	FROM
	(
		SELECT
			EXTRACT ( DAYS FROM NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS difdias,
			EXTRACT ( HOURS FROM NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS difhoras,
			EXTRACT ( MINUTES FROM NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS difminutos,
			condicion ,
			nombre_tabla, nombre_campo
			--,SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP
		FROM ws.ws_datos_tablas w
		WHERE nombre_tabla LIKE 'PROPERTIES%' AND nombre_campo='fintra.last_update'
		      AND EXISTS (SELECT w2.nombre_tabla
				  FROM ws.ws_datos_tablas w2
				  WHERE w2.nombre_tabla=w.nombre_tabla
				  	AND w2.nombre_campo='fintra.sw_tabla'
				  	AND w2.condicion NOT LIKE 'Sin procesar.%'
				  )
	) tem  	--se consulta cantidad de minutos entre ultima ejecucion y fecha actual para los que estan ejecutandose
	LOOP

		_minutos_pasados:=_group.minutos_pasados;
		_nombre_tabla:=_group.nombre_tabla;
		_nombre_campo:=_group.nombre_campo;
		_caso:='_CASO: ' || _nombre_tabla || ' ; ' || 'Minutos: ' || _minutos_pasados || ' ; ';
		IF (_minutos_pasados>34) THEN	--si han pasado mas de 34 minutos
			_respuesta:=_respuesta || '_GRAVE_' || _caso;
			INSERT INTO ws.log_sorpresas_ws(fecha, tabla, llave_primaria, mensaje) VALUES
				(NOW(), 'ESTADO_CLIENTE', _caso, 'a veces el cliente de tsp no termina por lo que no coloca Sin procesar...');--se inserta una sorpresa
			UPDATE ws.ws_datos_tablas SET condicion='Sin procesar..'
			WHERE nombre_tabla=_nombre_tabla AND nombre_campo='fintra.sw_tabla';--se dice que no se esta procesando
			UPDATE ws.ws_datos_tablas SET condicion='alert'
			WHERE nombre_tabla=_nombre_tabla AND nombre_campo='fintra.alarm' ;--se dice que se disparo alarma
		ELSE

			IF (_minutos_pasados>16) THEN --si han pasado mas de 5 minutos

				_respuesta:=_respuesta || '_RARO_' || _caso;
			ELSE --si no han pasado mas de 5 minutos
				_respuesta=_respuesta || '_OK_' || _caso;
			END IF;
		END IF;
	END LOOP;

	IF ( _respuesta != '' ) THEN
	    _informe:=_respuesta;
	ELSE --si no han pasado mas de 5 minutos
	    _informe:='TODO FUNCIONA OK!';
	END IF;



  RETURN _informe;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION arreglar_clientes_ws_tsp_new()
  OWNER TO postgres;
COMMENT ON FUNCTION arreglar_clientes_ws_tsp_new() IS 'Arreglar el sw del web service client version 20100924';
