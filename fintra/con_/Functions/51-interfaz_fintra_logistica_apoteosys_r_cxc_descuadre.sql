-- Function: con.interfaz_fintra_logistica_apoteosys_r_cxc_descuadre()

-- DROP FUNCTION con.interfaz_fintra_logistica_apoteosys_r_cxc_descuadre();

CREATE OR REPLACE FUNCTION con.interfaz_fintra_logistica_apoteosys_r_cxc_descuadre()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION TOMA LOS INGRESOS Y
  *CONTRUYE EL ASIENTO CONTABLE(R) QUE MAS ADELANTE SE TRASLADARA A APOTEOSYS.
  *DOCUMENTACION:= EL ARRAY _ARRCUENTASAET HACE REFERENCIA A LAS CUENTAS PARA
  *REALIZAR LA VERIFICACION DE LAS TRANSACCIONES ASI:
  *13101002,11050508
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2017-07-11
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/


 REC_OS RECORD;
 REC_R0 RECORD;
 REC_R1 RECORD;
 REC_R2 RECORD;
 REC_R3 RECORD;
 REC_R RECORD;
 REC_R4 RECORD;
 REC_R5 RECORD;
 REC_R6 RECORD;
 SECUENCIA_R INTEGER;
 CONSEC INTEGER:=1;
 VAL_AET NUMERIC:=0;
 VAL_AGA NUMERIC:=0;
 VAL_EXT NUMERIC:=0;
 PLANILLA_ TEXT:='';
 FECHADOC_ TEXT:='';
 _VAR_CU TEXT:='';
 SW TEXT:='N';
 _ARRCUENTASAET VARCHAR[] :='{13101002,13101001,11050508,13802608}';--IDEAL UN TABLA OJO!!
 MCTYPE CON.TYPE_INSERT_MC;
 CADENA_ TEXT:= '';

BEGIN

--SE CONSULTAN LOS REGISTROS QUE SE VAN A TRANSPORTAR PARA EL BOTON DE INGRESO

	FOR REC_OS IN

		SELECT
			EGRE.NUM_INGRESO, CXP.CORRIDA, EGRE.PROCESADO
		FROM
			EGRESO_TSP EGRE
		INNER JOIN EGRESODET_TSP DETEGRE ON(DETEGRE.reg_status=EGRE.reg_status AND DETEGRE.dstrct=EGRE.dstrct AND DETEGRE.branch_code=EGRE.branch_code
										AND DETEGRE.bank_account_no =EGRE.bank_account_no AND DETEGRE.document_no=EGRE.document_no)
		INNER JOIN FIN.CXP_DOC_TSP  CXP ON(CXP.DSTRCT='TSP' AND CXP.PROVEEDOR=EGRE.NIT AND CXP.TIPO_DOCUMENTO='010' AND CXP.DOCUMENTO=DETEGRE.DOCUMENTO)
		WHERE
		CXP.DSTRCT='TSP' AND
		--CXP.PERIODO='201806' AND
		CXP.REG_STATUS=''
		--AND CXP.DOCUMENTO LIKE 'MT%'
		AND EGRE.PROCESADO='S'
		--AND DETEGRE.PROCESADO_R='N'
		AND EGRE.NUM_INGRESO IN('IC306977')
		--and  CXP.CORRIDA = '77459'
		GROUP BY
			EGRE.NUM_INGRESO,  CXP.CORRIDA, EGRE.PROCESADO
		ORDER BY
			EGRE.NUM_INGRESO
		--LIMIT 1

--SELECT con.interfaz_fintra_logistica_apoteosys_r_CXC_descuadre();

