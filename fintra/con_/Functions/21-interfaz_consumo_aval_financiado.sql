-- Function: con.interfaz_consumo_aval_financiado()

-- DROP FUNCTION con.interfaz_consumo_aval_financiado();

CREATE OR REPLACE FUNCTION con.interfaz_consumo_aval_financiado()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODOS LO NEGOCIOS CONSUMO.
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-08-10
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

NEGOCIO_ RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD NUMERIC;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT INTEGER:= 1;
NUM_CUOTA_INVALIDA INTEGER;
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
RESPUESTA TEXT:='N';
VALIDACIONES TEXT;
CUENTA_ASIENTO VARCHAR;

BEGIN
	/**SACAMOS EL LISTADO DE NEGOCIOS PADRES*/
	FOR NEGOCIO_ IN
		SELECT NEG.FINANCIA_AVAL,
			NEG.NEGOCIO_REL,
			UNEG.ID AS UNIDAD_NEG,
			NEG.COD_NEG,
			NEG.COD_CLI,
			NEG.FECHA_NEGOCIO,
			SOLA.RENOVACION,
			CONV.AGENCIA
		FROM NEGOCIOS NEG
		INNER JOIN CONVENIOS CONV ON (CONV.ID_CONVENIO = NEG.ID_CONVENIO)
		INNER JOIN REL_UNIDADNEGOCIO_CONVENIOS RUC ON (CONV.ID_CONVENIO = RUC.ID_CONVENIO)
		INNER JOIN UNIDAD_NEGOCIO UNEG ON (UNEG.ID = RUC.ID_UNID_NEGOCIO)
		INNER JOIN SOLICITUD_AVAL SOLA ON (SOLA.COD_NEG = NEG.COD_NEG)
		WHERE NEG.ESTADO_NEG = 'T' AND UNEG.ID = '14'
		AND PROCESADO_MC = 'N'
		AND NEG.COD_NEG NOT IN (SELECT NEGOCIO_REESTRUCTURACION FROM REL_NEGOCIOS_REESTRUCTURACION)
		AND NEG.FINANCIA_AVAL = TRUE
		AND NEG.NEGOCIO_REL = ''
		--AND NEG.COD_NEG='FA36018'
		AND REPLACE(SUBSTRING(NEG.F_DESEM,1,7),'-','')=REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
	LOOP
