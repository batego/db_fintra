-- Function: con.interfaz_fintra_logistica_apoteosys_bingreso()

-- DROP FUNCTION con.interfaz_fintra_logistica_apoteosys_bingreso();

CREATE OR REPLACE FUNCTION con.interfaz_fintra_logistica_apoteosys_bingreso()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION TOMA LOS INGRESOS Y
  *CONTRUYE EL ASIENTO CONTABLE QUE MAS ADELANTE SE TRASLADARA A APOTEOSYS.
  *DOCUMENTACION:= EL ARRAY _ARRCUENTASAET HACE REFERENCIA A LAS CUENTAS PARA
  *REALIZAR LA VERIFICACION DE LAS TRANSACCIONES ASI:
  *ING:=11050508,13802702,13802704,28050509,28050508,13802602
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2017-05-19
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/


 REC_OS RECORD;
 REC_ING RECORD;
 REC_ING_B RECORD;
 REC_ING_C RECORD;
 SECUENCIA_ING INTEGER;
 CONSEC INTEGER:=1;
 PLANILLA_ TEXT:='';
 FECHADOC_ TEXT:='';
 SW TEXT:='N';
 _ARRCUENTASAET VARCHAR[] :='{11050508,13802702,13802704,28050509,28050508,13802602}';--IDEAL UN TABLA OJO!!
_ARRAYFACTURAS VARCHAR[];
 MCTYPE CON.TYPE_INSERT_MC;
 CADENA_ TEXT:= '';

BEGIN

--SE CONSULTAN LOS REGISTROS QUE SE VAN A TRANSPORTAR PARA EL BOTON DE INGRESO

	FOR REC_OS IN

		SELECT
			EGRE.NUM_INGRESO, CXP.CORRIDA,PROCESADO--, CXP.DOCUMENTO --,NO_INGRESO
		FROM
			FIN.CXP_DOC_TSP  CXP
		INNER JOIN
			EGRESODET_TSP DETEGRE ON (DETEGRE.DOCUMENTO=CXP.DOCUMENTO)
		INNER JOIN
			EGRESO_TSP EGRE ON(EGRE.REG_STATUS=DETEGRE.REG_STATUS AND EGRE.DSTRCT=DETEGRE.DSTRCT AND EGRE.BRANCH_CODE=DETEGRE.BRANCH_CODE AND
							EGRE.BANK_ACCOUNT_NO=DETEGRE.BANK_ACCOUNT_NO AND EGRE.DOCUMENT_NO=DETEGRE.DOCUMENT_NO)
		WHERE
			CXP.PERIODO='201808' AND
			CXP.REG_STATUS='' AND
			CXP.DOCUMENTO LIKE 'MT%'
			AND EGRE.PROCESADO='N'
			and DETEGRE.NUM_INGRESO IN('IC306977')
		GROUP BY
			EGRE.NUM_INGRESO,  CXP.CORRIDA, PROCESADO--, CXP.DOCUMENTO--, CXP.DOCUMENTO
		ORDER BY
			EGRE.NUM_INGRESO