/**286439091
SELECT * FROM con.mc____ where mc_____codigo____contab_b='FINT' AND procesado='N' AND MC_____CODIGO____TD_____B = 'CXCN' AND mc_____numero____b='30442'
update con.mc____ set procesado='S' where mc_____codigo____contab_b='FINT' AND procesado IN('S','R') AND MC_____CODIGO____TD_____B = 'CXCN'
AND mc_____codigo____cd_____b IN('CRLG') --and mc_____numero____period_b IN(6)
and mc_____numero____b='30394'
SELECT MC_____NUMERO____PERIOD_B, MC_____NUMERO____B, count(*) FROM con.mc____ where mc_____codigo____contab_b='FINT' AND procesado='N' AND MC_____CODIGO____TD_____B = 'CXCN'
group by MC_____NUMERO____PERIOD_B, MC_____NUMERO____B
delete FROM con.mc____ where mc_____codigo____contab_b='FINT' AND procesado='N' AND mc_____codigo____cd_____b='CRLG' and mc_____secuinte__b in(3,4) and mc_____numero____b in('30423')
and mc_____numero____b='30414' AND MC_____CODIGO____TD_____B = 'CXCN' and mc_____codigo____cu_____b='A1111F21501'
UPDATE con.mc____ SET mc_____DEBmonloc_b=mc_____DEBmonloc_b-504000.00 where mc_____codigo____contab_b='FINT' AND MC_____CODIGO____TD_____B = 'CXCN' and procesado='R'
and mc_____secuinte__b=2 and mc_____numero____b in('30423')
UPDATE con.mc____ SET PROCESADO='N' where mc_____codigo____contab_b='FINT' and procesado='R' AND MC_____CODIGO____TD_____B = 'CXCN' and mc_____numero____b in('30423')
AND NUM_PROCESO=8091
UPDATE con.mc____ SET MC_____NUMERO____PERIOD_B=7,procesado='N' where mc_____codigo____contab_b='FINT' AND procesado='N' AND
MC_____CODIGO____TD_____B = 'CXCN' AND mc_____numero____b='30442'
SELECT * FROM con.mc____ where mc_____codigo____contab_b='FINT' AND MC_____CODIGO____TD_____B = 'CXCN' and MC_____REFERENCI_B ilike '%79521%'
*/

	LOOP

			FOR REC_R0 IN

				SELECT
					DOCUMENTO,CMC, DESCRIPCION
				FROM
					CON.FACTURA
				WHERE  DOCUMENTO LIKE 'R0%'
					AND UPPER(DESCRIPCION) LIKE '%CORRIDA%'||REC_OS.CORRIDA||'%' AND CMC IN('DE','PD', 'GO','DT')
					--and DOCUMENTO='NC_CXPIC281637'
			LOOP


				--SECUENCIA DE LA R
				SELECT INTO SECUENCIA_R NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');
				VAL_AET :=0;
				VAL_AGA :=0;
				VAL_EXT :=0;

				--------------------------------------------------------------------------------------------------------------------------------------------
				--SE CONSTRUYE EL ASIENTO POR EL NUMERO DE LA OPERACION
				-----------------------------------
				--CXC DE DESCUADRE
				-----------------------------------
				FOR REC_R IN

					SELECT NUM_INGRESO,
						CONCEPTO,
						FECHA_CONTABILIZACION,
						PERIODO,
						_ARRCUENTASAET[3] AS CUENTA_CAJA,
						_ARRCUENTASAET[2] AS CUENTA_R,
						CASE WHEN E.CONCEPTO='ANTICIPO' THEN 'A1111F21401'
							  WHEN E.CONCEPTO='PP FINTRA' THEN 'A1111F22201'
						ELSE 'A1111F21501' END AS CENTRO_COSTO,
						SUM(VALOR_INGRESO)*-1 AS VALOR_DEBITO,
						NITCLI,
						TERCER_CODIGO____TIT____B,
						TERCER_DIGICHEQ__B,
						TERCER_NOMBCORT__B,
						TERCER_APELLIDOS_B,
						TERCER_NOMBEXTE__B,
						TERCER_CODIGO____TT_____B,
						TERCER_DIRECCION_B,
						TERCER_CODIGO____CIUDAD_B,
						TERCER_TELEFONO1_B
					FROM (
					SELECT
						NUM_INGRESO,
						--T.CONCEPTO,
						FECHA_CONTABILIZACION,
						PERIODO,
						VALOR_INGRESO,
						NITCLI,
						TERCER_CODIGO____TIT____B,
						TERCER_DIGICHEQ__B,
						TERCER_NOMBCORT__B,
						TERCER_APELLIDOS_B,
						TERCER_NOMBEXTE__B,
						TERCER_CODIGO____TT_____B,
						TERCER_DIRECCION_B,
						TERCER_CODIGO____CIUDAD_B,
						TERCER_TELEFONO1_B,
					CASE WHEN CONCEPTO ='' THEN

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
						ELSE  CONCEPTO END AS CONCEPTO
					FROM
					(SELECT NUM_INGRESO,
					       CUENTA,
					       DESCRIPCION,
					       DOCUMENTO,
					       FACTURA,
					       VALOR_INGRESO,
					       --FECHA_CONTABILIZACION::DATE,
					       ID.creation_date::date as FECHA_CONTABILIZACION,
					       replace(substring(ID.creation_date,1,7),'-','') as periodo,
					       --PERIODO,
					       --TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Planilla: ')+10 ,STRPOS(ID.DESCRIPCION, 'Descripcion item egreso:')-(STRPOS(ID.DESCRIPCION, 'Planilla: ')+10)))AS PLANILLA,
					       CASE WHEN TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Planilla: ')+10 ,STRPOS(ID.DESCRIPCION, 'Descripcion item egreso:')-(STRPOS(ID.DESCRIPCION, 'Planilla: ')+10))) ='' THEN
							TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Factura TSP : ')+14 ,STRPOS(ID.DESCRIPCION, 'Item factura TSP:' )-(STRPOS(ID.DESCRIPCION, 'Factura TSP : ')+14)))
						ELSE  TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Planilla: ')+10 ,STRPOS(ID.DESCRIPCION, 'Descripcion item egreso:')-(STRPOS(ID.DESCRIPCION, 'Planilla: ')+10)))
						END AS PLANILLA,
					       (CASE WHEN   TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Concepto: ')+10 ,STRPOS(ID.DESCRIPCION, 'Planilla:' )-(STRPOS(ID.DESCRIPCION, 'Concepto: ')+10))) not in('','50') THEN
									TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Concepto: ')+10 ,STRPOS(ID.DESCRIPCION, 'Planilla:' )-(STRPOS(ID.DESCRIPCION, 'Concepto: ')+10)))
							ELSE TRIM(SUBSTRING(ID.DESCRIPCION,STRPOS(ID.DESCRIPCION, 'Concepto: ')+10 ,STRPOS(ID.DESCRIPCION, 'Planilla:' )-(STRPOS(ID.DESCRIPCION, 'Concepto: ')+10)))
						    END)
					       AS CONCEPTO,
					       CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE NITCLI END AS NITCLI,
					       --NITCLI,
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
						D.TELEFONO AS TERCER_TELEFONO1_B

					FROM
						CON.INGRESO_DETALLE ID
					LEFT JOIN
						PROVEEDOR C ON(C.NIT=ID.NITCLI)
					LEFT JOIN
						NIT D ON(D.CEDULA=C.NIT)
					LEFT JOIN
						CIUDAD E ON(E.CODCIU=D.CODCIU)
					LEFT JOIN
						CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=ID.NITCLI)
					WHERE
						NUM_INGRESO =REC_OS.NUM_INGRESO
					)T) E
					GROUP BY
						NUM_INGRESO, CONCEPTO, FECHA_CONTABILIZACION, PERIODO, NITCLI, TERCER_CODIGO____TIT____B, TERCER_DIGICHEQ__B, TERCER_NOMBCORT__B,
						TERCER_APELLIDOS_B, TERCER_NOMBEXTE__B, TERCER_CODIGO____TT_____B, TERCER_DIRECCION_B, TERCER_CODIGO____CIUDAD_B, TERCER_TELEFONO1_B
					having
						SUM(e.VALOR_INGRESO)=(select valor_factura from con.factura where documento=REC_R0.documento)
					ORDER BY
						CONCEPTO

				LOOP

					FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(REC_R.FECHA_CONTABILIZACION,1,7),'-','')=REC_R.PERIODO THEN REC_R.FECHA_CONTABILIZACION::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(REC_R.PERIODO,1,4),SUBSTRING(REC_R.PERIODO,5,2)::INT)::DATE END ;

					MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
					MCTYPE.MC_____CODIGO____TD_____B := 'CXCN' ;
					MCTYPE.MC_____CODIGO____CD_____B := 'CRLG'  ;
					MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
					MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
					MCTYPE.MC_____NUMERO____B := SECUENCIA_R  ;
					MCTYPE.MC_____SECUINTE__B := CONSEC  ;
					MCTYPE.MC_____REFERENCI_B := REC_R0.DOCUMENTO||';'||REC_OS.CORRIDA  ;
					MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(REC_R.PERIODO,1,4)::INT  ;
					MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(REC_R.PERIODO,5,2)::INT  ;
					MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
					MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FUNCIONR', 'FAC', REC_R.CUENTA_CAJA,'', 1)  ;
					MCTYPE.MC_____CODIGO____CU_____B := REC_R.CENTRO_COSTO ;
					MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(REC_R.NITCLI)>10 THEN SUBSTR(REC_R.NITCLI,1,10) ELSE REC_R.NITCLI END;
					MCTYPE.MC_____DEBMONORI_B := 0  ;
					MCTYPE.MC_____CREMONORI_B := 0 ;
					MCTYPE.MC_____DEBMONLOC_B := CASE WHEN REC_R.VALOR_DEBITO::NUMERIC>=0 THEN REC_R.VALOR_DEBITO::NUMERIC ELSE 0 END ;
					MCTYPE.MC_____CREMONLOC_B := CASE WHEN REC_R.VALOR_DEBITO::NUMERIC<0 THEN REC_R.VALOR_DEBITO::NUMERIC*-1 ELSE 0 END ;
					MCTYPE.MC_____INDTIPMOV_B := 4  ;
					MCTYPE.MC_____INDMOVREV_B := 'N'  ;
					MCTYPE.MC_____OBSERVACI_B := REC_R0.DESCRIPCION  ;
					MCTYPE.MC_____FECHORCRE_B := REC_R.FECHA_CONTABILIZACION::TIMESTAMP  ;
					MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
					MCTYPE.MC_____FEHOULMO__B := REC_R.FECHA_CONTABILIZACION::TIMESTAMP  ;
					MCTYPE.MC_____AUTULTMOD_B := ''  ;
					MCTYPE.MC_____VALIMPCON_B := 0  ;
					MCTYPE.MC_____NUMERO_OPER_B := REC_R.NUM_INGRESO;
					MCTYPE.TERCER_CODIGO____TIT____B := REC_R.TERCER_CODIGO____TIT____B  ;
					MCTYPE.TERCER_NOMBCORT__B := SUBSTR(REC_R.TERCER_NOMBCORT__B,1,32)  ;
					MCTYPE.TERCER_NOMBEXTE__B := SUBSTR(REC_R.TERCER_NOMBEXTE__B,1,64)  ;
					MCTYPE.TERCER_APELLIDOS_B := SUBSTR(REC_R.TERCER_APELLIDOS_B,1,32)  ;
					MCTYPE.TERCER_CODIGO____TT_____B := REC_R.TERCER_CODIGO____TT_____B  ;
					MCTYPE.TERCER_DIRECCION_B := SUBSTR(REC_R.TERCER_DIRECCION_B,1,64)  ;
					MCTYPE.TERCER_CODIGO____CIUDAD_B := REC_R.TERCER_CODIGO____CIUDAD_B  ;
					MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(REC_R.TERCER_TELEFONO1_B)>15 THEN SUBSTR(REC_R.TERCER_TELEFONO1_B,1,15) ELSE REC_R.TERCER_TELEFONO1_B END;
					MCTYPE.TERCER_TIPOGIRO__B := 1 ;
					MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
					MCTYPE.TERCER_SUCURSAL__B := ''  ;
					MCTYPE.TERCER_NUMECUEN__B := ''  ;
					MCTYPE.MC_____CODIGO____DS_____B := '';
					MCTYPE.MC_____NUMDOCSOP_B := '';
					MCTYPE.MC_____NUMEVENC__B := NULL;
					MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
					MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

					--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
					SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
					CONSEC:=CONSEC+1;
					--RAISE NOTICE 'CONSEC 13: %',CONSEC;

					-----------------------------------------
					MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
					MCTYPE.MC_____SECUINTE__B := CONSEC  ;
					MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FUNCIONR', 'FAC', REC_R.CUENTA_R,'', 1)  ;
					--MCTYPE.MC_____CODIGO____CU_____B := REC_R.CENTRO_COSTO ;
					MCTYPE.MC_____DEBMONLOC_B := CASE WHEN REC_R.VALOR_DEBITO::NUMERIC<0 THEN REC_R.VALOR_DEBITO::NUMERIC*-1 ELSE 0 END ;
					MCTYPE.MC_____CREMONLOC_B := CASE WHEN REC_R.VALOR_DEBITO::NUMERIC>=0 THEN REC_R.VALOR_DEBITO::NUMERIC ELSE 0 END ;
					MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FUNCIONR', 'FAC', REC_R.CUENTA_R,'', 3);
					MCTYPE.MC_____NUMDOCSOP_B := REC_R0.DOCUMENTO;

					IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FUNCIONR', 'FAC', REC_R.CUENTA_R,'', 5)::INT=1)THEN
						MCTYPE.MC_____NUMEVENC__B := 1;
					ELSE
						MCTYPE.MC_____NUMEVENC__B := NULL;
					END IF;

					MCTYPE.MC_____FECHEMIS__B=FECHADOC_::TIMESTAMP  ;
					MCTYPE.MC_____FECHVENC__B=FECHADOC_::TIMESTAMP  ;

					--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
					SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
					CONSEC:=CONSEC+1;
					-----------------------------------------
				END LOOP;

				--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
				IF CON.SP_VALIDACIONES(MCTYPE,'LOGISTICA') ='N' THEN
					SW='N';

					--BORRAMOS EL COMPROBANTE DE ING
					DELETE FROM CON.MC____
					WHERE MC_____NUMERO____B = SECUENCIA_R AND MC_____CODIGO____CONTAB_B = 'FINT'
					 AND MC_____CODIGO____TD_____B = 'CXCN' AND  MC_____CODIGO____CD_____B = 'CRLG'  ;

					CONTINUE;
				END IF;

				CONSEC:=1;

			END LOOP;
			-----------------------------------
			--R CMC->TO Y OT
			-----------------------------------
