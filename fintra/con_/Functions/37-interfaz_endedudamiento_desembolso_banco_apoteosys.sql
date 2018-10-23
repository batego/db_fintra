-- Function: con.interfaz_endedudamiento_desembolso_banco_apoteosys()

-- DROP FUNCTION con.interfaz_endedudamiento_desembolso_banco_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_endedudamiento_desembolso_banco_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
	CreditosBancarios record;
	r_asiento record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;



BEGIN
	-- 1. Buscamos los créditos con saldo 0 que no se hayan enviado a Apoteosys
	FOR CreditosBancarios IN
				SELECT  cbd.dstrct,
					cbd.documento,
					cbd.nit_banco,
					cbd.fecha_inicial,
					(substring(cbd.fecha_inicial,1,4)||substring(cbd.fecha_inicial,6,2)) as periodo,
					cbd.cupo
				FROM fin.credito_bancario cbd
				INNER JOIN fin.cxp_doc cxp
					ON cxp.documento = cbd.documento
					AND cxp.proveedor = cbd.nit_banco
					AND cxp.dstrct = cbd.dstrct
				WHERE
					cbd.reg_status='' and
					cxp.reg_status='' and
					cbd.procesado_apo = 'N' AND
					cbd.dstrct = 'FINV'
					AND cbd.fecha_inicial BETWEEN '2017-01-01' AND CURRENT_DATE
					--AND cbd.documento = '8903002794'
				ORDER BY cbd.documento
	LOOP
		-- Creamos el asiento contable de desembolso del crédito
		--obtenemos los datos del Débito y el Crédito
		raise notice 'documento: % nit %', CreditosBancarios.documento,CreditosBancarios.nit_banco;

		--SECUENCIA DEL CXP
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_CXP_APOTEOSYS');

		FOR r_asiento IN
				SELECT
					cxp.tipo_documento,
					cxp.periodo,
					cxp_det.documento,
					cxp_det.codigo_cuenta as cuenta,
					cxp_det.descripcion,
					cxp_det.vlr as valor_debito,
					0 as valor_credito,
					cxp.creation_date,
					cxp_det.descripcion,
					--cxp_det.proveedor,
					CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE cxp_det.proveedor END AS proveedor,
					(CASE
					 WHEN D.TIPO_IDEN='CED' THEN 'CC'
					 WHEN D.TIPO_IDEN='RIF' THEN 'CE'
					 WHEN D.TIPO_IDEN='' THEN 'CC'
					 WHEN D.TIPO_IDEN='NIT' THEN 'NIT'
					 ELSE
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
				FROM fin.cxp_items_doc  cxp_det
				INNER JOIN fin.cxp_doc  cxp ON cxp.dstrct = cxp_det.dstrct AND  cxp.tipo_documento = cxp_det.tipo_documento AND cxp.documento = cxp_det.documento
				LEFT JOIN PROVEEDOR C ON(C.NIT=CXP_DET.PROVEEDOR)
				LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=CXP_DET.PROVEEDOR)
				WHERE
					cxp_det.dstrct = CreditosBancarios.dstrct and
					cxp_det.reg_status != 'A' AND
					cxp_det.tipo_documento = 'FAP' and
					cxp_det.documento = CreditosBancarios.documento and
					cxp_det.proveedor = CreditosBancarios.nit_banco
				UNION ALL
				SELECT
					cxp.tipo_documento,
					cxp.periodo,
					cxp.documento,
					cmc.cuenta,
					cxp.descripcion,
					0::numeric as valor_debito,
					cxp.vlr_neto as valor_credito ,
					cxp.creation_date,
					cxp.descripcion,
					--cxp.proveedor,
					CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE cxp.proveedor END AS proveedor,
					(CASE
					 WHEN D.TIPO_IDEN='CED' THEN 'CC'
					 WHEN D.TIPO_IDEN='RIF' THEN 'CE'
					 WHEN D.TIPO_IDEN='' THEN 'CC'
					 WHEN D.TIPO_IDEN='NIT' THEN 'NIT'
					 ELSE
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
				FROM fin.cxp_doc  cxp
				INNER JOIN con.cmc_doc cmc ON cmc.cmc = cxp.handle_code AND cmc.tipodoc = cxp.tipo_documento
				LEFT JOIN PROVEEDOR C ON(C.NIT=CXP.PROVEEDOR)
				LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=CXP.PROVEEDOR)
				WHERE
					cxp.dstrct = CreditosBancarios.dstrct and
					cxp.reg_status != 'A' AND
					cxp.tipo_documento = 'FAP' and
					cxp.documento = CreditosBancarios.documento and
					cxp.proveedor = CreditosBancarios.nit_banco

		LOOP

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(CreditosBancarios.fecha_inicial::DATE,1,7),'-','')=CreditosBancarios.periodo THEN CreditosBancarios.fecha_inicial::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(CreditosBancarios.PERIODO,1,4),SUBSTRING(CreditosBancarios.PERIODO,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'CXPN' ;
			MCTYPE.MC_____CODIGO____CD_____B := 'APEB'  ;
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := CREDITOSBANCARIOS.DOCUMENTO  ;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(CreditosBancarios.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(CreditosBancarios.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', 'CC', CreditosBancarios.cupo,'', 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(R_ASIENTO.PROVEEDOR)>10 THEN SUBSTR(R_ASIENTO.PROVEEDOR,1,10) ELSE R_ASIENTO.PROVEEDOR END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION  ;
			MCTYPE.MC_____FECHORCRE_B := CreditosBancarios.fecha_inicial::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := CreditosBancarios.fecha_inicial::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := CREDITOSBANCARIOS.DOCUMENTO;
			MCTYPE.TERCER_CODIGO____TIT____B := R_ASIENTO.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := R_ASIENTO.TERCER_NOMBCORT__B  ;
			MCTYPE.TERCER_NOMBEXTE__B := R_ASIENTO.TERCER_NOMBEXTE__B  ;
			MCTYPE.TERCER_APELLIDOS_B := R_ASIENTO.TERCER_APELLIDOS_B  ;
			MCTYPE.TERCER_CODIGO____TT_____B := R_ASIENTO.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := R_ASIENTO.TERCER_DIRECCION_B  ;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := R_ASIENTO.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_TELEFONO1_B)>15 THEN SUBSTR(R_ASIENTO.TERCER_TELEFONO1_B,1,15) ELSE R_ASIENTO.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 4)='S')then
				MCTYPE.MC_____NUMDOCSOP_B := CREDITOSBANCARIOS.DOCUMENTO;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC_ENDEUDAMIENTO____(MCTYPE);
			CONSEC:=CONSEC+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'ENDEUDAMIENTO') ='N' THEN
			SW='N';

			--BORRAMOS EL COMPROBANTE DE EXT
			DELETE FROM CON.MC_ENDEUDAMIENTO____
			WHERE MC_____NUMERO____B = SECUENCIA_GEN AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'CXPN' AND  MC_____CODIGO____CD_____B = 'APEB'  ;

			CONTINUE;
		END IF;

		-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
		IF(SW='S')THEN
			UPDATE
				FIN.CREDITO_BANCARIO
			SET
				PROCESADO_APO = 'S'
			WHERE DSTRCT = CREDITOSBANCARIOS.DSTRCT  AND
				DOCUMENTO = CREDITOSBANCARIOS.DOCUMENTO;

			SW:='N';
		END IF;

		CONSEC:=1;

	END LOOP;



RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_endedudamiento_desembolso_banco_apoteosys()
  OWNER TO postgres;
