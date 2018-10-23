-- Function: eg_comportamiento_pago_entidades_recaudo()

-- DROP FUNCTION eg_comportamiento_pago_entidades_recaudo();

CREATE OR REPLACE FUNCTION eg_comportamiento_pago_entidades_recaudo()
  RETURNS SETOF comportamiento_pagos_recaudos AS
$BODY$

DECLARE
  RECORDCXP RECORD;
  RECORDNOTA RECORD;
  RECORDERESO RECORD;
  _SWPAGONOTA BOOLEAN:=FALSE;
  _SWPAGOEGRESO BOOLEAN:=FALSE;
  _TIPO_PAGO INTEGER:=0;

  RS COMPORTAMIENTO_PAGOS_RECAUDOS;

BEGIN

      FOR RECORDCXP IN (
			SELECT
				CXP.PERIODO AS PERIODO_CXP,
				CXP.TIPO_DOCUMENTO,
				CXP.DOCUMENTO,
				CXP.PROVEEDOR AS TERCERO,
				GET_NOMBP(PROVEEDOR) AS NOMBRE_PROVEEDOR,
				CXP.BANCO,
				CXP.SUCURSAL,
				CXP.DOCUMENTO_RELACIONADO AS NEGOCIO,
				CASE WHEN NEG.ESTADO_NEG='T' THEN 'TRANSFERIDO'
				     WHEN NEG.ESTADO_NEG='D' THEN 'DESISTIDO'
				     WHEN NEG.ESTADO_NEG='R' THEN 'RECHAZADO'
				     WHEN NEG.ESTADO_NEG='V' THEN 'APROBADO'
				END AS ESTADO_NEGOCIO,
				NEG.F_DESEM::DATE AS FECHA_DESEMBOLSO,
				REPLACE(SUBSTRING(NEG.F_DESEM,1,7),'-','') AS PERIODO_DESEMBOLSO,
				CXP.FECHA_DOCUMENTO::DATE,
				CXP.FECHA_VENCIMIENTO::DATE,
				CXP.REG_STATUS AS ESTADO_CXP,
				CXP.VLR_NETO AS VALOR_NETO,
				CXP.VLR_SALDO AS VALOR_SALDO,
				CXP.CHEQUE AS NUMERO_EGRESO,
				''::VARCHAR AS NUMERO_NOTA,
				0::INTEGER AS TIPO_PAGO, -- 1:= EGRESO, 2:=NOTA_CREDITO , 3:=HIBRIDO
				0.00::NUMERIC AS VALOR_NOTA,
				'-'::VARCHAR AS PERIODO_NOTA,
				0.00::NUMERIC AS VALOR_EGRESO,
				'-'::VARCHAR AS PERIODO_EGRESO
			FROM FIN.CXP_DOC  CXP
			INNER JOIN NEGOCIOS NEG ON (NEG.COD_NEG=CXP.DOCUMENTO_RELACIONADO)
			WHERE DOCUMENTO ILIKE 'CXP%'
			AND HANDLE_CODE IN ('EV','SU')
			AND TIPO_DOCUMENTO IN ('FAP')
			AND CXP.PROVEEDOR IN ('8901049641','8301319931')
			--and cxp.documento='CXP000000565'
			and CXP.REG_STATUS=''
			ORDER BY CXP.PROVEEDOR
			)

      LOOP
		_SWPAGONOTA:=false;
		_SWPAGOEGRESO:=false;
		_TIPO_PAGO:=0;
		--1) VALIDAMOS EL POGO CON NOTAS
	       PERFORM  * FROM FIN.CXP_DOC WHERE  PROVEEDOR=RECORDCXP.TERCERO  AND DOCUMENTO_RELACIONADO=RECORDCXP.DOCUMENTO AND TIPO_DOCUMENTO='NC';
		       IF(FOUND)THEN
				SELECT INTO RECORDNOTA * FROM FIN.CXP_DOC WHERE PROVEEDOR=RECORDCXP.TERCERO AND  DOCUMENTO_RELACIONADO=RECORDCXP.DOCUMENTO AND TIPO_DOCUMENTO='NC' AND REG_STATUS='';
				RECORDCXP.NUMERO_NOTA :=RECORDNOTA.DOCUMENTO;
				RECORDCXP.VALOR_NOTA :=RECORDNOTA.VLR_NETO;
				RECORDCXP.PERIODO_NOTA :=RECORDNOTA.PERIODO;
				_SWPAGONOTA:=TRUE;
				_TIPO_PAGO:=1;
		       END IF;


		--2) VALIDAMOS EL PAGO CON EGRESO
		IF(RECORDCXP.NUMERO_EGRESO !='') THEN
			-- PERFORM EG.* FROM EGRESO EG
-- 			INNER JOIN  EGRESODET EDET ON (EDET.DOCUMENT_NO=EG.DOCUMENT_NO AND EDET.BRANCH_CODE=EG.BRANCH_CODE AND EDET.BANK_ACCOUNT_NO=EG.BANK_ACCOUNT_NO)
-- 			WHERE EG.REG_STATUS=''
-- 			AND EDET.DOCUMENTO=RECORDCXP.DOCUMENTO
-- 			AND EDET.TIPO_DOCUMENTO='FAP'
-- 			AND EG.DOCUMENT_NO=RECORDCXP.NUMERO_EGRESO
-- 			AND EG.NIT= RECORDCXP.TERCERO;
-- 			IF(FOUND)THEN

				SELECT INTO RECORDERESO EDET.VLR,COALESCE(EG.PERIODO ,'999999') AS PERIODO
				FROM EGRESO EG
				INNER JOIN  EGRESODET EDET ON (EDET.DOCUMENT_NO=EG.DOCUMENT_NO AND EDET.BRANCH_CODE=EG.BRANCH_CODE AND EDET.BANK_ACCOUNT_NO=EG.BANK_ACCOUNT_NO)
				WHERE EG.REG_STATUS=''
				AND EDET.DOCUMENTO=RECORDCXP.DOCUMENTO
				AND EDET.TIPO_DOCUMENTO='FAP'
				AND EG.DOCUMENT_NO=RECORDCXP.NUMERO_EGRESO
				AND EG.NIT= RECORDCXP.TERCERO
				AND EDET.BRANCH_CODE=RECORDCXP.BANCO
				AND EDET.BANK_ACCOUNT_NO=RECORDCXP.SUCURSAL;

			--	RAISE NOTICE 'RECORDERESO: %',RECORDERESO;

				RECORDCXP.VALOR_EGRESO:=RECORDERESO.VLR;
				RECORDCXP.PERIODO_EGRESO:=RECORDERESO.PERIODO;
				_TIPO_PAGO:=2;

				_SWPAGOEGRESO:=TRUE;

-- 			END IF;
		END IF;

		raise notice '_TIPO_PAGO : %',_TIPO_PAGO;
		--3VALIDAMOS SI ES UN PAGO HIBRIDO
		IF(_SWPAGONOTA AND _SWPAGOEGRESO)THEN
			_TIPO_PAGO:=3;
		END IF;

		RECORDCXP.TIPO_PAGO:=_TIPO_PAGO;

		RS:=RECORDCXP;

		RETURN NEXT RS;

      END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_comportamiento_pago_entidades_recaudo()
  OWNER TO postgres;