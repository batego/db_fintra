-- Function: adelantardiferidos(character varying, text[])

-- DROP FUNCTION adelantardiferidos(character varying, text[]);

CREATE OR REPLACE FUNCTION adelantardiferidos(_negocio character varying, _diferidos text[])
  RETURNS text AS
$BODY$
DECLARE
		respuesta        CHARACTER VARYING = '';
		registro         CHARACTER VARYING;
		contador         INT = 0;
		record_diferidos RECORD;
BEGIN
		FOR record_diferidos IN SELECT *
		                        FROM ing_fenalco
		                        WHERE codneg = _negocio AND cod = ANY (_diferidos :: TEXT []) LOOP
				RAISE NOTICE 'DIFERIDO %', record_diferidos.cod;
				registro = '';
				--Se valida si esta contabilizado (tiene periodo o fecha de contabilizacion)
				IF record_diferidos.periodo IS NULL OR record_diferidos.periodo = '' OR
				   record_diferidos.fecha_contabilizacion = '0099-01-01 00:00:00'
				THEN
						--Se valida si esta marcado por apoteosys
						IF record_diferidos.procesado_dif = 'N'
						THEN
								--Se válida que no esté vencido
								IF record_diferidos.fecha_doc >= CURRENT_TIMESTAMP
								THEN
										--Se actualiza la fecha a la actual
										UPDATE ing_fenalco
										SET fecha_doc = current_timestamp
										WHERE cod = record_diferidos.cod;

										contador := contador + 1;
								ELSE
										registro := registro || 'diferido ' || record_diferidos.cod || ': esta vencido,';
								END IF;
						ELSE
								registro := registro || 'diferido ' || record_diferidos.cod ||
								            ': esta marcado por apoteosys,';
						END IF;
				ELSE
						registro := registro || 'diferido ' || record_diferidos.cod || ': esta contabilizado,';
				END IF;

				RAISE NOTICE 'registro:   %', registro;

				IF registro != ''
				THEN
						respuesta := respuesta || registro;
				END IF;
		END LOOP;

		RAISE NOTICE 'DIFERIDOS %', respuesta;

		IF contador = array_upper(_diferidos, 1)
		THEN
				RETURN 'Diferidos adelantados';
		ELSE
				RETURN respuesta;
		END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION adelantardiferidos(character varying, text[])
  OWNER TO postgres;