-- IC215687 - R0034089 - R0034090
-- 			IC222726 - R0034088
--UPDATE con.factura set descripcion = descripcion||'-IC215687' where documento='R0034090'
			FOR REC_R2 IN
				SELECT
					DOCUMENTO,CMC, DESCRIPCION
				FROM
					CON.FACTURA
				WHERE REG_STATUS='' AND DOCUMENTO LIKE 'R0%'
				AND DESCRIPCION LIKE '%'||REC_OS.NUM_INGRESO||'%' AND CMC IN('TO','OT','DT','DG','DA')
				--and documento in('R0034088')
			LOOP

				--IF(REC_R2.CMC='TO')THEN

					--SECUENCIA DE LA R
					SELECT INTO SECUENCIA_R NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');
					VAL_AET :=0;
					VAL_AGA :=0;
					VAL_EXT :=0;

					FOR REC_R1 IN
						SELECT
							B.CREATION_DATE,
							A.PERIODO,
							B.CODIGO_CUENTA_CONTABLE AS CUENTA,
							B.VALOR_ITEM,
							--B.NIT,
							CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE B.NIT END AS NIT,
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
							(SELECT TIPO_OPERACION FROM FIN.ANTICIPOS_PAGOS_TERCEROS
							WHERE PLANILLA IN(
							replace(replace(replace(replace(replace(replace(
							(SUBSTR(B.DESCRIPCION, position('PLANILLA' in UPPER(B.DESCRIPCION))+8, CHAR_LENGTH(B.DESCRIPCION)))
							,chr(10),''),chr(11),''),chr(13),''),chr(27),''),chr(32),''),chr(39),'')
							)
							GROUP BY PLANILLA, TIPO_OPERACION LIMIT 1) AS TIPO,
							(SELECT CASE WHEN CONCEPT_CODE='01' THEN 'AET'
							WHEN CONCEPT_CODE='10' THEN 'AGA'
							WHEN CONCEPT_CODE='50' THEN 'EXT'
							ELSE '' END
							FROM FIN.ANTICIPOS_PAGOS_TERCEROS
						--WHERE PLANILLA IN(SUBSTR(B.DESCRIPCION, 10, CHAR_LENGTH(B.DESCRIPCION)))
						WHERE PLANILLA IN
							(
							replace(replace(replace(replace(replace(replace(
							(SUBSTR(B.DESCRIPCION, position('PLANILLA' in UPPER(B.DESCRIPCION))+8, CHAR_LENGTH(B.DESCRIPCION)))
							,chr(10),''),chr(11),''),chr(13),''),chr(27),''),chr(32),''),chr(39),'')
							)
							and reg_status='' LIMIT 1) AS CONCEPT_CODE,
							(select CONCEPTO
							from
							tem.homologacion_planillas_concepto
							WHERE
-- 							PLANILLA IN
-- 							(replace(replace(replace(replace(replace(replace(
--  							(B.DESCRIPCION)
--  							,chr(10),''),chr(11),''),chr(13),''),chr(27),''),chr(32),''),chr(39),'')
-- 							-- replace(replace(replace(replace(replace(replace(
-- -- 							(SUBSTR(B.DESCRIPCION, position('PLANILLA' in UPPER(B.DESCRIPCION))+8, CHAR_LENGTH(B.DESCRIPCION)))
-- -- 							,chr(10),''),chr(11),''),chr(13),''),chr(27),''),chr(32),''),chr(39),'')
-- 							) AND
							--NUM_INGRESO=REC_OS.NUM_INGRESO AND
							DOCUMENTO=A.DOCUMENTO
							limit 1
							) AS CONCEPT_CODE2,
							SUBSTR(B.DESCRIPCION, 10, CHAR_LENGTH(B.DESCRIPCION)) AS PLANILLA,
							B.DESCRIPCION
						 FROM
							CON.FACTURA A
						INNER JOIN
							CON.FACTURA_DETALLE B ON(B.DSTRCT=A.DSTRCT AND B.TIPO_DOCUMENTO=A.TIPO_DOCUMENTO AND B.DOCUMENTO=A.DOCUMENTO)
						LEFT JOIN
							PROVEEDOR C ON(C.NIT=B.NIT)
						LEFT JOIN
							NIT D ON(D.CEDULA=C.NIT)
						LEFT JOIN
							CIUDAD E ON(E.CODCIU=D.CODCIU)
						LEFT JOIN
							CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=B.NIT)
						WHERE
							A.DSTRCT='FINV' AND
							A.TIPO_DOCUMENTO='FAC' AND
							A.DOCUMENTO=REC_R2.DOCUMENTO

					LOOP

						FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(REC_R1.CREATION_DATE,1,7),'-','')=REC_R1.PERIODO THEN REC_R1.CREATION_DATE::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(REC_R1.PERIODO,1,4),SUBSTRING(REC_R1.PERIODO,5,2)::INT)::DATE END ;

						MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
						MCTYPE.MC_____CODIGO____TD_____B := 'CXCN' ;
						MCTYPE.MC_____CODIGO____CD_____B := 'CRLG'  ;
						MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
						MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
						MCTYPE.MC_____NUMERO____B := SECUENCIA_R  ;
						MCTYPE.MC_____SECUINTE__B := CONSEC  ;
						MCTYPE.MC_____REFERENCI_B := REC_R2.DOCUMENTO||';'||REC_OS.CORRIDA  ;
						MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(REC_R1.PERIODO,1,4)::INT  ;
						MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(REC_R1.PERIODO,5,2)::INT  ;
						MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
						MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FUNCIONR', 'FAC', REC_R1.CUENTA,'', 1)  ;
						MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(REC_R1.NIT)>10 THEN SUBSTR(REC_R1.NIT,1,10) ELSE REC_R1.NIT END;
						MCTYPE.MC_____DEBMONORI_B := 0  ;
						MCTYPE.MC_____CREMONORI_B := 0 ;
						MCTYPE.MC_____DEBMONLOC_B := 0;
						MCTYPE.MC_____CREMONLOC_B := REC_R1.VALOR_ITEM;
													-- IF(REC_R1.TIPO='AET')THEN
