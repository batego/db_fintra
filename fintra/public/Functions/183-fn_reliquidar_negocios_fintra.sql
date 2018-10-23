-- Function: fn_reliquidar_negocios_fintra(character varying, numeric, numeric, character varying, numeric, character varying)

-- DROP FUNCTION fn_reliquidar_negocios_fintra(character varying, numeric, numeric, character varying, numeric, character varying);

CREATE OR REPLACE FUNCTION fn_reliquidar_negocios_fintra(_negocio character varying, _valor numeric, _cuota numeric, _fechacuota character varying, _convenio numeric, _usuario character varying)
  RETURNS text AS
$BODY$

DECLARE
		totalesliquidacion RECORD;
		respuesta          VARCHAR;
		_estadonegocio     VARCHAR;
		_TASA 		   NUMERIC;
BEGIN

		DELETE FROM documentos_neg_aceptado
		WHERE cod_neg = _negocio :: VARCHAR;

		SELECT INTO _TASA TASA_INTERES FROM CONVENIOS WHERE ID_CONVENIO=_CONVENIO;

		INSERT INTO documentos_neg_aceptado (
				cod_neg,
				item,
				fecha,
				dias,
				saldo_inicial,
				capital,
				interes,
				valor,
				saldo_final,
				creation_date,
				seguro,
				custodia,
				remesa,
				cuota_manejo,
				valor_aval)
				(
						SELECT
								_negocio :: VARCHAR        AS cod_neg,
								item,
								fecha :: DATE,
								dias,
								saldo_inicial,
								capital,
								interes,
								valor,
								saldo_final,
								NOW()                      AS creation_date,
								seguro,
								custodia,
								remesa,
								cuota_manejo,
								COALESCE(valor_aval, 0.00) AS valor_aval

						FROM
										apicredit.EG_LIQUIDADOR_CREDITOS(_valor :: INTEGER, _cuota :: INTEGER, _fechacuota :: DATE,
										                                 _convenio :: INTEGER));

		SELECT INTO totalesliquidacion
				SUM(capital)  AS capital,
				--VALOR DESEMBOLSO
				SUM(interes)  AS interes,
				SUM(custodia) AS custodia,
				SUM(seguro)   AS seguro,
				SUM(remesa)   AS remesa,
				SUM(valor)    AS valor_cuota,
				--TOTAL PAGADO
				COUNT(0)      AS numcuota,
				MIN(fecha)    AS fecha_pr_cuota,
				valor_aval
		FROM documentos_neg_aceptado
		WHERE cod_neg = _negocio :: VARCHAR --ESTO ES UN PARAMETRO
		      AND reg_status = ''
		GROUP BY valor_aval;


		SELECT INTO _estadonegocio estado_neg FROM negocios
		WHERE cod_neg = _negocio :: VARCHAR;

		IF (_estadonegocio = 'E')
		THEN
				INSERT INTO negocios_trazabilidad (
						reg_status, dstrct, numero_solicitud, actividad, usuario, fecha,
						cod_neg, comentarios, concepto, causal, comentario_stby)

						SELECT
								reg_status,
								dstrct,
								numero_solicitud,
								'DEC',
								usuario,
								fecha + INTERVAL '1 SECOND',
								cod_neg,
								comentarios,
								'APROBADO',
								causal,
								comentario_stby
						FROM negocios_trazabilidad
						WHERE cod_neg = _negocio :: VARCHAR AND concepto IN ('RELIQUIDAR', 'RELIQUIDAR_FINTRA');

		END IF;


		UPDATE negocios
		SET
				nro_docs      = totalesliquidacion.numcuota,
				vr_custodia   = totalesliquidacion.custodia,
				vr_desembolso = (totalesliquidacion.capital - totalesliquidacion.valor_aval),
				vr_negocio    = (totalesliquidacion.capital - totalesliquidacion.valor_aval),
				tot_pagado    = totalesliquidacion.valor_cuota,
				valor_aval    = totalesliquidacion.valor_aval,
				valor_fianza  = totalesliquidacion.valor_aval,
				estado_neg    = 'V', --AQUI VA EL ESTADO
				actividad     = 'DEC', --
				aval_manual   = 'S',
				num_aval      = get_lcod('NUMERO_AVAL'),
				tasa	      = _TASA
		WHERE cod_neg = _negocio :: VARCHAR;



		UPDATE solicitud_aval
		SET estado_sol = 'V'
		WHERE cod_neg = _negocio :: VARCHAR;

		RETURN 'RELIQUIDACION EXITOSA';

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fn_reliquidar_negocios_fintra(character varying, numeric, numeric, character varying, numeric, character varying)
  OWNER TO postgres;
