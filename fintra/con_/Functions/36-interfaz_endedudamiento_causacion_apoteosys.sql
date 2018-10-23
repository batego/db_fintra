-- Function: con.interfaz_endedudamiento_causacion_apoteosys()

-- DROP FUNCTION con.interfaz_endedudamiento_causacion_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_endedudamiento_causacion_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
	r_detalle_credito record;
	r_causacion record;
	periodo_ text;
	creation_date_ text;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;


BEGIN

	-- 2. Buscamos las notas de causación de intereses y egresos del crédito que no se hayan enviado a Apoteosys
	FOR r_detalle_credito IN
				SELECT
					cbd.dstrct,
					cbd.nit_banco,
					cbd.documento,
					cbd.id,
					cbd.doc_intereses,
					cbd.doc_pago, cb.cupo,
					cbd.fecha_final,
					(substring(cbd.fecha_final,1,4)||substring(cbd.fecha_final,6,2)) as periodo,
					cbd.interes_acumulado,
					cbd.creation_date
				FROM fin.credito_bancario_detalle cbd
				INNER JOIN fin.credito_bancario cb on(cb.dstrct=cbd.dstrct and cb.nit_banco=cbd.nit_banco and cb.documento=cbd.documento)
				INNER JOIN fin.cxp_doc cxp ON cxp.documento = cbd.documento
					AND cxp.proveedor = cbd.nit_banco
					AND cxp.dstrct = cbd.dstrct
				WHERE 	cbd.dstrct = 'FINV'
					AND cb.procesado_apo='S'
					AND cbd.procesado_apo = 'N'  --DEBE IR EN N
					AND cbd.doc_pago = ''
					AND (substring(cbd.fecha_final,1,4)||substring(cbd.fecha_final,6,2)) =REPLACE(SUBSTRING(NOW(),1,7),'-','')
					--AND cbd.documento = '106080003796'
				ORDER BY cbd.documento, cbd.id

	LOOP


		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_CXP_APOTEOSYS');
	-- 2.2. Buscamos las notas de causación de intereses
		-- obtenemos los datos del debe
		FOR r_causacion IN
				SELECT
					cxp.periodo,
					cxp.creation_date,
					--cxp_det.documento,
					'EGR' as documento,
					cxp_det.codigo_cuenta as cuenta,
					cxp_det.descripcion ||'=>'||cxp.documento as descripcion,
					cxp_det.vlr as valor_debito,
					0 as valor_credito,
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
				FROM
					fin.cxp_items_doc cxp_det
				INNER JOIN fin.cxp_doc  cxp ON cxp.dstrct = cxp_det.dstrct AND  cxp.tipo_documento = cxp_det.tipo_documento AND cxp.documento = cxp_det.documento
				LEFT JOIN PROVEEDOR C ON(C.NIT=CXP.PROVEEDOR)
				LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=CXP.PROVEEDOR)
				WHERE
					cxp_det.dstrct = r_detalle_credito.dstrct and
					cxp_det.reg_status != 'A' AND
					cxp_det.tipo_documento = 'ND' AND
					cxp_det.documento = r_detalle_credito.doc_intereses AND
					cxp_det.proveedor = r_detalle_credito.nit_banco
				UNION ALL
				SELECT
					cxp.periodo,
					cxp.creation_date,
					--cxp.documento,
					--cmc.cuenta,
					'ND' as documento,
					'21051008' as cuenta,
					cxp.descripcion||'=>'||cxp.documento as descripcion,
					0,
					cxp.vlr_neto as credito,
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
				FROM
					fin.cxp_doc  cxp
				INNER JOIN con.cmc_doc cmc ON cmc.cmc = cxp.handle_code AND cmc.tipodoc = cxp.tipo_documento
				LEFT JOIN PROVEEDOR C ON(C.NIT=CXP.PROVEEDOR)
				LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=CXP.PROVEEDOR)
				WHERE
				cxp.dstrct = r_detalle_credito.dstrct and
				cxp.reg_status != 'A' AND
				cxp.tipo_documento = 'ND' AND
				cxp.documento = r_detalle_credito.doc_intereses and
				cxp.proveedor = r_detalle_credito.nit_banco
		LOOP

			-- Insertamos en la tabla de Apoteosys
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r_detalle_credito.fecha_final::DATE,1,7),'-','')=r_detalle_credito.periodo THEN r_detalle_credito.fecha_final::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(r_detalle_credito.periodo,1,4),SUBSTRING(r_detalle_credito.periodo,5,2)::INT)::DATE END ;

				if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_causacion.documento, r_causacion.CUENTA,'', 6)='S')then
					MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
					MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
				else
					MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
					MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

				end if;

				MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
				MCTYPE.MC_____CODIGO____TD_____B := 'CXPN' ;
				MCTYPE.MC_____CODIGO____CD_____B := 'NDEB'  ;
				MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
				MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
				MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
				MCTYPE.MC_____SECUINTE__B := CONSEC  ;
				MCTYPE.MC_____REFERENCI_B := r_detalle_credito.DOCUMENTO  ;
				MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(r_detalle_credito.PERIODO,1,4)::INT;
				MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(r_detalle_credito.PERIODO,5,2)::INT;
				MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
				MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_causacion.documento, r_causacion.CUENTA,'', 1)  ;
				MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', 'CC', r_detalle_credito.cupo,'', 2)  ;
				MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(r_causacion.proveedor)>10 THEN SUBSTR(r_causacion.proveedor,1,10) ELSE r_causacion.proveedor END;
				MCTYPE.MC_____DEBMONORI_B := 0  ;
				MCTYPE.MC_____CREMONORI_B := 0 ;
				MCTYPE.MC_____DEBMONLOC_B := r_causacion.VALOR_DEBITO::NUMERIC  ;
				MCTYPE.MC_____CREMONLOC_B := r_causacion.VALOR_CREDITO::NUMERIC  ;
				MCTYPE.MC_____INDTIPMOV_B := 4  ;
				MCTYPE.MC_____INDMOVREV_B := 'N'  ;
				MCTYPE.MC_____OBSERVACI_B := r_causacion.DESCRIPCION ;
				MCTYPE.MC_____FECHORCRE_B := r_detalle_credito.fecha_final::TIMESTAMP  ;
				MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
				MCTYPE.MC_____FEHOULMO__B := r_detalle_credito.fecha_final::TIMESTAMP  ;
				MCTYPE.MC_____AUTULTMOD_B := ''  ;
				MCTYPE.MC_____VALIMPCON_B := 0  ;
				MCTYPE.MC_____NUMERO_OPER_B := r_detalle_credito.DOCUMENTO;
				MCTYPE.TERCER_CODIGO____TIT____B := r_causacion.TERCER_CODIGO____TIT____B  ;
				MCTYPE.TERCER_NOMBCORT__B := r_causacion.TERCER_NOMBCORT__B  ;
				MCTYPE.TERCER_NOMBEXTE__B := r_causacion.TERCER_NOMBEXTE__B  ;
				MCTYPE.TERCER_APELLIDOS_B := r_causacion.TERCER_APELLIDOS_B  ;
				MCTYPE.TERCER_CODIGO____TT_____B := r_causacion.TERCER_CODIGO____TT_____B  ;
				MCTYPE.TERCER_DIRECCION_B := r_causacion.TERCER_DIRECCION_B  ;
				MCTYPE.TERCER_CODIGO____CIUDAD_B := r_causacion.TERCER_CODIGO____CIUDAD_B  ;
				MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(r_causacion.TERCER_TELEFONO1_B)>15 THEN SUBSTR(r_causacion.TERCER_TELEFONO1_B,1,15) ELSE r_causacion.TERCER_TELEFONO1_B END;
				MCTYPE.TERCER_TIPOGIRO__B := 1 ;
				MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
				MCTYPE.TERCER_SUCURSAL__B := ''  ;
				MCTYPE.TERCER_NUMECUEN__B := ''  ;
				MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_causacion.documento, r_causacion.CUENTA,'', 3);
				--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
				MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_causacion.documento, r_causacion.CUENTA,'', 5)::INT;

				if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_causacion.documento, r_causacion.CUENTA,'', 4)='S')then
					MCTYPE.MC_____NUMDOCSOP_B := r_detalle_credito.DOCUMENTO;
				else
					MCTYPE.MC_____NUMDOCSOP_B := '';
				end if;

				if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_causacion.documento, r_causacion.CUENTA,'', 5)::int=1)then
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
			DELETE FROM CON.MC____
			WHERE MC_____NUMERO____B = SECUENCIA_EXT AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'CXPN' AND  MC_____CODIGO____CD_____B = 'NDEB'  ;

			CONTINUE;
		END IF;

		IF(SW='S')THEN
			-- MARCAMOS EN DETALLE DEL CRéDITO QUE YA SE ENVíO A APOTEOSYS
			UPDATE
				FIN.CREDITO_BANCARIO_DETALLE
			SET
				PROCESADO_APO = 'S'
			WHERE
				DSTRCT = 'FINV' AND
				DOC_INTERESES = R_DETALLE_CREDITO.DOC_INTERESES AND
				DOCUMENTO = R_DETALLE_CREDITO.DOCUMENTO;

			SW:='N';
		END IF;

		CONSEC:=1;
		raise notice 'doc_int: % doc: %',r_detalle_credito.doc_intereses,r_detalle_credito.documento;

	END LOOP;

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_endedudamiento_causacion_apoteosys()
  OWNER TO postgres;