-- 		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');
		SECUENCIA_INT:=1;
		RAISE NOTICE 'NEGOCIO: %',NEGOCIO_.COD_NEG;
		/**BUSCAMOS LA INFORMACION DEL CLIENTE*/
		SELECT INTO INFOCLIENTE
			(CASE
			WHEN TIPO_IDEN ='CED' THEN 'CC'
			WHEN TIPO_IDEN ='RIF' THEN 'CE'
			WHEN TIPO_IDEN ='NIT' THEN 'NIT' ELSE
			'CC' END) AS TIPO_DOC,
			(CASE
			WHEN TIPO_IDEN IN  ('RIF','NIT') THEN 'RCOM'  -->REGIMEN COMUN
			WHEN TIPO_IDEN IN  ('CED')  THEN 'RSCP'
			ELSE 'RSCP'
			END) AS CODIGO,
			(CASE
			WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
			ELSE '08001' END) AS CODIGOCIU,
			(D.NOMBRE1||' '||D.NOMBRE2) AS NOMBRE_CORTO,
			(D.APELLIDO1||' '||D.APELLIDO2) AS APELLIDOS,
			*
		FROM  NIT D --ON(D.CEDULA=PROV.NIT)
		LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
		WHERE CEDULA = NEGOCIO_.COD_CLI;
		--REGIMEN SIMPLICADO RSCP
		--REGIMEN COMUN RCOM

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
		MCTYPE.MC_____CODIGO____TD_____B := 'OPER' ;
		MCTYPE.MC_____CODIGO____CD_____B := SUBSTRING(NEGOCIO_.COD_NEG,1,2);
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ; --SECUENCIA GENERAL

		SELECT INTO NUM_CUOTA_INVALIDA COUNT(*) FROM CON.FACTURA WHERE NEGASOC = NEGOCIO_.COD_NEG AND CHAR_LENGTH(NUM_DOC_FEN)>2;

		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		IF(NUM_CUOTA_INVALIDA > 0)THEN
			CONTINUE;
		ELSE
			FOR INFOITEMS_ IN
			SELECT * FROM (
				(SELECT
					'CARTERA' AS DESCR,
					1::INTEGER AS ITERACION,
					NUM_DOC_FEN,
					FAC.DOCUMENTO,
					FAC.TIPO_DOCUMENTO,
					CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE FAC.NIT END AS NIT,
					--FAC.NIT,
					SUM (VALOR_UNITARIO) AS VALOR_DEB,
					0::NUMERIC AS VALOR_CREDT,
					'CARTERA FENALCO' AS DESCRIPCION,
					F_DESEM::DATE AS CREATION_DATE,
					FAC.FECHA_VENCIMIENTO,
					REPLACE(SUBSTRING(F_DESEM,1,7),'-','') AS PERIODO,
					(CASE
					WHEN TIPO_IDEN ='CED' THEN 'CC'
					WHEN TIPO_IDEN ='RIF' THEN 'CE'
					WHEN TIPO_IDEN ='NIT' THEN 'NIT' ELSE
					'CC' END) AS TIPO_DOC,
					(CASE
					WHEN TIPO_IDEN IN  ('RIF','NIT') THEN 'RCOM'  -->REGIMEN COMUN
					WHEN TIPO_IDEN IN  ('CED')  THEN 'RSCP'
					ELSE 'RSCP'
					END) AS CODIGO,
					(CASE
					WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
					ELSE '08001' END) AS CODIGOCIU,
					(D.NOMBRE1||' '||D.NOMBRE2) AS NOMBRE_CORTO,
					(D.APELLIDO1||' '||D.APELLIDO2) AS APELLIDOS,
					D.NOMBRE,
					D.DIRECCION,
					D.TELEFONO
				FROM CON.FACTURA FAC
				INNER JOIN NEGOCIOS NEG ON (FAC.NEGASOC = NEG.COD_NEG)
				INNER JOIN CON.FACTURA_DETALLE FACDET ON (FAC.DOCUMENTO = FACDET.DOCUMENTO)
				LEFT JOIN NIT D ON(D.CEDULA=FAC.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=FAC.NIT)
				WHERE NEGASOC = NEGOCIO_.COD_NEG
				AND FAC.REG_STATUS = ''
				AND FACDET.REG_STATUS = ''
				AND VALOR_UNITARIO <> 0
				GROUP BY NUM_DOC_FEN,F_DESEM,FAC.FECHA_VENCIMIENTO,NEGASOC,FAC.TIPO_DOCUMENTO,FAC.NIT,FAC.DOCUMENTO,HT.NIT_APOTEOSYS
				,TIPO_IDEN, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
				ORDER BY NUM_DOC_FEN::INTEGER
				)
				UNION ALL
				(SELECT
					'INTERES' AS DESCR,
					2::INTEGER AS ITERACION,
					NUM_DOC_FEN,
					B.DOCUMENTO,
					'NEG' AS TIPO_DOCUMENTO,
					CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE FAC.NIT END AS NIT,
					--FAC.NIT,
					0::NUMERIC AS VALOR_DEB,
					SUM (VALOR_UNITARIO) AS VALOR_CREDT,
					FAC.DESCRIPCION,
					F_DESEM::DATE AS CREATION_DATE,
					FAC.FECHA_VENCIMIENTO,
					REPLACE(SUBSTRING(F_DESEM,1,7),'-','') AS PERIODO,
					(CASE
					WHEN TIPO_IDEN ='CED' THEN 'CC'
					WHEN TIPO_IDEN ='RIF' THEN 'CE'
					WHEN TIPO_IDEN ='NIT' THEN 'NIT' ELSE
					'CC' END) AS TIPO_DOC,
					(CASE
					WHEN TIPO_IDEN IN  ('RIF','NIT') THEN 'RCOM'  -->REGIMEN COMUN
					WHEN TIPO_IDEN IN  ('CED')  THEN 'RSCP'
					ELSE 'RSCP'
					END) AS CODIGO,
					(CASE
					WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
					ELSE '08001' END) AS CODIGOCIU,
					(D.NOMBRE1||' '||D.NOMBRE2) AS NOMBRE_CORTO,
					(D.APELLIDO1||' '||D.APELLIDO2) AS APELLIDOS,
					D.NOMBRE,
					D.DIRECCION,
					D.TELEFONO
				FROM CON.FACTURA FAC
				INNER JOIN NEGOCIOS NEG ON (FAC.NEGASOC = NEG.COD_NEG)
				INNER JOIN CON.FACTURA_DETALLE FACDET ON (FAC.DOCUMENTO = FACDET.DOCUMENTO)
				INNER  JOIN (SELECT CODNEG,
						       SUBSTRING(COD,1,2) AS PREFIJO,
						       COD AS DOCUMENTO,
						       LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00') AS CUOTA,
						       FECHA_DOC::DATE AS FECHA_VEN,
						       VALOR
						FROM ING_FENALCO WHERE TIPODOC='IF'
						ORDER BY
						COD,LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00')::INTEGER
					      ) B ON (FAC.NEGASOC=B.CODNEG AND LPAD(SUBSTRING(FAC.DOCUMENTO,8,2),2,'00') =B.CUOTA)
				LEFT JOIN NIT D ON(D.CEDULA=FAC.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=FAC.NIT)
				WHERE NEGASOC = NEGOCIO_.COD_NEG
				AND FACDET.DESCRIPCION IN ('INTERESES')
				AND FAC.REG_STATUS = ''
				AND FACDET.REG_STATUS = ''AND VALOR_UNITARIO <> 0
				GROUP BY NUM_DOC_FEN,F_DESEM,FAC.FECHA_VENCIMIENTO,NEGASOC,FAC.TIPO_DOCUMENTO,FAC.NIT,FAC.DESCRIPCION,FAC.PERIODO,B.DOCUMENTO,HT.NIT_APOTEOSYS
				,TIPO_IDEN, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
				ORDER BY NUM_DOC_FEN::INTEGER
				)
				UNION ALL
				((SELECT
					'CUOTA ADMIN' AS DESCR,
					3::INTEGER AS ITERACION,
					NUM_DOC_FEN,
					B.DOCUMENTO,
					'NEG' AS TIPO_DOCUMENTO,
					CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE FAC.NIT END AS NIT,
					--FAC.NIT,
					0::NUMERIC AS VALOR_DEB,
					SUM (VALOR_UNITARIO) AS VALOR_CREDT,
					FAC.DESCRIPCION,
					F_DESEM::DATE AS CREATION_DATE,
					FAC.FECHA_VENCIMIENTO,
					REPLACE(SUBSTRING(F_DESEM,1,7),'-','') AS PERIODO,
					(CASE
					WHEN TIPO_IDEN ='CED' THEN 'CC'
					WHEN TIPO_IDEN ='RIF' THEN 'CE'
					WHEN TIPO_IDEN ='NIT' THEN 'NIT' ELSE
					'CC' END) AS TIPO_DOC,
					(CASE
					WHEN TIPO_IDEN IN  ('RIF','NIT') THEN 'RCOM'  -->REGIMEN COMUN
					WHEN TIPO_IDEN IN  ('CED')  THEN 'RSCP'
					ELSE 'RSCP'
					END) AS CODIGO,
					(CASE
					WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
					ELSE '08001' END) AS CODIGOCIU,
					(D.NOMBRE1||' '||D.NOMBRE2) AS NOMBRE_CORTO,
					(D.APELLIDO1||' '||D.APELLIDO2) AS APELLIDOS,
					D.NOMBRE,
					D.DIRECCION,
					D.TELEFONO
				FROM CON.FACTURA FAC
				INNER JOIN NEGOCIOS NEG ON (FAC.NEGASOC = NEG.COD_NEG)
				INNER JOIN CON.FACTURA_DETALLE FACDET ON (FAC.DOCUMENTO = FACDET.DOCUMENTO)
				inner  JOIN (SELECT CODNEG,
						       SUBSTRING(COD,1,2) AS PREFIJO,
						       COD AS DOCUMENTO,
						       LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00') AS CUOTA,
						       FECHA_DOC::DATE AS FECHA_VEN,
						       VALOR
						FROM ING_FENALCO WHERE tipodoc='CM'
						ORDER BY
						COD,LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00')::INTEGER
					     ) B on (FAC.NEGASOC=B.CODNEG AND LPAD(SUBSTRING(FAC.DOCUMENTO,8,2),2,'00') =B.CUOTA)
				LEFT JOIN NIT D ON(D.CEDULA=FAC.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=FAC.NIT)
				WHERE NEGASOC = NEGOCIO_.COD_NEG
				AND FACDET.DESCRIPCION IN ('CUOTA-ADMINISTRACION')
				AND FAC.REG_STATUS = ''
				AND FACDET.REG_STATUS = ''AND VALOR_UNITARIO <> 0
				GROUP BY NUM_DOC_FEN,F_DESEM,FAC.FECHA_VENCIMIENTO,NEGASOC,FAC.TIPO_DOCUMENTO,FAC.NIT,FAC.DESCRIPCION,FAC.PERIODO,B.DOCUMENTO,HT.NIT_APOTEOSYS
				,TIPO_IDEN, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
				ORDER BY NUM_DOC_FEN::INTEGER)
				UNION ALL
				(SELECT
					'CUOTA ADMIN' AS DESCR,
					3::INTEGER AS ITERACION,
					NUM_DOC_FEN,
					FAC.DOCUMENTO,
					'NEG' AS TIPO_DOCUMENTO,
					CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE FAC.NIT END AS NIT,
					--FAC.NIT,
					0::NUMERIC AS VALOR_DEB,
					SUM (VALOR_UNITARIO) AS VALOR_CREDT,
					FAC.DESCRIPCION,
					F_DESEM::DATE AS CREATION_DATE,
					FAC.FECHA_VENCIMIENTO,
					REPLACE(SUBSTRING(F_DESEM,1,7),'-','') AS PERIODO,
					(CASE
					WHEN TIPO_IDEN ='CED' THEN 'CC'
					WHEN TIPO_IDEN ='RIF' THEN 'CE'
					WHEN TIPO_IDEN ='NIT' THEN 'NIT' ELSE
					'CC' END) AS TIPO_DOC,
					(CASE
					WHEN TIPO_IDEN IN  ('RIF','NIT') THEN 'RCOM'  -->REGIMEN COMUN
					WHEN TIPO_IDEN IN  ('CED')  THEN 'RSCP'
					ELSE 'RSCP'
					END) AS CODIGO,
					(CASE
					WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
					ELSE '08001' END) AS CODIGOCIU,
					(D.NOMBRE1||' '||D.NOMBRE2) AS NOMBRE_CORTO,
					(D.APELLIDO1||' '||D.APELLIDO2) AS APELLIDOS,
					D.NOMBRE,
					D.DIRECCION,
					D.TELEFONO
				FROM CON.FACTURA FAC
				INNER JOIN NEGOCIOS NEG ON (FAC.NEGASOC = NEG.COD_NEG)
				INNER JOIN CON.FACTURA_DETALLE FACDET ON (FAC.DOCUMENTO = FACDET.DOCUMENTO)
				LEFT JOIN NIT D ON(D.CEDULA=FAC.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=FAC.NIT)
				WHERE NEGASOC = NEGOCIO_.COD_NEG
				AND FAC.REG_STATUS = ''
				AND FAC.DOCUMENTO ILIKE 'CM%'
				AND FACDET.REG_STATUS = ''AND VALOR_UNITARIO <> 0
				GROUP BY NUM_DOC_FEN,F_DESEM,FAC.FECHA_VENCIMIENTO,NEGASOC,FAC.TIPO_DOCUMENTO,FAC.NIT,FAC.DESCRIPCION,FAC.PERIODO,FAC.DOCUMENTO,HT.NIT_APOTEOSYS
				,TIPO_IDEN, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
				ORDER BY NUM_DOC_FEN::INTEGER)
				)UNION ALL
				(SELECT
					'FENALCO' AS DESCR,
					4::INTEGER AS ITERACION,
					DOCUMENTO AS NUM_DOC_FEN,
					DOCUMENTO AS DOCUMENTO,
					CXP.TIPO_DOCUMENTO,
					CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE CXP.PROVEEDOR END AS PROVEEDOR,
					--CXP.PROVEEDOR,
					0::NUMERIC AS VALOR_DEB,
					VLR_NETO AS VALOR_CREDT,
					CXP.DESCRIPCION,
					F_DESEM::DATE AS CREATION_DATE,
					F_DESEM::DATE AS FECHA_VENCIMIENTO,
					REPLACE(SUBSTRING(F_DESEM,1,7),'-','') AS PERIODO,
					(CASE
					WHEN TIPO_IDEN ='CED' THEN 'CC'
					WHEN TIPO_IDEN ='RIF' THEN 'CE'
					WHEN TIPO_IDEN ='NIT' THEN 'NIT' ELSE
					'CC' END) AS TIPO_DOC,
					(CASE
					WHEN TIPO_IDEN IN  ('RIF','NIT') THEN 'RCOM'  -->REGIMEN COMUN
					WHEN TIPO_IDEN IN  ('CED')  THEN 'RSCP'
					ELSE 'RSCP'
					END) AS CODIGO,
					(CASE
					WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
					ELSE '08001' END) AS CODIGOCIU,
					(D.NOMBRE1||' '||D.NOMBRE2) AS NOMBRE_CORTO,
					(D.APELLIDO1||' '||D.APELLIDO2) AS APELLIDOS,
					D.NOMBRE,
					D.DIRECCION,
					D.TELEFONO
				FROM FIN.CXP_DOC CXP
				INNER JOIN NEGOCIOS NEG ON ( NEG.COD_NEG = CXP.DOCUMENTO_RELACIONADO)
				LEFT JOIN NIT D ON(D.CEDULA=CXP.PROVEEDOR)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=CXP.PROVEEDOR)
				WHERE DOCUMENTO_RELACIONADO IN (NEGOCIO_.COD_NEG)
				AND VLR_NETO <> 0
				AND CXP.REG_STATUS = ''
				AND SUBSTRING (CXP.DOCUMENTO,1,2) IN ('PM','PB')
				GROUP BY NEG.COD_NEG,DOCUMENTO,CXP.TIPO_DOCUMENTO,CXP.PROVEEDOR,CXP.DESCRIPCION,F_DESEM,VLR_NETO,HT.NIT_APOTEOSYS
				,TIPO_IDEN, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
				)
				UNION ALL
				(SELECT
					'REMESA' AS DESCR,
					5::INTEGER AS ITERACION,
					NUM_DOC_FEN,
					FAC.DOCUMENTO,
					'NEG' AS TIPO_DOCUMENTO,
					CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE FAC.NIT END AS NIT,
					--FAC.NIT,
					0::NUMERIC AS VALOR_DEB,
					SUM (VALOR_UNITARIO) AS VALOR_CREDT,
					FAC.DESCRIPCION,
					F_DESEM::DATE AS CREATION_DATE,
					FAC.FECHA_VENCIMIENTO,
					REPLACE(SUBSTRING(F_DESEM,1,7),'-','') AS PERIODO,
					(CASE
					WHEN TIPO_IDEN ='CED' THEN 'CC'
					WHEN TIPO_IDEN ='RIF' THEN 'CE'
					WHEN TIPO_IDEN ='NIT' THEN 'NIT' ELSE
					'CC' END) AS TIPO_DOC,
					(CASE
					WHEN TIPO_IDEN IN  ('RIF','NIT') THEN 'RCOM'  -->REGIMEN COMUN
					WHEN TIPO_IDEN IN  ('CED')  THEN 'RSCP'
					ELSE 'RSCP'
					END) AS CODIGO,
					(CASE
					WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
					ELSE '08001' END) AS CODIGOCIU,
					(D.NOMBRE1||' '||D.NOMBRE2) AS NOMBRE_CORTO,
					(D.APELLIDO1||' '||D.APELLIDO2) AS APELLIDOS,
					D.NOMBRE,
					D.DIRECCION,
					D.TELEFONO
				FROM CON.FACTURA FAC
				INNER JOIN NEGOCIOS NEG ON (FAC.NEGASOC = NEG.COD_NEG)
				INNER JOIN CON.FACTURA_DETALLE FACDET ON (FAC.DOCUMENTO = FACDET.DOCUMENTO)
				LEFT JOIN NIT D ON(D.CEDULA=FAC.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=FAC.NIT)
				WHERE NEGASOC = NEGOCIO_.COD_NEG
				AND FACDET.DESCRIPCION IN ('REMESA')
				AND FAC.REG_STATUS = ''
				AND FACDET.REG_STATUS = ''AND VALOR_UNITARIO <> 0
				GROUP BY NUM_DOC_FEN,F_DESEM,FAC.FECHA_VENCIMIENTO,NEGASOC,FAC.TIPO_DOCUMENTO,FAC.NIT,FAC.DESCRIPCION,FAC.PERIODO,FAC.DOCUMENTO,HT.NIT_APOTEOSYS
				,TIPO_IDEN, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
				ORDER BY NUM_DOC_FEN::INTEGER
				)
				) AS A WHERE SUBSTR(A.DOCUMENTO,1,2)!='ND'
			LOOP
				CUENTA_ASIENTO := CON.INTERFAZ_CUENTA_DIFERIDOS_APOTEOSYS(SUBSTRING(NEGOCIO_.COD_NEG,1,2), INFOITEMS_.ITERACION, NEGOCIO_.AGENCIA,NEGOCIO_.UNIDAD_NEG::VARCHAR);
				RAISE NOTICE 'COD: %, ITERACION: %, AGENCIA: %, CUENTA: %',SUBSTRING(NEGOCIO_.COD_NEG,1,2), INFOITEMS_.ITERACION, NEGOCIO_.AGENCIA,CUENTA_ASIENTO;
				IF(INFOITEMS_.TIPO_DOCUMENTO IN ('FAC','FAP','NEG') AND CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO',INFOITEMS_.TIPO_DOCUMENTO, CUENTA_ASIENTO, NEGOCIO_.AGENCIA, 6)='S')THEN
					MCTYPE.MC_____FECHVENC__B = INFOITEMS_.FECHA_VENCIMIENTO; --FECHA VENCIMIENTO
					IF (INFOITEMS_.FECHA_VENCIMIENTO < INFOITEMS_.CREATION_DATE)THEN /** SE VALIDA SI LA FECHA DE VENCIMEINTO ES MENOR A LA DE CREACION*/
						MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.FECHA_VENCIMIENTO; --FECHA CREACION
					ELSE
						MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.CREATION_DATE; --FECHA CREACION
					END IF;

				ELSE
					MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
					MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
				END IF;
				FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(INFOITEMS_.CREATION_DATE,1,7),'-','') = INFOITEMS_.PERIODO THEN INFOITEMS_.CREATION_DATE::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(INFOITEMS_.PERIODO,1,4), SUBSTRING(INFOITEMS_.PERIODO,5,2)::INT)::DATE END;
				MCTYPE.MC_____FECHA_____B := FECHADOC_;
				MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--SECUENCIA INTERNA
				MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--SECUENCIA INTERNA
				MCTYPE.MC_____REFERENCI_B := NEGOCIO_.COD_NEG;
				MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( INFOITEMS_.PERIODO,1,4)::INT;
				MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( INFOITEMS_.PERIODO,5,2)::INT;
				MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
				MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.TIPO_DOCUMENTO, CUENTA_ASIENTO, NEGOCIO_.AGENCIA, 1);
				MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.TIPO_DOCUMENTO, CUENTA_ASIENTO, NEGOCIO_.AGENCIA, 2);
				MCTYPE.MC_____IDENTIFIC_TERCER_B := INFOITEMS_.NIT;
				MCTYPE.MC_____DEBMONORI_B := 0;
				MCTYPE.MC_____CREMONORI_B := 0;
				MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.VALOR_DEB::NUMERIC;
				MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.VALOR_CREDT::NUMERIC;
				MCTYPE.MC_____INDTIPMOV_B := 4;
				MCTYPE.MC_____INDMOVREV_B := 'N';
				MCTYPE.MC_____OBSERVACI_B := INFOITEMS_.DESCRIPCION;
				MCTYPE.MC_____FECHORCRE_B := INFOITEMS_.CREATION_DATE::TIMESTAMP;
				MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
				MCTYPE.MC_____FEHOULMO__B := INFOITEMS_.CREATION_DATE::TIMESTAMP;
				MCTYPE.MC_____AUTULTMOD_B := '';
				MCTYPE.MC_____VALIMPCON_B := 0;
				MCTYPE.MC_____NUMERO_OPER_B := '';
				MCTYPE.TERCER_CODIGO____TIT____B := INFOITEMS_.TIPO_DOC;
				MCTYPE.TERCER_NOMBCORT__B := SUBSTR(INFOITEMS_.NOMBRE_CORTO,1,32);
				MCTYPE.TERCER_NOMBEXTE__B := SUBSTR (INFOITEMS_.NOMBRE,1,64);
				MCTYPE.TERCER_APELLIDOS_B := SUBSTR(INFOITEMS_.APELLIDOS,1,32);
				MCTYPE.TERCER_CODIGO____TT_____B := INFOITEMS_.CODIGO;
				MCTYPE.TERCER_DIRECCION_B := SUBSTR(INFOITEMS_.DIRECCION,1,64);
				MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOITEMS_.CODIGOCIU;
				MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOITEMS_.TELEFONO)>15 THEN SUBSTR(INFOITEMS_.TELEFONO,1,15) ELSE INFOITEMS_.TELEFONO END;
				MCTYPE.TERCER_TIPOGIRO__B := 1;
				MCTYPE.TERCER_CODIGO____EF_____B := '';
				MCTYPE.TERCER_SUCURSAL__B := '';
				MCTYPE.TERCER_NUMECUEN__B := '';
				MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO',INFOITEMS_.TIPO_DOCUMENTO, CUENTA_ASIENTO, NEGOCIO_.AGENCIA, 3);
				IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.TIPO_DOCUMENTO, CUENTA_ASIENTO,NEGOCIO_.AGENCIA, 4)='S')THEN
					MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.DOCUMENTO;
				ELSE
					MCTYPE.MC_____NUMDOCSOP_B := '';
				END IF;

				IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.TIPO_DOCUMENTO, CUENTA_ASIENTO, NEGOCIO_.AGENCIA, 5)::INT=1)THEN
					MCTYPE.MC_____NUMEVENC__B := 1;
				ELSE
					MCTYPE.MC_____NUMEVENC__B := NULL;
				END IF;

				--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
				SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
				SECUENCIA_INT := SECUENCIA_INT + 1;

				--RAISE NOTICE 'VALOR_DEB: % VALOR_CREDT: %',INFOITEMS_.VALOR_DEB,INFOITEMS_.VALOR_CREDT;
			END LOOP;
		END IF;
		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'CONSUMO') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		RAISE NOTICE 'MCTYPE:1 %',MCTYPE;
		IF(SW = 'S')THEN
			--RAISE NOTICE 'PASO1: %',NEGOCIO_.COD_NEG;
			RESPUESTA := CON.INTERFAZ_CONSUMO_AVAL_APOTEOSYS(NEGOCIO_.COD_NEG, MCTYPE.MC_____NUMERO____B, MCTYPE.MC_____CODIGO____TD_____B, MCTYPE.MC_____CODIGO____CD_____B,INFOITEMS_.CREATION_DATE::DATE);
			IF(RESPUESTA = 'N')THEN
				CONTINUE;
			END IF;
			UPDATE NEGOCIOS SET PROCESADO_MC = 'S' WHERE COD_NEG = NEGOCIO_.COD_NEG;
		END IF;

	END LOOP;
RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_consumo_aval_financiado()
  OWNER TO postgres;
