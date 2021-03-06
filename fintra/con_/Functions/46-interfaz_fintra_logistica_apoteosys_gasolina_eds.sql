-- Function: con.interfaz_fintra_logistica_apoteosys_gasolina_eds()

-- DROP FUNCTION con.interfaz_fintra_logistica_apoteosys_gasolina_eds();

CREATE OR REPLACE FUNCTION con.interfaz_fintra_logistica_apoteosys_gasolina_eds()
  RETURNS text AS
$BODY$

DECLARE


 /************************************************
  *DESCRIPCION: ESTA FUNCION TOMA LAS CXP DE LA EDS Y
  *OBTIENE LAS TRANSACCIONES Y CONSTRUYE EL ASIENTO
  *CONTABLE QUE MAS ADELANTE SE TRASLADARA A APOTEOSYS.
  *DOCUMENTACION:= EL ARRAY _ARRCUENTASAET HACE REFERENCIA A LAS CUENTAS PARA
  *REALIZAR LA VERIFICACION DE LAS TRANSACCIONES ASI:
  *EGR:=23050118, FAP:=22050404.
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2017-05-23
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/


 REC_OS RECORD;
 REC_AGA RECORD;
 REC_EGR RECORD;
 SECUENCIA_EG INTEGER;
 CONSEC INTEGER:=1;
 CREDITOACUM NUMERIC:=0.00;
 PLANILLA_ TEXT:='';
 NUMERO_OPERACION_ TEXT:='';
 FECHA_CXP_ TEXT:='';
 PROVEEDOR_FT TEXT:='';
 FECHA_CONTABILIZACION_ TEXT := '';
 FECHADOC_ TEXT:='';
 SW TEXT:='N';
 _ARRCUENTASAET VARCHAR[] :='{23050118,22050404}';--IDEAL UN TABLA OJO!!
 _ARRAYEGRESOS VARCHAR[];
 MCTYPE CON.TYPE_INSERT_MC;

BEGIN

--SE CONSULTAN LOS REGISTROS QUE SE VAN A TRANSPORTAR PARA GASOLINA

	FOR REC_OS IN

		SELECT
		   TSP.FACTURA_TERCERO
		   ,CXP.PERIODO AS PERIODO_CONTABLE_CXP
		   ,TSP.FECHA_TRANSFERENCIA AS FECHA_EMISION
		   ,(TSP.FECHA_TRANSFERENCIA+'8 DAYS')::DATE AS FECHA_VENCIMIENTO
		   ,(SELECT FECHADOC FROM CON.COMPROBANTE WHERE NUMDOC=MAX(APT.NUMERO_OPERACION)  AND TIPODOC=APT.TIPO_OPERACION) AS FECHA_ANTICIPO
		   --,MAX(APT.NUMERO_OPERACION)
		FROM FIN.ANTICIPOS_PAGOS_TERCEROS APT
		LEFT JOIN FIN.ANTICIPOS_PAGOS_TERCEROS_TSP TSP  ON (APT.ID=TSP.ID)
		INNER JOIN PROVEEDOR AS B ON (B.NIT = APT.PROVEEDOR_ANTICIPO)
		INNER JOIN NIT AS C ON (C.CEDULA = APT.PLA_OWNER)
		LEFT JOIN  (SELECT * FROM FIN.CXP_DOC CXP
			WHERE CXP.HANDLE_CODE='GA' AND CXP.DSTRCT ='FINV'
			     AND CXP.REG_STATUS='' AND CXP.TIPO_DOCUMENTO='FAP'
			UNION
			SELECT * FROM  TEM.CXP_DOC_AGA
		   )CXP ON ( CXP.HANDLE_CODE='GA' AND CXP.DOCUMENTO=TSP.FACTURA_TERCERO AND CXP.DSTRCT ='FINV' AND CXP.REG_STATUS='' AND CXP.TIPO_DOCUMENTO='FAP')
		WHERE REPLACE(SUBSTRING(APT.FECHA_ANTICIPO,1,7),'-','')::INTEGER BETWEEN '201701'::INTEGER AND REPLACE(SUBSTRING(NOW(),1,7),'-','')::INTEGER
		    AND APT.REG_STATUS=''
		    AND APT.DSTRCT = 'FINV'
		    AND APT.PROVEEDOR_ANTICIPO = '802022016'
		    AND APT.CONCEPT_CODE IN ('10')
		    AND APT.PLANILLA != 'SAL ABPRES'
		    AND CXP.PERIODO = REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
		    AND ((TSP.FACTURA_TERCERO !='' AND TSP.ESTADO_PAGO_TERCERO='P' AND CXP.VLR_SALDO >0) --FACTURADO
		    OR (TSP.FACTURA_TERCERO !='' AND TSP.ESTADO_PAGO_TERCERO='P' AND CXP.VLR_SALDO =0)) --FACTURADO Y PAGADO
		    AND TSP.PROCESADO='N'
		GROUP BY
			TSP.FACTURA_TERCERO,
			CXP.PERIODO,
			TSP.FECHA_TRANSFERENCIA,
			APT.TIPO_OPERACION
		ORDER BY
			TSP.FACTURA_TERCERO


	LOOP
			--------------------------------------------------------------------------------------------------------------------------------------------
			--SE CONSULTA LA TRANSACCION

			SECUENCIA_EG:=0;
			PLANILLA_:='';
			CONSEC :=1;
			--FECHA DEL DOCUMENTO
			SELECT
				INTO FECHA_CXP_
				FECHADOC
			FROM
				CON.COMPROBANTE
			WHERE
				DSTRCT='FINV' AND
				TIPODOC='FAP' AND
				NUMDOC=REC_OS.FACTURA_TERCERO;

			raise notice 'Factura: %',REC_OS.FACTURA_TERCERO;

			--SECUENCIA DE LA TRANSACCION
			SELECT INTO SECUENCIA_EG NEXTVAL('CON.INTERFAZ_SECUENCIA_CXP_APOTEOSYS');

			--SE CONSTRUYE EL ASIENTO POR EL NUMERO DE LA OPERACION
			FOR REC_AGA IN

				SELECT
				      APT.PLANILLA
				     ,CASE WHEN HT2.NIT_APOTEOSYS IS NOT NULL THEN HT2.NIT_APOTEOSYS ELSE APT.PLA_OWNER END AS PLA_OWNER
				     ,APT.NUMERO_OPERACION
				     ,TSP.FACTURA_TERCERO
				     ,TSP.FECHA_TRANSFERENCIA AS FECHA_EMISION
				     ,(TSP.FECHA_TRANSFERENCIA+'8 DAYS')::DATE AS FECHA_VENCIMIENTO
				     ,CXPDET.VLR
				     ,CXP.PERIODO AS PERIODO_CONTABLE_CXP
				     ,CXP.FECHA_CONTABILIZACION
				     ,('REEMBOLSO ESTACIONES DE GASOLINA - '||UPPER(CXP.DESCRIPCION)) AS DETALLE
				     --,CXP.PROVEEDOR
				     ,CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE CXP.PROVEEDOR END AS PROVEEDOR
				     ,(CASE
					 WHEN C.TIPO_IDEN='CED' THEN 'CC'
					 WHEN C.TIPO_IDEN='RIF' THEN 'CE'
					 WHEN C.TIPO_IDEN='' THEN 'CC'
					 WHEN C.TIPO_IDEN='NIT' THEN 'NIT'
					 ELSE
				         'CC' END) AS TERCER_CODIGO____TIT____B
				     ,(C.NOMBRE1||' '||C.NOMBRE2) AS TERCER_NOMBCORT__B
				     ,(C.APELLIDO1||' '||C.APELLIDO2) AS TERCER_APELLIDOS_B
				     ,C.NOMBRE AS TERCER_NOMBEXTE__B
				     ,(CASE
					 WHEN D.GRAN_CONTRIBUYENTE='N' AND D.AGENTE_RETENEDOR='N' THEN 'RCOM'
					 WHEN D.GRAN_CONTRIBUYENTE='N' AND D.AGENTE_RETENEDOR='S' THEN 'RCAU'
					 WHEN D.GRAN_CONTRIBUYENTE='S' AND D.AGENTE_RETENEDOR='N' THEN 'GCON'
					 WHEN D.GRAN_CONTRIBUYENTE='S' AND D.AGENTE_RETENEDOR='S' THEN 'GCAU'
				      ELSE 'PNAL' END) AS TERCER_CODIGO____TT_____B
				      ,C.DIRECCION AS TERCER_DIRECCION_B
				      ,(CASE
					 WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
					 ELSE '08001' END) AS TERCER_CODIGO____CIUDAD_B
				      ,C.TELEFONO AS TERCER_TELEFONO1_B
				      ,D.DIGITO_VERIFICACION AS TERCER_DIGICHEQ__B
				      ,CXP.TERCER_CODIGO____TIT____B_EDS
				      ,CXP.TERCER_CODIGO____TT_____B_EDS
				      ,CXP.TERCER_CODIGO____CIUDAD_B_EDS
				      ,CXP.TERCER_DIGICHEQ__B_EDS
				      ,CXP.TERCER_NOMBCORT__B_EDS
				      ,CXP.TERCER_APELLIDOS_B_EDS
				      ,CXP.TERCER_NOMBEXTE__B_EDS
				      ,CXP.TERCER_DIRECCION_B_EDS
				      ,CXP.TERCER_TELEFONO1_B_EDS
				FROM FIN.ANTICIPOS_PAGOS_TERCEROS APT
				LEFT JOIN FIN.ANTICIPOS_PAGOS_TERCEROS_TSP TSP  ON (APT.ID=TSP.ID)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT2 ON(HT2.NIT_FINTRA=APT.PLA_OWNER)
				INNER JOIN PROVEEDOR AS B ON (B.NIT = APT.PROVEEDOR_ANTICIPO)
				INNER JOIN NIT AS C ON (C.CEDULA = APT.PLA_OWNER)
				INNER JOIN PROVEEDOR D ON(D.NIT=C.CEDULA )
				LEFT JOIN CIUDAD E ON(E.CODCIU=C.CODCIU)
				INNER JOIN  (SELECT  CXP_I.TIPO_DOCUMENTO
				                    ,CXP_I.REG_STATUS
				                    ,CXP_I.DSTRCT
				                    ,CXP_I.HANDLE_CODE
						    ,CXP_I.DOCUMENTO
						    ,CASE WHEN HT1.NIT_APOTEOSYS IS NOT NULL THEN HT1.NIT_APOTEOSYS ELSE CXP_I.PROVEEDOR END AS PROVEEDOR
						    ,CXP_I.FECHA_CONTABILIZACION
						    ,CXP_I.PERIODO
						    ,CXP_I.DESCRIPCION
						    ,CON.DATOS_BASICOS_CLIENTE('tipo_identificacion',N.TIPO_IDEN,'') AS TERCER_CODIGO____TIT____B_EDS
						    ,CON.DATOS_BASICOS_CLIENTE('tipo_agente',P.GRAN_CONTRIBUYENTE,P.AGENTE_RETENEDOR) AS TERCER_CODIGO____TT_____B_EDS
						    ,CON.DATOS_BASICOS_CLIENTE('ciudad',Z.CODIGO_DANE2,'') AS TERCER_CODIGO____CIUDAD_B_EDS
						    ,P.DIGITO_VERIFICACION AS TERCER_DIGICHEQ__B_EDS
						    ,(N.NOMBRE1||' '||N.NOMBRE2) AS TERCER_NOMBCORT__B_EDS
						    ,(N.APELLIDO1||' '||N.APELLIDO2) AS TERCER_APELLIDOS_B_EDS
						    ,N.NOMBRE AS TERCER_NOMBEXTE__B_EDS
						    ,N.DIRECCION AS TERCER_DIRECCION_B_EDS
						    ,N.TELEFONO AS TERCER_TELEFONO1_B_EDS
					     FROM FIN.CXP_DOC CXP_I
					     LEFT JOIN NIT AS N ON (N.CEDULA = CXP_I.PROVEEDOR)
					     LEFT JOIN PROVEEDOR P ON(P.NIT=N.CEDULA )
					     LEFT JOIN CIUDAD Z ON(Z.CODCIU=N.CODCIU)
					     LEFT JOIN CON.HOMOLOGA_TERCEROS HT1 ON(HT1.NIT_FINTRA=CXP_I.PROVEEDOR)
					     WHERE CXP_I.HANDLE_CODE='GA' AND CXP_I.DSTRCT ='FINV'  AND CXP_I.REG_STATUS='' AND CXP_I.TIPO_DOCUMENTO='FAP'
				   )CXP ON ( CXP.HANDLE_CODE='GA' AND CXP.DOCUMENTO=TSP.FACTURA_TERCERO AND CXP.DSTRCT ='FINV' AND CXP.REG_STATUS='' AND CXP.TIPO_DOCUMENTO='FAP')
				   LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=CXP.PROVEEDOR)
				INNER JOIN FIN.CXP_ITEMS_DOC CXPDET ON (CXPDET.DOCUMENTO=CXP.DOCUMENTO AND CXPDET.TIPO_DOCUMENTO=CXP.TIPO_DOCUMENTO AND CXPDET.REFERENCIA_1=TSP.ID  )
				WHERE TSP.FACTURA_TERCERO=REC_OS.FACTURA_TERCERO


			LOOP

				FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(FECHA_CXP_,1,7),'-','')=REC_AGA.PERIODO_CONTABLE_CXP THEN FECHA_CXP_::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(REC_AGA.PERIODO_CONTABLE_CXP,1,4),SUBSTRING(REC_AGA.PERIODO_CONTABLE_CXP,5,2)::INT)::DATE END ;

				--MCTYPE:=REC_AGA;
				IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[1],'', 6)='S')THEN
					MCTYPE.MC_____FECHEMIS__B=FECHADOC_::DATE;
					MCTYPE.MC_____FECHVENC__B=REC_OS.FECHA_VENCIMIENTO;
				ELSE
					MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
					MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

				END IF;

				--PARA OBTENER EL NUMERO DE PLANILLA

				PLANILLA_:='';

				IF(REC_AGA.PLANILLA!='')THEN
					MCTYPE.MC_____REFERENCI_B := REC_AGA.PLANILLA;
				ELSE
					MCTYPE.MC_____REFERENCI_B := REC_OS.FACTURA_TERCERO;
				END IF;
				------------------------------------
				MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
				MCTYPE.MC_____CODIGO____TD_____B := 'CXPN' ;
				MCTYPE.MC_____CODIGO____CD_____B := 'AG'  ;
				MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
				MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE;
				MCTYPE.MC_____NUMERO____B := SECUENCIA_EG  ;
				MCTYPE.MC_____SECUINTE__B := CONSEC  ;
				--MCTYPE.MC_____CODIGO____REFERE_B := PLANILLA_ ;
				MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(REC_OS.PERIODO_CONTABLE_CXP,1,4)::INT  ;
				MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(REC_OS.PERIODO_CONTABLE_CXP,5,2)::INT  ;
				MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
				MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[1],'', 1)  ;
				MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[1],'', 2)  ;
				MCTYPE.MC_____IDENTIFIC_TERCER_B := CASE WHEN CHAR_LENGTH(REC_AGA.PLA_OWNER)>10 THEN SUBSTR(REC_AGA.PLA_OWNER,1,10) ELSE REC_AGA.PLA_OWNER END ;
				MCTYPE.MC_____DEBMONORI_B := 0  ;
				MCTYPE.MC_____CREMONORI_B := 0 ;
				MCTYPE.MC_____DEBMONLOC_B := REC_AGA.VLR::NUMERIC  ;
				CREDITOACUM := CREDITOACUM + REC_AGA.VLR::NUMERIC;
				MCTYPE.MC_____CREMONLOC_B := 0.00  ;
				MCTYPE.MC_____INDTIPMOV_B := 4  ;
				MCTYPE.MC_____INDMOVREV_B := 'N'  ;
				MCTYPE.MC_____OBSERVACI_B := REC_AGA.DETALLE  ;
				MCTYPE.MC_____FECHORCRE_B := REC_AGA.FECHA_CONTABILIZACION::TIMESTAMP  ;
				MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
				MCTYPE.MC_____FEHOULMO__B := REC_AGA.FECHA_CONTABILIZACION::TIMESTAMP  ;
				MCTYPE.MC_____AUTULTMOD_B := ''  ;
				MCTYPE.MC_____VALIMPCON_B := 0  ;
				MCTYPE.MC_____NUMERO_OPER_B := REC_OS.FACTURA_TERCERO;
				MCTYPE.TERCER_CODIGO____TIT____B := REC_AGA.TERCER_CODIGO____TIT____B  ;
				MCTYPE.TERCER_NOMBCORT__B := REC_AGA.TERCER_NOMBCORT__B  ;
				MCTYPE.TERCER_NOMBEXTE__B := REC_AGA.TERCER_NOMBEXTE__B  ;
				MCTYPE.TERCER_APELLIDOS_B := REC_AGA.TERCER_APELLIDOS_B  ;
				MCTYPE.TERCER_CODIGO____TT_____B := REC_AGA.TERCER_CODIGO____TT_____B  ;
				MCTYPE.TERCER_DIRECCION_B := REC_AGA.TERCER_DIRECCION_B  ;
				MCTYPE.TERCER_CODIGO____CIUDAD_B := REC_AGA.TERCER_CODIGO____CIUDAD_B  ;
				MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(REC_AGA.TERCER_TELEFONO1_B)>15 THEN SUBSTR(REC_AGA.TERCER_TELEFONO1_B,1,15) ELSE REC_AGA.TERCER_TELEFONO1_B END;
				MCTYPE.TERCER_TIPOGIRO__B := 1 ;
				MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
				MCTYPE.TERCER_SUCURSAL__B := ''  ;
				MCTYPE.TERCER_NUMECUEN__B := ''  ;
				MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[1],'', 3);
				MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[1],'', 5)::INT;

				IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[1],'', 4)='S')THEN

					IF(REC_AGA.PLANILLA!='')THEN
						MCTYPE.MC_____NUMDOCSOP_B := 'AGA'||REC_AGA.NUMERO_OPERACION;
					ELSE
						MCTYPE.MC_____NUMDOCSOP_B := REC_OS.FACTURA_TERCERO;
					END IF;

				ELSE
					MCTYPE.MC_____NUMDOCSOP_B := '';
				END IF;

				IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[1],'', 5)::INT=1)THEN
					MCTYPE.MC_____NUMEVENC__B := 1;
				ELSE
					MCTYPE.MC_____NUMEVENC__B := NULL;
				END IF;

				PROVEEDOR_FT := REC_AGA.PROVEEDOR;
				FECHA_CONTABILIZACION_ := REC_AGA.FECHA_CONTABILIZACION;

				--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
				SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
				CONSEC:=CONSEC+1;

			END LOOP;

			-------------------------------------------------------------------

			--MCTYPE:=REC_AGA;
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[2],'', 6)='S')THEN
				MCTYPE.MC_____FECHEMIS__B=FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B=REC_OS.FECHA_VENCIMIENTO;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			END IF;

			MCTYPE.MC_____REFERENCI_B := REC_OS.FACTURA_TERCERO;
			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'CXPN' ;
			MCTYPE.MC_____CODIGO____CD_____B := 'AG'  ;
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			--MCTYPE.MC_____FECHA_____B := REC_OS.FECHA_ANTICIPO;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_EG  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			--MCTYPE.MC_____CODIGO____REFERE_B := PLANILLA_ ;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(REC_OS.PERIODO_CONTABLE_CXP,1,4)::INT  ;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(REC_OS.PERIODO_CONTABLE_CXP,5,2)::INT  ;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[2],'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[2],'', 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B := CASE WHEN CHAR_LENGTH(PROVEEDOR_FT)>10 THEN SUBSTR(PROVEEDOR_FT,1,10) ELSE PROVEEDOR_FT END ;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := 0.00;
			MCTYPE.MC_____CREMONLOC_B := CREDITOACUM::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := 'VALOR COBRADO POR LA EDS'  ;
			MCTYPE.MC_____FECHORCRE_B := FECHA_CONTABILIZACION_::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := FECHA_CONTABILIZACION_::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := REC_OS.FACTURA_TERCERO;

			MCTYPE.TERCER_CODIGO____TIT____B := REC_AGA.TERCER_CODIGO____TIT____B_EDS  ;
			MCTYPE.TERCER_NOMBCORT__B := REC_AGA.TERCER_NOMBCORT__B_EDS  ;
			MCTYPE.TERCER_NOMBEXTE__B := REC_AGA.TERCER_NOMBEXTE__B_EDS  ;
			MCTYPE.TERCER_APELLIDOS_B := REC_AGA.TERCER_APELLIDOS_B_EDS  ;
			MCTYPE.TERCER_CODIGO____TT_____B := REC_AGA.TERCER_CODIGO____TT_____B_EDS  ;
			MCTYPE.TERCER_DIRECCION_B := REC_AGA.TERCER_DIRECCION_B_EDS  ;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := REC_AGA.TERCER_CODIGO____CIUDAD_B_EDS  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(REC_AGA.TERCER_TELEFONO1_B_EDS)>15 THEN SUBSTR(REC_AGA.TERCER_TELEFONO1_B_EDS,1,15) ELSE REC_AGA.TERCER_TELEFONO1_B_EDS END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;

			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[2],'', 3);
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[2],'', 5)::INT;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[2],'', 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := REC_OS.FACTURA_TERCERO;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('GASOLINA', 'FAP', _ARRCUENTASAET[2],'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);

			-------------------------------------------------------------------

			--SETEAMOS LA VARIABLE ACUMULATIVA DEL VALOR DE LA CUENTA 22050404
			CREDITOACUM := 0.00;

			--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
			IF CON.SP_VALIDACIONES(MCTYPE, 'LOGISTICA') ='N' THEN
				SW='N';
				CONTINUE;
			END IF;

			--ACTUALIZAMOS EL REGISTRO EN OS PARA SABER QUE SE PROCESO
			IF(SW='S')THEN
				UPDATE
					FIN.ANTICIPOS_PAGOS_TERCEROS_TSP
				SET
					PROCESADO='S'
				WHERE
					FACTURA_TERCERO=REC_OS.FACTURA_TERCERO;

				SW:='N';
			END IF;

	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_fintra_logistica_apoteosys_gasolina_eds()
  OWNER TO postgres;