-- 														VAL_AET := VAL_AET+REC_R1.VALOR_ITEM::NUMERIC;
-- 													ELSIF(REC_R1.TIPO='AGA')THEN
-- 														VAL_AGA := VAL_AGA+REC_R1.VALOR_ITEM::NUMERIC;
-- 													ELSE
-- 														VAL_EXT := VAL_EXT+REC_R1.VALOR_ITEM::NUMERIC;
-- 													END IF;
								-- IF(REC_R1.TIPO!='')THEN
-- 									IF(REC_R1.TIPO='AET')THEN
-- 										VAL_AET := VAL_AET+REC_R1.VALOR_ITEM::NUMERIC;
-- 										_VAR_CU := 'A1111F21401' ;
-- 									ELSIF(REC_R1.TIPO='AGA')THEN
-- 										VAL_AGA := VAL_AGA+REC_R1.VALOR_ITEM::NUMERIC;
-- 										_VAR_CU := 'A1111F21501';
-- 									ELSIF(REC_R1.TIPO='EXT')THEN
-- 										VAL_EXT := VAL_EXT+REC_R1.VALOR_ITEM::NUMERIC;
-- 										_VAR_CU := 'A1111F22201';
-- 									END IF;
-- 								ELSE
								IF(REC_R2.CMC IN('DT','DG','DA'))THEN
									IF(REC_R2.CMC='DT')THEN
										VAL_AET := VAL_AET+REC_R1.VALOR_ITEM::NUMERIC;
										_VAR_CU := 'A1111F21401' ;
									ELSIF(REC_R2.CMC='DG')THEN
										VAL_AGA := VAL_AGA+REC_R1.VALOR_ITEM::NUMERIC;
										_VAR_CU := 'A1111F21501';
									ELSIF(REC_R2.CMC='DA')THEN
										VAL_EXT := VAL_EXT+REC_R1.VALOR_ITEM::NUMERIC;
										_VAR_CU := 'A1111F22201';
									END IF;
								ELSE
									IF(REC_R1.CONCEPT_CODE2='AET')THEN
										VAL_AET := VAL_AET+REC_R1.VALOR_ITEM::NUMERIC;
										_VAR_CU := 'A1111F21401' ;
									ELSIF(REC_R1.CONCEPT_CODE2='AGA')THEN
										VAL_AGA := VAL_AGA+REC_R1.VALOR_ITEM::NUMERIC;
										_VAR_CU := 'A1111F21501';
									ELSIF(REC_R1.CONCEPT_CODE2='EXT')THEN
										VAL_EXT := VAL_EXT+REC_R1.VALOR_ITEM::NUMERIC;
										_VAR_CU := 'A1111F22201';
									END IF;
								END IF;
								--END IF;
						MCTYPE.MC_____CODIGO____CU_____B := _VAR_CU;
						-- CASE WHEN REC_R1.TIPO='AET' THEN 'A1111F21401'