-- IC297006
-- IC297007
-- IC297008
-- IC297009
--update con.mc____ set procesado='N' where num_proceso=22019
--SELECT con.interfaz_fintra_logistica_apoteosys_bingreso();

	LOOP
			--------------------------------------------------------------------------------------------------------------------------------------------
				--SECUENCIA DEL INGRESO
				SELECT INTO SECUENCIA_ING NEXTVAL('CON.INTERFAZ_SECUENCIA_BINGRESO_APOTEOSYS');

				--SE CONSTRUYE EL ASIENTO POR EL NUMERO DE LA OPERACION
				FOR REC_ING IN

					SELECT
						tipo_documento as tipodoc,
						replace(substring(A.creation_date,1,7),'-','') as periodo,
						cuenta,
						CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE NITCLI END AS TERCERO,
						case when valor_ingreso<0 then valor_ingreso*-1 else 0 end as valor_debito,
						case when valor_ingreso>0 then valor_ingreso else 0 end as valor_credito,
						'PAGO '||FACTURA AS DETALLE,
						A.CREATION_DATE,
						A.CREATION_USER,
						A.LAST_UPDATE,
						A.USER_UPDATE,
						(CASE
						WHEN D.TIPO_IDEN='CED' THEN 'CC'
						WHEN D.TIPO_IDEN='RIF' THEN 'CE'
						WHEN D.TIPO_IDEN='NIT' THEN 'NIT' ELSE
						'CC' END) AS TERCER_CODIGO____TIT____B,
						C.DIGITO_VERIFICACION AS TERCER_DIGICHEQ__B,
						(D.NOMBRE1||' '||D.NOMBRE2) AS TERCER_NOMBCORT__B,
						(D.APELLIDO1||' '||D.APELLIDO2) AS TERCER_APELLIDOS_B,
						D.NOMBRE AS TERCER_NOMBEXTE__B,
						(CASE
						WHEN C.GRAN_CONTRIBUYENTE='N' AND C.AGENTE_RETENEDOR='N' THEN 'RCOM'
						WHEN C.GRAN_CONTRIBUYENTE='N' AND C.AGENTE_RETENEDOR='S' THEN 'RCAU'
						WHEN C.GRAN_CONTRIBUYENTE='S' AND C.AGENTE_RETENEDOR='N' THEN 'GCON'
						WHEN C.GRAN_CONTRIBUYENTE='S' AND C.AGENTE_RETENEDOR='S' THEN 'GCAU'
						ELSE 'PNAL' END) AS TERCER_CODIGO____TT_____B,
						D.DIRECCION AS TERCER_DIRECCION_B,
						(CASE
						WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
						ELSE '08001' END) AS TERCER_CODIGO____CIUDAD_B,
						D.TELEFONO AS TERCER_TELEFONO1_B,
						FACTURA AS DOCUMENTO_REL
					FROM
						con.ingreso_detalle A
					LEFT JOIN
						PROVEEDOR C ON(C.NIT=A.NITCLI)
					LEFT JOIN
						NIT D ON(D.CEDULA=C.NIT)
					LEFT JOIN
						CIUDAD E ON(E.CODCIU=D.CODCIU)
					LEFT JOIN
						CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=A.NITCLI)
					where
						num_ingreso=REC_OS.NUM_INGRESO AND
						CUENTA NOT IN(_ARRCUENTASAET[1],_ARRCUENTASAET[4],_ARRCUENTASAET[5])
					ORDER BY
						valor_ingreso,tipo_documento

				LOOP

					FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(REC_ING.CREATION_DATE,1,7),'-','')=REC_ING.PERIODO THEN REC_ING.CREATION_DATE::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(REC_ING.PERIODO,1,4),SUBSTRING(REC_ING.PERIODO,5,2)::INT)::DATE END ;

					--MCTYPE:=REC_ING;
					IF(REC_ING.TIPODOC='ING' AND REC_ING.CUENTA IN(_ARRCUENTASAET[2], _ARRCUENTASAET[3], _ARRCUENTASAET[6]) AND CON.OBTENER_HOMOLOGACION_APOTEOSYS('BINGRESO', REC_ING.TIPODOC, REC_ING.CUENTA,'', 6)='S')THEN
						MCTYPE.MC_____FECHEMIS__B=FECHADOC_::DATE  ;
						MCTYPE.MC_____FECHVENC__B=FECHADOC_::DATE  ;
					ELSE
						MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
						MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
					END IF;

					MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
					MCTYPE.MC_____CODIGO____TD_____B := 'INGN' ;
					MCTYPE.MC_____CODIGO____CD_____B := 'IGLG'  ;
					MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
					MCTYPE.MC_____NUMERO____B := SECUENCIA_ING  ;
					MCTYPE.MC_____SECUINTE__B := CONSEC  ;
					MCTYPE.MC_____REFERENCI_B := REC_OS.NUM_INGRESO||';'||REC_OS.CORRIDA  ;
					MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(REC_ING.PERIODO,1,4)::INT  ;
					MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(REC_ING.PERIODO,5,2)::INT  ;
					MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
					MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('BINGRESO', REC_ING.TIPODOC, REC_ING.CUENTA,'', 1)  ;
					MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('BINGRESO', REC_ING.TIPODOC, REC_ING.CUENTA,'', 2)  ;
					MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(REC_ING.TERCERO)>10 THEN SUBSTR(REC_ING.TERCERO,1,10) ELSE REC_ING.TERCERO END;
					MCTYPE.MC_____DEBMONORI_B := 0  ;
					MCTYPE.MC_____CREMONORI_B := 0 ;
					MCTYPE.MC_____DEBMONLOC_B := REC_ING.VALOR_DEBITO::NUMERIC  ;
					MCTYPE.MC_____CREMONLOC_B := REC_ING.VALOR_CREDITO::NUMERIC  ;
					MCTYPE.MC_____INDTIPMOV_B := 4  ;
					MCTYPE.MC_____INDMOVREV_B := 'N'  ;
					MCTYPE.MC_____OBSERVACI_B := REC_ING.DETALLE  ;
					MCTYPE.MC_____FECHORCRE_B := FECHADOC_::TIMESTAMP  ;
					MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
					MCTYPE.MC_____FEHOULMO__B := FECHADOC_::TIMESTAMP  ;
					MCTYPE.MC_____AUTULTMOD_B := ''  ;
					MCTYPE.MC_____VALIMPCON_B := 0  ;
					MCTYPE.MC_____NUMERO_OPER_B := REC_OS.NUM_INGRESO;
					MCTYPE.TERCER_CODIGO____TIT____B := REC_ING.TERCER_CODIGO____TIT____B  ;
					MCTYPE.TERCER_NOMBCORT__B := SUBSTR(REC_ING.TERCER_NOMBCORT__B,1,32)  ;
					MCTYPE.TERCER_NOMBEXTE__B := SUBSTR(REC_ING.TERCER_NOMBEXTE__B,1,64)  ;
					MCTYPE.TERCER_APELLIDOS_B := SUBSTR(REC_ING.TERCER_APELLIDOS_B,1,32)  ;
					MCTYPE.TERCER_CODIGO____TT_____B := REC_ING.TERCER_CODIGO____TT_____B  ;
					MCTYPE.TERCER_DIRECCION_B := SUBSTR(REC_ING.TERCER_DIRECCION_B,1,64)  ;
					MCTYPE.TERCER_CODIGO____CIUDAD_B := REC_ING.TERCER_CODIGO____CIUDAD_B  ;
					MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(REC_ING.TERCER_TELEFONO1_B)>15 THEN SUBSTR(REC_ING.TERCER_TELEFONO1_B,1,15) ELSE REC_ING.TERCER_TELEFONO1_B END;
					MCTYPE.TERCER_TIPOGIRO__B := 1 ;
					MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
					MCTYPE.TERCER_SUCURSAL__B := ''  ;
					MCTYPE.TERCER_NUMECUEN__B := ''  ;
					MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('BINGRESO', REC_ING.TIPODOC, REC_ING.CUENTA,'', 3);

					IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('BINGRESO', REC_ING.TIPODOC, REC_ING.CUENTA,'', 4)='S')THEN

						SELECT INTO PLANILLA_ NUMERO_OPERACION  FROM FIN.ORDEN_SERVICIO_DETALLE WHERE FACTURA_CXC=REC_ING.DOCUMENTO_REL;
						--SELECT  * FROM FIN.ORDEN_SERVICIO_DETALLE WHERE FACTURA_CXC='PP02120430';

						IF(REC_ING.CUENTA=_ARRCUENTASAET[3])THEN
							MCTYPE.MC_____NUMDOCSOP_B := 'AGA'||PLANILLA_;
						ELSE
							MCTYPE.MC_____NUMDOCSOP_B := PLANILLA_;
						END IF;

					ELSE
						MCTYPE.MC_____NUMDOCSOP_B := '';
					END IF;

					IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('BINGRESO', REC_ING.TIPODOC, REC_ING.CUENTA,'', 5)::INT=1)THEN
						MCTYPE.MC_____NUMEVENC__B := 1;
					ELSE
						MCTYPE.MC_____NUMEVENC__B := NULL;
					END IF;

					--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
					SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
					CONSEC:=CONSEC+1;
					RAISE NOTICE 'CONSEC 13: %',CONSEC;
				END LOOP;

				-------------------------------------------------------------------------------------------------------------------------------------
				FOR REC_ING_B  IN
					SELECT
						CONCEPTO,
						CUENTA,
						CASE WHEN VALOR_INGRESO <0 THEN VALOR_INGRESO*-1 ELSE 0 END AS DEBITO,
						CASE WHEN VALOR_INGRESO >=0 THEN VALOR_INGRESO ELSE 0 END AS CREDITO,
						CASE WHEN CONCEPTO='ANTICIPO' THEN 'A1111F21401'
							  WHEN CONCEPTO='PP FINTRA' THEN 'A1111F22201'
						ELSE 'A1111F21501' END AS CENTRO_COSTO,
						DESCRIPCION
					FROM (
					SELECT NUM_INGRESO,
					       CUENTA,
					       DESCRIPCION,
					       DOCUMENTO,
					       FACTURA,
					       VALOR_INGRESO,
					       TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Planilla: ')+10 ,STRPOS(ID.DESCRIPCION, 'Descripcion item egreso:')-(STRPOS(ID.DESCRIPCION, 'Planilla: ')+10)))AS PLANILLA,
					       (CASE WHEN
					       TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Concepto: ')+10 ,STRPOS(ID.DESCRIPCION, 'Planilla:' )-(STRPOS(ID.DESCRIPCION, 'Concepto: ')+10))) not in('','50') THEN
						TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Concepto: ')+10 ,STRPOS(ID.DESCRIPCION, 'Planilla:' )-(STRPOS(ID.DESCRIPCION, 'Concepto: ')+10)))
						WHEN
					       TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Concepto: ')+10 ,STRPOS(ID.DESCRIPCION, 'Planilla:' )-(STRPOS(ID.DESCRIPCION, 'Concepto: ')+10))) in('50','') THEN
						'PP FINTRA'
						ELSE '' END)
					       AS CONCEPTO

					FROM CON.INGRESO_DETALLE ID  WHERE NUM_INGRESO=REC_OS.NUM_INGRESO AND CUENTA IN(_ARRCUENTASAET[4],_ARRCUENTASAET[5]) AND VALOR_INGRESO<>0
					)T

				LOOP

					MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
					MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
					MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
					MCTYPE.MC_____CODIGO____TD_____B := 'INGN' ;
					MCTYPE.MC_____CODIGO____CD_____B := 'IGLG'  ;
					MCTYPE.MC_____SECUINTE__B := CONSEC  ;
					MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
					MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('BINGRESO', 'ING', REC_ING_B.CUENTA,'', 1)  ;
					MCTYPE.MC_____CODIGO____CU_____B := REC_ING_B.CENTRO_COSTO;
					MCTYPE.MC_____DEBMONORI_B := 0  ;
					MCTYPE.MC_____CREMONORI_B := 0 ;
					MCTYPE.MC_____DEBMONLOC_B := REC_ING_B.DEBITO::NUMERIC  ;
					MCTYPE.MC_____CREMONLOC_B := REC_ING_B.CREDITO::NUMERIC  ;
					MCTYPE.MC_____INDTIPMOV_B := 4  ;
					MCTYPE.MC_____INDMOVREV_B := 'N'  ;
					MCTYPE.MC_____CODIGO____DS_____B := '';
					MCTYPE.MC_____NUMDOCSOP_B := '';
					MCTYPE.MC_____NUMEVENC__B := NULL;
					MCTYPE.MC_____OBSERVACI_B := 'ANT QUE NO GENERARON TSP'  ;


					--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
					SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
					CONSEC:=CONSEC+1;
					RAISE NOTICE 'CONSEC 28: %',CONSEC;
				END LOOP;
				-------------------------------------------------------------------------------------------------------------------------------------

				-------------------------------------------------------------------------------------------------------------------------------------

				FOR REC_ING_C IN

					select
					CONCEPTO,
					_ARRCUENTASAET[1] AS CUENTA,
					CASE WHEN CONCEPTO='ANTICIPO' THEN 'A1111F21401'
							  WHEN CONCEPTO='PP FINTRA' THEN 'A1111F22201'
						ELSE 'A1111F21501' END AS CENTRO_COSTO,
					sum(valor_ingreso) as valor_debito
					from
					(SELECT
						PLANILLA
						,CASE WHEN CONCEPTO ='' THEN

							case when substr(t.planilla,char_length(t.planilla),char_length(t.planilla)) in('1','2','3','4','5','6','7','8','9','0') then

							     case when (SELECT count(0) FROM fin.anticipos_pagos_terceros   where planilla=t.planilla and vlr=abs(t.VALOR_INGRESO)) = 1 then
										(SELECT case when concept_code='01' then 'ANTICIPO'
													when concept_code='10' then 'FINTRA GASOLINA'
												else 'PP FINTRA' end FROM fin.anticipos_pagos_terceros   where planilla=t.planilla and vlr=abs(t.VALOR_INGRESO))::varchar
								     when (SELECT count(0) FROM fin.anticipos_pagos_terceros   where planilla=t.planilla and vlr=abs(t.VALOR_INGRESO) and reg_status='A')=1 then
										(SELECT case when concept_code='01' then 'ANTICIPO'
													when concept_code='10' then 'FINTRA GASOLINA'
												else 'PP FINTRA' end FROM fin.anticipos_pagos_terceros   where planilla=t.planilla and vlr=abs(t.VALOR_INGRESO) and reg_status='A')::varchar
								     when (SELECT count(0) FROM fin.cxp_items_doc_tsp   where documento like 'MT%' and planilla in (t.planilla) and vlr=t.VALOR_INGRESO)=1 then
										(SELECT concepto FROM fin.cxp_items_doc_tsp   where documento like 'MT%' and planilla in (t.planilla) and vlr=t.VALOR_INGRESO)
								     when (SELECT concepto FROM fin.cxp_items_doc_tsp   where documento like 'MT%' and planilla in (t.planilla) and vlr=abs(t.VALOR_INGRESO) limit 1)='' then
										(SELECT concepto FROM fin.cxp_items_doc_tsp   where documento like 'MT%' and planilla in (t.planilla) and vlr=abs(t.VALOR_INGRESO) limit 1)
								else
										'ANTICIPO'
								end

							else

								 case when (SELECT count(0) FROM fin.anticipos_pagos_terceros   where planilla=substr(t.planilla,1,char_length(t.planilla)-1) and vlr=abs(t.VALOR_INGRESO)) = 1 then
										(SELECT case when concept_code='01' then 'ANTICIPO'
													when concept_code='10' then 'FINTRA GASOLINA'
												else 'PP FINTRA' end FROM fin.anticipos_pagos_terceros   where planilla=substr(t.planilla,1,char_length(t.planilla)-1) and vlr=abs(t.VALOR_INGRESO))::varchar
								     when (SELECT count(0) FROM fin.anticipos_pagos_terceros   where planilla=substr(t.planilla,1,char_length(t.planilla)-1) and vlr=abs(t.VALOR_INGRESO) and reg_status='A')=1 then
										(SELECT case when concept_code='01' then 'ANTICIPO'
													when concept_code='10' then 'FINTRA GASOLINA'
												else 'PP FINTRA' end FROM fin.anticipos_pagos_terceros   where planilla=substr(t.planilla,1,char_length(t.planilla)-1) and vlr=abs(t.VALOR_INGRESO) and reg_status='A')::varchar
								     when (SELECT count(0) FROM fin.cxp_items_doc_tsp   where documento like 'MT%' and planilla in (substr(t.planilla,1,char_length(t.planilla)-1)) and vlr=t.VALOR_INGRESO)=1 then
										(SELECT concepto FROM fin.cxp_items_doc_tsp   where documento like 'MT%' and planilla in (substr(t.planilla,1,char_length(t.planilla)-1)) and vlr=t.VALOR_INGRESO)
								else
										(SELECT concepto FROM fin.cxp_items_doc_tsp   where documento like 'MT%' and planilla in (substr(t.planilla,1,char_length(t.planilla)-1)) and vlr=abs(t.VALOR_INGRESO) limit 1)
								end

							end
						WHEN CONCEPTO ='50' THEN 'PP FINTRA'
						ELSE  CONCEPTO END AS CONCEPTO ,
						VALOR_INGRESO,
						abs(t.VALOR_INGRESO ) as abs_valor_ingreso
					FROM (
					SELECT NUM_INGRESO,
					       CUENTA,
					       DESCRIPCION,
					       DOCUMENTO,
					       FACTURA,
					       VALOR_INGRESO,
					       CASE WHEN TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Planilla: ')+10 ,STRPOS(ID.DESCRIPCION, 'Descripcion item egreso:')-(STRPOS(ID.DESCRIPCION, 'Planilla: ')+10))) ='' THEN
							TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Factura TSP : ')+14 ,STRPOS(ID.DESCRIPCION, 'Item factura TSP:' )-(STRPOS(ID.DESCRIPCION, 'Factura TSP : ')+14)))
						ELSE  TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Planilla: ')+10 ,STRPOS(ID.DESCRIPCION, 'Descripcion item egreso:')-(STRPOS(ID.DESCRIPCION, 'Planilla: ')+10)))
						END AS PLANILLA,
					       (CASE WHEN   TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Concepto: ')+10 ,STRPOS(ID.DESCRIPCION, 'Planilla:' )-(STRPOS(ID.DESCRIPCION, 'Concepto: ')+10))) not in('','50') THEN
									TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Concepto: ')+10 ,STRPOS(ID.DESCRIPCION, 'Planilla:' )-(STRPOS(ID.DESCRIPCION, 'Concepto: ')+10)))
							ELSE TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Concepto: ')+10 ,STRPOS(ID.DESCRIPCION, 'Planilla:' )-(STRPOS(ID.DESCRIPCION, 'Concepto: ')+10)))
						    END)
					       --'50'
					       AS CONCEPTO
					FROM CON.INGRESO_DETALLE ID  WHERE NUM_INGRESO =REC_OS.NUM_INGRESO order by concepto
					)T) A
					GROUP BY
					CONCEPTO

				LOOP

					MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
					MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
					MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
					MCTYPE.MC_____CODIGO____TD_____B := 'INGN' ;
					MCTYPE.MC_____CODIGO____CD_____B := 'IGLG'  ;
					MCTYPE.MC_____SECUINTE__B := CONSEC  ;
					MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
					MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('BINGRESO', 'ING', REC_ING_C.CUENTA,'', 1)  ;
					MCTYPE.MC_____CODIGO____CU_____B := REC_ING_C.CENTRO_COSTO;
					MCTYPE.MC_____DEBMONORI_B := 0  ;
					MCTYPE.MC_____CREMONORI_B := 0 ;
					MCTYPE.MC_____DEBMONLOC_B := REC_ING_C.VALOR_DEBITO::NUMERIC ;
					MCTYPE.MC_____CREMONLOC_B := 0 ;
					MCTYPE.MC_____INDTIPMOV_B := 4  ;
					MCTYPE.MC_____INDMOVREV_B := 'N'  ;
					MCTYPE.MC_____CODIGO____DS_____B := '';
					MCTYPE.MC_____NUMDOCSOP_B := '';
					MCTYPE.MC_____NUMEVENC__B := NULL;
					MCTYPE.MC_____OBSERVACI_B := 'CAJA TSP TSP';

					--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
					SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
					CONSEC:=CONSEC+1;
					RAISE NOTICE 'CONSEC 11: %',CONSEC;
				END LOOP;

				-------------------------------------------------------------------------------------------------------------------------------------

			CONSEC:=1;

			--------------------------------------------------------------------------------------------------------------------------------------------

			--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
			IF CON.SP_VALIDACIONES(MCTYPE,'LOGISTICA') ='N' THEN
				SW='N';

				--BORRAMOS EL COMPROBANTE DE ING
				DELETE FROM CON.MC____
				WHERE MC_____NUMERO____B = SECUENCIA_ING AND MC_____CODIGO____CONTAB_B = 'FINT'
				 AND MC_____CODIGO____TD_____B = 'INGN' AND  MC_____CODIGO____CD_____B = 'IGLG'  ;

				CONTINUE;
			END IF;

			--ACTUALIZAMOS EL REGISTRO EN OS PARA SABER QUE SE PROCESO
			IF(SW='S')THEN
				UPDATE
					EGRESO_TSP
				SET
					PROCESADO='S'
				WHERE
					NUM_INGRESO=REC_OS.NUM_INGRESO;

				SW:='N';
			END IF;
		SW:='N';
	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_fintra_logistica_apoteosys_bingreso()
  OWNER TO postgres;
