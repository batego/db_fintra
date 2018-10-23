-- Function: arreglar_client_ws()

-- DROP FUNCTION arreglar_client_ws();

CREATE OR REPLACE FUNCTION arreglar_client_ws()
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
		FROM ws.ws_datos_tablas
		WHERE nombre_tabla='ESTADO_CLIENTE' AND nombre_campo='ESTADO_CLIENTE'
	) tem  ;
	IF (minutos>90) THEN
		respuesta='PROBLEM_' || minutos;
		INSERT INTO ws.log_sorpresas_ws(fecha, tabla, llave_primaria, mensaje) VALUES
			(NOW(), 'ESTADO_CLIENTE', 'a veces el cliente de tsp no termina por lo que no coloca Sin procesar...', respuesta);
		UPDATE ws.ws_datos_tablas SET condicion='Sin procesar' || condicion WHERE nombre_tabla='ESTADO_CLIENTE' AND nombre_campo='ESTADO_CLIENTE';
	ELSE
		IF (minutos>4) THEN
			respuesta='RARO_' || minutos;
		ELSE
			respuesta='OK_' || minutos;

		END IF;
	END IF;

  RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION arreglar_client_ws()
  OWNER TO postgres;
COMMENT ON FUNCTION arreglar_client_ws() IS 'Arreglar el sw del web service client';
