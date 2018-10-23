-- Function: tem.plantilla_pagos()

-- DROP FUNCTION tem.plantilla_pagos();

CREATE OR REPLACE FUNCTION tem.plantilla_pagos()
  RETURNS text AS
$BODY$
DECLARE

recodIngresos record;

BEGIN

	for recodIngresos in

			 select * from (
					SELECT
						CAROLINA.NEGASOC,
						CAROLINA.NITCLI,
						CAROLINA.DESCRIPCION_INGRESO,
						CAROLINA.NUM_INGRESO AS INGRESO_INTERES,
						DANIELA.NUM_INGRESO AS INGRESO_SEGURO,
						TEM.VALIDA_DESCUADRE_NOTAS_AJUSTE(CAROLINA.NUM_INGRESO::VARCHAR ,DANIELA.NUM_INGRESO::VARCHAR, 'INTERES'::VARCHAR, CAROLINA.NEGASOC::VARCHAR) as dif_int ,
						TEM.VALIDA_DESCUADRE_NOTAS_AJUSTE(CAROLINA.NUM_INGRESO::VARCHAR ,DANIELA.NUM_INGRESO::VARCHAR, 'SEGURO'::VARCHAR, CAROLINA.NEGASOC::VARCHAR) as dif_seguro,
						(select sum(valor_saldo) from con.factura where negasoc=CAROLINA.NEGASOC and reg_status='') as valor_saldo

					FROM(
						SELECT * FROM (
							SELECT *
							       ,(SELECT CASE WHEN SUBSTRING(CUENTA,1,2) ='27' THEN 'INTERES' ELSE 'SEGURO' END AS MARCA   FROM CON.COMPRODET  WHERE NUMDOC IN (NUM_INGRESO) AND CUENTA IN ('27050940','28150901')) AS MARCA
							FROM  TEM.INGRESO_CAROLINA_PAGO_TOTAL

						)T WHERE MARCA ='INTERES'
					)CAROLINA
					LEFT JOIN (

						SELECT * FROM (
							SELECT *
							       ,(SELECT CASE WHEN SUBSTRING(CUENTA,1,2) ='27' THEN 'INTERES' ELSE 'SEGURO' END AS MARCA   FROM CON.COMPRODET  WHERE NUMDOC IN (NUM_INGRESO) AND CUENTA IN ('27050940','28150901')) AS MARCA
							FROM  TEM.INGRESO_CAROLINA_PAGO_TOTAL

						)T  WHERE MARCA = 'SEGURO'

					)DANIELA ON (CAROLINA.NITCLI=DANIELA.NITCLI)
					)t2
					where (dif_int !=0.00 or dif_seguro!=0.00) or dif_int is null or dif_seguro is null  and NEGASOC !='LB00309'

	loop


			INSERT INTO  TEM.PLATILLA_PAGOS
			SELECT
			       ESTADO_CUOTA,
			       '01-01-0099'::DATE AS FECHA_INGRESO,
			       '01-01-0099'::DATE AS FECHA_EMISION,
			       FECHA_VENCIMIENTO,
			       CUOTA::INTEGER,
			       DOCUMENTO_SOPORTE,
			       'CXPA'::VARCHAR AS TIPO_DOCUMENTO_SOP,
			       DESCRIPCION,
			       NIT AS TERCERO,
			       'A1111F15201'::VARCHAR AS CENTRO_COSTO,
			       '27050501'::VARCHAR AS CUENTA ,
			       SUM(VALOR_UNITARIO) AS VALOR_DEBITO,
			       0.00::NUMERIC AS VALOR_CREDITO,
			       NEGOCIO AS REFERENCIA
			 FROM (
				SELECT
				       CASE WHEN ING.REG_STATUS='' THEN 'PAGADA' ELSE 'REVERSADA' END AS ESTADO_CUOTA,
				       FAC.NUM_DOC_FEN AS CUOTA,
				       FAC.NIT,
				       CASE WHEN   FDET.DESCRIPCION='INTERES' THEN ING.COD ELSE  FAC.DOCUMENTO END AS DOCUMENTO_SOPORTE,
				       FDET.DESCRIPCION,
				       FDET.VALOR_UNITARIO,
				       FAC.FECHA_VENCIMIENTO,
				       ING.CODNEG AS NEGOCIO
				FROM ING_FENALCO ING
				INNER JOIN CON.FACTURA FAC ON (ING.FECHA_DOC=FAC.FECHA_VENCIMIENTO AND ING.CODNEG=FAC.NEGASOC)
				INNER JOIN CON.FACTURA_DETALLE FDET ON (FDET.DOCUMENTO=FAC.DOCUMENTO AND FAC.TIPO_DOCUMENTO=FDET.TIPO_DOCUMENTO)
				WHERE CODNEG =RECODINGRESOS.NEGASOC AND FDET.REG_STATUS='' AND  ING.REG_STATUS='A' AND FDET.DESCRIPCION ='INTERES'
			) T
			GROUP BY
			ESTADO_CUOTA,
			CUOTA::INTEGER,
			DOCUMENTO_SOPORTE,
			NIT,
			DESCRIPCION,
			FECHA_VENCIMIENTO,
			NEGOCIO

			 UNION ALL

			SELECT
			       ESTADO_CUOTA,
			       '01-01-0099'::DATE AS FECHA_INGRESO,
			       '01-01-0099'::DATE AS FECHA_EMISION,
			       FECHA_VENCIMIENTO,
			       CUOTA::INTEGER,
			       DOCUMENTO_SOPORTE,
			       'CXPA'::VARCHAR AS TIPO_DOCUMENTO_SOP,
			       DESCRIPCION,
			       '860028415'::VARCHAR AS TERCERO,
			       'A1111F15201'::VARCHAR AS CENTRO_COSTO,
			       '28150502'::VARCHAR AS CUENTA,
			       SUM(VALOR_UNITARIO) AS VALOR_DEBITO,
			       0.00::NUMERIC AS VALOR_CREDITO,
			       NEGOCIO AS REFERENCIA
			 FROM (
				SELECT
				       CASE WHEN ING.REG_STATUS='' THEN 'PAGADA' ELSE 'REVERSADA' END AS ESTADO_CUOTA,
				       FAC.NUM_DOC_FEN AS CUOTA,
				       CASE WHEN   FDET.DESCRIPCION='INTERES' THEN ING.COD ELSE  FAC.DOCUMENTO END AS DOCUMENTO_SOPORTE,
				       FDET.DESCRIPCION,
				       FDET.VALOR_UNITARIO,
				       FAC.FECHA_VENCIMIENTO,
				       ING.CODNEG AS NEGOCIO
				FROM ING_FENALCO ING
				INNER JOIN CON.FACTURA FAC ON (ING.FECHA_DOC=FAC.FECHA_VENCIMIENTO AND ING.CODNEG=FAC.NEGASOC)
				INNER JOIN CON.FACTURA_DETALLE FDET ON (FDET.DOCUMENTO=FAC.DOCUMENTO AND FAC.TIPO_DOCUMENTO=FDET.TIPO_DOCUMENTO)
				WHERE CODNEG =RECODINGRESOS.NEGASOC AND FDET.REG_STATUS='' AND  ING.REG_STATUS='A' AND FDET.DESCRIPCION ='SEGURO'
			) T
			GROUP BY
			ESTADO_CUOTA,
			CUOTA::INTEGER,
			DOCUMENTO_SOPORTE,
			DESCRIPCION,
			FECHA_VENCIMIENTO,
			NEGOCIO
			UNION ALL
			SELECT
			       'REVERSADA'::VARCHAR AS ESTADO_CUOTA,
			       I.FECHA_INGRESO,
			       I.FECHA_INGRESO AS FECHA_EMISION,
			       F.FECHA_VENCIMIENTO,
			       F.NUM_DOC_FEN::INTEGER AS CUOTA,
			       F.DOCUMENTO AS DOCUMENTO_SOPORTE,
			       'CXC0'::VARCHAR AS TIPO_DOCUMENTO_SOP,
			       FD.DESCRIPCION,
			       F.NIT AS TERCERO,
			       'A1111F15201'::VARCHAR AS CENTRO_COSTO,
			       '13050501'::VARCHAR AS CUENTA,
			       0.00::NUMERIC AS VALOR_DEBITO,
			       FD.VALOR_INGRESO AS VALOR_CREDITO,
			       F.NEGASOC AS REFERENCIA
			FROM CON.INGRESO_DETALLE FD
			INNER JOIN   CON.INGRESO I ON (I.NUM_INGRESO=FD.NUM_INGRESO)
			INNER JOIN CON.FACTURA F ON (F.DOCUMENTO=FD.DOCUMENTO)
			WHERE I.NUM_INGRESO IN (RECODINGRESOS.INGRESO_INTERES,RECODINGRESOS.INGRESO_SEGURO);

	end loop;

	return 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.plantilla_pagos()
  OWNER TO postgres;