-- 															WHEN REC_R1.TIPO='AGA' THEN 'A1111F21501'
-- 															ELSE 'A1111F22201' END;
						MCTYPE.MC_____INDTIPMOV_B := 4  ;
						MCTYPE.MC_____INDMOVREV_B := 'N'  ;
						MCTYPE.MC_____OBSERVACI_B := CASE WHEN CHAR_LENGTH(REC_R1.DESCRIPCION)>255 THEN SUBSTR(REC_R1.DESCRIPCION,1,255) ELSE REC_R1.DESCRIPCION END;
						MCTYPE.MC_____FECHORCRE_B := REC_R1.CREATION_DATE::TIMESTAMP  ;
						MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
						MCTYPE.MC_____FEHOULMO__B := REC_R1.CREATION_DATE::TIMESTAMP  ;
						MCTYPE.MC_____AUTULTMOD_B := ''  ;
						MCTYPE.MC_____VALIMPCON_B := 0  ;
						MCTYPE.MC_____NUMERO_OPER_B := REC_OS.NUM_INGRESO;
						MCTYPE.TERCER_CODIGO____TIT____B := REC_R1.TERCER_CODIGO____TIT____B  ;
						MCTYPE.TERCER_NOMBCORT__B := SUBSTR(REC_R1.TERCER_NOMBCORT__B,1,32)  ;
						MCTYPE.TERCER_NOMBEXTE__B := SUBSTR(REC_R1.TERCER_NOMBEXTE__B,1,64)  ;
						MCTYPE.TERCER_APELLIDOS_B := SUBSTR(REC_R1.TERCER_APELLIDOS_B,1,32)  ;
						MCTYPE.TERCER_CODIGO____TT_____B := REC_R1.TERCER_CODIGO____TT_____B  ;
						MCTYPE.TERCER_DIRECCION_B := SUBSTR(REC_R1.TERCER_DIRECCION_B,1,64)  ;
						MCTYPE.TERCER_CODIGO____CIUDAD_B := REC_R1.TERCER_CODIGO____CIUDAD_B  ;
						MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(REC_R1.TERCER_TELEFONO1_B)>15 THEN SUBSTR(REC_R1.TERCER_TELEFONO1_B,1,15) ELSE REC_R1.TERCER_TELEFONO1_B END;
						MCTYPE.TERCER_TIPOGIRO__B := 1 ;
						MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
						MCTYPE.TERCER_SUCURSAL__B := ''  ;
						MCTYPE.TERCER_NUMECUEN__B := ''  ;
						MCTYPE.MC_____CODIGO____DS_____B := '';
						MCTYPE.MC_____NUMDOCSOP_B := '';
						MCTYPE.MC_____NUMEVENC__B := NULL;
						MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
						MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

						--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
						SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
						CONSEC:=CONSEC+1;
						--RAISE NOTICE 'CONSEC 13: %',CONSEC;

					END LOOP;

					MCTYPE.MC_____CREMONLOC_B := 0;
					MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FUNCIONR', 'FAC', _ARRCUENTASAET[4],'', 3);
					MCTYPE.MC_____NUMDOCSOP_B := REC_R2.DOCUMENTO;

					IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FUNCIONR', 'FAC', _ARRCUENTASAET[4],'', 5)::INT=1)THEN
						MCTYPE.MC_____NUMEVENC__B := 1;
					ELSE
						MCTYPE.MC_____NUMEVENC__B := NULL;
					END IF;

					MCTYPE.MC_____FECHEMIS__B=FECHADOC_::DATE  ;
					MCTYPE.MC_____FECHVENC__B=FECHADOC_::DATE  ;

					IF(VAL_AET>0)THEN
						-----------------------------------------
						MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
						MCTYPE.MC_____SECUINTE__B := CONSEC  ;
						MCTYPE.MC_____CODIGO____CPC____B := '13050503'  ;
						MCTYPE.MC_____CODIGO____CU_____B := 'A1111F21401';
						MCTYPE.MC_____DEBMONLOC_B := VAL_AET::NUMERIC;

						--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
						SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
						CONSEC:=CONSEC+1;
						-----------------------------------------
					END IF;

					IF(VAL_AGA>0)THEN
						-----------------------------------------
						MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
						MCTYPE.MC_____SECUINTE__B := CONSEC  ;
						MCTYPE.MC_____CODIGO____CPC____B := '13050503'  ;
						MCTYPE.MC_____CODIGO____CU_____B := 'A1111F21501';
						MCTYPE.MC_____DEBMONLOC_B := VAL_AGA::NUMERIC;

						--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
						SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
						CONSEC:=CONSEC+1;
						-----------------------------------------
					END IF;

					IF(VAL_EXT>0)THEN
						-----------------------------------------
						MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
						MCTYPE.MC_____SECUINTE__B := CONSEC  ;
						MCTYPE.MC_____CODIGO____CPC____B := '13050503'  ;
						MCTYPE.MC_____CODIGO____CU_____B := 'A1111F22201';
						MCTYPE.MC_____DEBMONLOC_B := VAL_EXT::NUMERIC;

						--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
						SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
						CONSEC:=CONSEC+1;
						-----------------------------------------
					END IF;

					--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
					IF CON.SP_VALIDACIONES(MCTYPE,'LOGISTICA') ='N' THEN
						SW='N';

						--BORRAMOS EL COMPROBANTE DE ING
						DELETE FROM CON.MC____
						WHERE MC_____NUMERO____B = SECUENCIA_R AND MC_____CODIGO____CONTAB_B = 'FINT'
						 AND MC_____CODIGO____TD_____B = 'CXCN' AND  MC_____CODIGO____CD_____B = 'CRLG'  ;

						CONTINUE;
					END IF;

				--END IF;

			END LOOP;

			--ACTUALIZAMOS EL REGISTRO EN OS PARA SABER QUE SE PROCESO
			IF(SW='S')THEN
				UPDATE
					EGRESODET_TSP
				SET
					PROCESADO_R='S'
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
ALTER FUNCTION con.interfaz_fintra_logistica_apoteosys_r_cxc_descuadre()
  OWNER TO postgres;
