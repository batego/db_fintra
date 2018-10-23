-- Function: arreglar_client_multiple_ws()

-- DROP FUNCTION arreglar_client_multiple_ws();

CREATE OR REPLACE FUNCTION arreglar_client_multiple_ws()
  RETURNS text AS
$BODY$DECLARE
  respuesta TEXT;
  minutos INTEGER;
BEGIN
	SELECT INTO minutos ((difdias*24*60)+(difhoras*60)+difminutos) || '__' || oid
		 AS estado_client_ws
	FROM	(
		SELECT
			EXTRACT ( DAYS FROM NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS difdias,
			EXTRACT ( HOURS FROM NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS difhoras,
			EXTRACT ( MINUTES FROM NOW()-CAST(SUBSTR(condicion,POSITION('-' IN condicion)-4,19) AS TIMESTAMP) ) AS difminutos,

			condicion
			,*
		FROM ws.ws_datos_tablas
		WHERE nombre_tabla LIKE 'SW_%' AND nombre_campo LIKE 'SW_%'
			AND condicion =(SELECT MAX(condicion)
				FROM ws.ws_datos_tablas
				WHERE nombre_tabla LIKE 'SW_%' AND nombre_campo LIKE 'SW_%')
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
ALTER FUNCTION arreglar_client_multiple_ws()
  OWNER TO postgres;
COMMENT ON FUNCTION arreglar_client_multiple_ws() IS 'Arreglar el sw del web service multiple client';
