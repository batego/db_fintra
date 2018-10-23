-- Function: con.interfaz_egresos_fc_apoteosys()

-- DROP FUNCTION con.interfaz_egresos_fc_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_egresos_fc_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: CREA LOS ASIENTOS DE LOS EGRESOS DE NEGOCIOS FE
  *AUTOR:=@DVALENCIA
  *FECHA CREACION:=2018-08-16
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  *
  ************************************************/

EGRESO_ RECORD;
INFOTERCERO RECORD;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT INTEGER:= 1;
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
INFOITEMS_ RECORD;
FECHADOC_ VARCHAR:= '';

BEGIN

	/**LISTADO DE EGRESOS A PASAR*/
	FOR EGRESO_ IN

		SELECT
			E.DOCUMENT_NO AS CHEQUE,
			CXP.TIPO_DOCUMENTO,
			CXP.DESCRIPCION,
			E.NIT AS TERCERO,
			E.BRANCH_CODE,
			E.BANK_ACCOUNT_NO,
			E.PERIODO,
			--'201808'::VARCHAR AS PERIODO,
			CONV.AGENCIA,
			UNEG.DESCRIPCION AS UNIDAD_NEG,
			SUBSTRING(SP_UNEG_NEGOCIO_NAME(N.COD_NEG),1,1) AS PREFIJO,
			N.COD_NEG,
			N.F_DESEM::DATE AS FECHA_EMISION,
			N.F_DESEM::DATE AS FECHA_VENCIMIENTO,
			EDET.PROCESADO
		FROM EGRESO E
		INNER JOIN EGRESODET EDET ON EDET.DOCUMENT_NO=E.DOCUMENT_NO
		INNER JOIN FIN.CXP_DOC CXP ON CXP.CHEQUE=E.DOCUMENT_NO
		INNER JOIN NEGOCIOS N ON N.COD_NEG=CXP.DOCUMENTO_RELACIONADO
		INNER JOIN CONVENIOS CONV ON (CONV.ID_CONVENIO = N.ID_CONVENIO)
		INNER JOIN REL_UNIDADNEGOCIO_CONVENIOS RUC ON (CONV.ID_CONVENIO = RUC.ID_CONVENIO)
		INNER JOIN UNIDAD_NEGOCIO UNEG ON (UNEG.ID = RUC.ID_UNID_NEGOCIO)
		WHERE E.REG_STATUS = ''
		AND CXP.CHEQUE != ''
		AND N.ESTADO_NEG IN ('T')
		AND UNEG.ID = '30'
		AND N.PROCESADO_MC='S'
		AND PROCESADO = 'N'
		AND N.COD_NEG NOT IN (SELECT NEGOCIO_REESTRUCTURACION FROM REL_NEGOCIOS_REESTRUCTURACION)
		--AND E.PERIODO ='201808' --REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
		--AND COALESCE(EDET.PROCESADO,'N')='N'
		---AND N.COD_NEG = 'FC00012'

	LOOP

		select INTO INFOTERCERO
			(CASE
			WHEN tipo_iden ='CED' THEN 'CC'
			WHEN tipo_iden ='RIF' THEN 'CE'
			WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
			'CC' END) as tipo_doc,
			(CASE
			WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
			WHEN tipo_iden in  ('CED')  THEN 'RSCP'
			else
			'RSCP'
			END) as codigo,
			(CASE
			WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
			ELSE '08001' END) as codigociu,
			(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
			(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
			*
		from  NIT D --ON(D.CEDULA=prov.NIT)
		LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
		where cedula = EGRESO_.tercero;

		--OBTENEMOS LA SECUENCIA
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_EGRESO_APOTEOSYS');

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'EGRN';
		MCTYPE.MC_____CODIGO____CD_____B := 'EGF'||EGRESO_.PREFIJO;
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		SECUENCIA_INT:=1;


		FOR INFOITEMS_ IN
			--- Asiento Cxp
			SELECT
				CXP.DOCUMENTO,
				HC.CUENTA,
				CXP.HANDLE_CODE,
				CXP.VLR_NETO AS VALOR_DEB,
				0::NUMERIC AS VALOR_CREDT,
				EG.NIT AS TERCERO,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE EG.NIT END AS TERCERO2,
				CXP.DESCRIPCION
			FROM NEGOCIOS NEG
			INNER JOIN FIN.CXP_DOC CXP ON(CXP.TIPO_DOCUMENTO_REL='NEG' AND CXP.DOCUMENTO_RELACIONADO=NEG.COD_NEG)
			INNER JOIN CON.CMC_DOC  HC ON (HC.CMC=CXP.HANDLE_CODE AND HC.TIPODOC=CXP.TIPO_DOCUMENTO)
			INNER JOIN EGRESO EG ON(EG.DSTRCT='FINV' AND EG.BRANCH_CODE=CXP.BANCO AND EG.BANK_ACCOUNT_NO=CXP.SUCURSAL AND EG.DOCUMENT_NO=CXP.CHEQUE)
			INNER JOIN EGRESODET EGDET ON(EGDET.DSTRCT=EG.DSTRCT AND EGDET.BRANCH_CODE=EG.BRANCH_CODE AND EGDET.BANK_ACCOUNT_NO=EG.BANK_ACCOUNT_NO AND EGDET.DOCUMENT_NO=EG.DOCUMENT_NO)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=EG.NIT)
			WHERE EG.REG_STATUS = ''
			AND EG.DOCUMENT_NO = EGRESO_.CHEQUE

			UNION ALL

			--- Asiento banco
			SELECT
				CXP.CHEQUE AS DOCUMENTO,
				COALESCE((SELECT CODIGO_CUENTA FROM BANCO  WHERE BRANCH_CODE =(CASE WHEN EG.BRANCH_CODE='BANCOLOMBIAPAB' THEN 'BANCOLOMBIA' ELSE EG.BRANCH_CODE END) AND BANK_ACCOUNT_NO=EG.BANK_ACCOUNT_NO),'00000000') AS CUENTA,
				CXP.HANDLE_CODE,
				0::NUMERIC AS VALOR_DEB,
				CXP.VLR_NETO AS VALOR_CREDT,
				EG.NIT AS TERCERO,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE EG.NIT END AS TERCERO2,
				CXP.DESCRIPCION
			FROM NEGOCIOS NEG
			INNER JOIN FIN.CXP_DOC CXP ON(CXP.TIPO_DOCUMENTO_REL='NEG' AND CXP.DOCUMENTO_RELACIONADO=NEG.COD_NEG)
			INNER JOIN CON.CMC_DOC  HC ON (HC.CMC=CXP.HANDLE_CODE AND HC.TIPODOC=CXP.TIPO_DOCUMENTO)
			INNER JOIN EGRESO EG ON(EG.DSTRCT='FINV' AND EG.BRANCH_CODE=CXP.BANCO AND EG.BANK_ACCOUNT_NO=CXP.SUCURSAL AND EG.DOCUMENT_NO=CXP.CHEQUE)
			INNER JOIN EGRESODET EGDET ON(EGDET.DSTRCT=EG.DSTRCT AND EGDET.BRANCH_CODE=EG.BRANCH_CODE AND EGDET.BANK_ACCOUNT_NO=EG.BANK_ACCOUNT_NO AND EGDET.DOCUMENT_NO=EG.DOCUMENT_NO)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON  (HT.NIT_FINTRA=EG.NIT)
			WHERE EG.REG_STATUS = ''
			AND EG.DOCUMENT_NO = EGRESO_.CHEQUE


		LOOP

			RAISE NOTICE 'INFOITEMS_.DOCUMENTO:%',INFOITEMS_.DOCUMENTO;
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FC_FINT',EGRESO_.TIPO_DOCUMENTO, INFOITEMS_.CUENTA, EGRESO_.AGENCIA, 6)='S')THEN
				MCTYPE.MC_____FECHEMIS__B = EGRESO_.FECHA_EMISION; --FECHA CREACION
				MCTYPE.MC_____FECHVENC__B = EGRESO_.FECHA_VENCIMIENTO; --FECHA VENCIMIENTO
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(EGRESO_.FECHA_EMISION,1,7),'-','') = EGRESO_.PERIODO THEN EGRESO_.FECHA_EMISION::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(EGRESO_.PERIODO,1,4), SUBSTRING(EGRESO_.PERIODO,5,2)::INT)::DATE END;
			MCTYPE.MC_____FECHA_____B :=FECHADOC_;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____REFERENCI_B := EGRESO_.COD_NEG;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( EGRESO_.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( EGRESO_.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FC_FINT', EGRESO_.TIPO_DOCUMENTO, INFOITEMS_.CUENTA,EGRESO_.AGENCIA, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FC_FINT', EGRESO_.TIPO_DOCUMENTO, INFOITEMS_.CUENTA,EGRESO_.AGENCIA, 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := CASE WHEN LENGTH(EGRESO_.TERCERO)>9 AND INFOTERCERO.TIPO_DOC='NIT' THEN SUBSTRING(INFOITEMS_.TERCERO2, 1,9) ELSE EGRESO_.TERCERO END;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := EGRESO_.DESCRIPCION||' '||EGRESO_.FECHA_VENCIMIENTO||' '||EGRESO_.COD_NEG||'-'||EGRESO_.CHEQUE|| ' '||EGRESO_.UNIDAD_NEG;
			MCTYPE.MC_____FECHORCRE_B := EGRESO_.FECHA_EMISION::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := EGRESO_.FECHA_EMISION::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOTERCERO.TIPO_DOC;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTR(INFOTERCERO.NOMBRE_CORTO,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTR (INFOTERCERO.NOMBRE,1,64);
			MCTYPE.TERCER_APELLIDOS_B := SUBSTR(INFOTERCERO.APELLIDOS,1,32);
			MCTYPE.TERCER_CODIGO____TT_____B := INFOTERCERO.CODIGO;
			MCTYPE.TERCER_DIRECCION_B := SUBSTR(INFOTERCERO.DIRECCION,1,64);
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOTERCERO.CODIGOCIU;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOTERCERO.TELEFONO)>15 THEN SUBSTR(INFOTERCERO.TELEFONO,1,15) ELSE INFOTERCERO.TELEFONO END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FC_FINT',EGRESO_.TIPO_DOCUMENTO, INFOITEMS_.CUENTA,EGRESO_.AGENCIA, 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FC_FINT', EGRESO_.TIPO_DOCUMENTO, INFOITEMS_.CUENTA,EGRESO_.AGENCIA, 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.DOCUMENTO;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FC_FINT', EGRESO_.TIPO_DOCUMENTO, INFOITEMS_.CUENTA, EGRESO_.AGENCIA, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			--RAISE NOTICE 'MCTYPE %',MCTYPE;
	 		SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
	 		SECUENCIA_INT :=SECUENCIA_INT+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'EGRESO_ECA') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		IF(SW = 'S')THEN
			UPDATE EGRESODET SET PROCESADO='S' WHERE DSTRCT='FINV' AND BRANCH_CODE=EGRESO_.BRANCH_CODE AND BANK_ACCOUNT_NO=EGRESO_.BANK_ACCOUNT_NO AND DOCUMENT_NO=EGRESO_.CHEQUE;
		END IF;

	END LOOP;

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_egresos_fc_apoteosys()
  OWNER TO postgres;
