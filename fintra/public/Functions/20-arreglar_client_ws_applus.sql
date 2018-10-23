-- Function: arreglar_client_ws_applus()

-- DROP FUNCTION arreglar_client_ws_applus();

CREATE OR REPLACE FUNCTION arreglar_client_ws_applus()
  RETURNS text AS
$BODY$DECLARE
  respuesta TEXT;
  minutos INTEGER;
BEGIN
	SELECT INTO minutos /*CASE WHEN */((difdias*24*60)+(difhoras*60)+difminutos)/*>180 THEN 'PROBLEM_' || ((difdias*24*60)+(difhoras*60)+difminutos)*/
		/*WHEN ((difdias*24*60)+(difhoras*60)+difminutos)>60 THEN 'RARO_' || ((difdias*24*60)+(difhoras*60)+difminutos)
		ELSE 'OK_' || ((difdias*24*60)+(difhoras*60)+difminutos)*/
		/*END*/ AS estado_client_ws
	FROM
	(
		SELECT /*SUBSTR(condicion,1,2),now(),
			POSITION('-' IN condicion),
			CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) AS fec_ejecucion,
			 (   NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS dif0,*/
			EXTRACT ( DAYS FROM NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS difdias,
			EXTRACT ( HOURS FROM NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS difhoras,
			EXTRACT ( MINUTES FROM NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS difminutos,

			condicion
		FROM ws.ws_datos_tablas_plus9
		WHERE nombre_tabla='ESTADO_CLIENTE' AND nombre_campo='ESTADO_CLIENTE'
	) tem  ;
	IF (minutos>9) THEN
		respuesta='PROBLEM_' || minutos;
		INSERT INTO ws.log_sorpresas_ws(fecha, tabla, llave_primaria, mensaje) VALUES
			(NOW(), 'ESTADO_CLIENTE', 'a veces el cliente de applus no termina por lo que no coloca Sin procesar...', respuesta);
		UPDATE ws.ws_datos_tablas_plus9 SET condicion='No procesando' || condicion WHERE nombre_tabla='ESTADO_CLIENTE' AND nombre_campo='ESTADO_CLIENTE';
	ELSE
		IF (minutos>2) THEN respuesta='RARO_' || minutos;
		ELSE respuesta='OK_' || minutos;
		END IF;
	END IF;

  RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION arreglar_client_ws_applus()
  OWNER TO postgres;
COMMENT ON FUNCTION arreglar_client_ws_applus() IS 'Arreglar el sw del web service client applus';
