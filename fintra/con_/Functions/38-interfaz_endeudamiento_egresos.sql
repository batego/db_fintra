-- Function: con.interfaz_endeudamiento_egresos()

-- DROP FUNCTION con.interfaz_endeudamiento_egresos();

CREATE OR REPLACE FUNCTION con.interfaz_endeudamiento_egresos()
  RETURNS text AS
$BODY$

DECLARE
	r_detalle_credito record;
	v_intereses numeric;
	v_intereses_c numeric;
	r_asiento record;
	periodo_ text;
	creation_date_ text;
	documento_int_ text;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;


BEGIN
	v_intereses := 0;

	-- 2. Buscamos los egresos del crédito que no se hayan enviado a Apoteosys
	FOR r_detalle_credito IN
				SELECT cbd.dstrct,
				       cbd.nit_banco,
				       cbd.documento,
				       cbd.id,
				       cbd.doc_intereses,
				       cbd.doc_pago,
				       cb.cupo,
				       cb.fecha_inicial as fecha_inicio,
				       cb.creation_date,
				       cbd.fecha_final,
				       (substring(cbd.fecha_final,1,4)||substring(cbd.fecha_final,6,2)) as periodo
				FROM fin.credito_bancario_detalle cbd
				INNER JOIN fin.credito_bancario cb on(cb.dstrct=cbd.dstrct and cb.nit_banco=cbd.nit_banco and cb.documento=cbd.documento)
				INNER JOIN fin.cxp_doc cxp ON cxp.documento = cbd.documento
					AND cxp.proveedor = cbd.nit_banco
					AND cxp.dstrct = cbd.dstrct
				WHERE cxp.reg_status='' and
					cbd.dstrct = 'FINV' and
					cb.procesado_apo='S' --PARA VERIFICAR QUE ESTE EL NACIMIENTO
					AND cbd.procesado_apo = 'N'
					AND cbd.doc_pago != ''
					--AND cbd.creation_date BETWEEN '2017-01-01' AND CURRENT_DATE
					AND (substring(cbd.fecha_final,1,4)||substring(cbd.fecha_final,6,2))=REPLACE(SUBSTRING(NOW(),1,7),'-','')

				ORDER BY cbd.documento, cbd.id
	LOOP

		documento_int_:='';
		v_intereses:=0;
		v_intereses_c:=0;

		--Buscamos la CXP de la ND generada
		v_intereses:= coalesce((SELECT
								cxp_det.vlr
							FROM fin.cxp_items_doc cxp_det
							WHERE cxp_det.dstrct = 'FINV' AND cxp_det.tipo_documento = 'ND'
							AND cxp_det.documento = r_detalle_credito.doc_intereses AND cxp_det.proveedor = r_detalle_credito.nit_banco),0);

		--Obtenemos el documento de intereses inmediatamente anterior
		SELECT INTO documento_int_
			doc_intereses
		FROM
		fin.credito_bancario_detalle  cbd
		where
		cbd.documento=r_detalle_credito.documento and
		fecha_final=(SELECT fecha_inicial FROM fin.credito_bancario_detalle  where documento=cbd.documento and  doc_intereses =r_detalle_credito.doc_intereses) and doc_pago='' ;

		v_intereses_c:= coalesce((SELECT cxp_det.vlr
							FROM fin.cxp_items_doc cxp_det
							WHERE cxp_det.dstrct = 'FINV' AND cxp_det.tipo_documento = 'ND'
							AND cxp_det.documento = documento_int_  AND cxp_det.proveedor = r_detalle_credito.nit_banco),0);

		raise notice 'Intereses1:%',v_intereses;
		raise notice 'Intereses2:%',v_intereses_c;


		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_EGRESO_APOTEOSYS');

		FOR r_asiento IN
				SELECT
				    eg.periodo,
				    eg.creation_date,
				    e.document_no,
				    'EGR' as TIPO_DOCUMENTO,
				    CASE
				    WHEN e.cuenta != '' THEN e.cuenta
				    ELSE cmc.cuenta
				    END AS cuenta,
				    e.branch_code as descripcion,
				    e.vlr - (v_intereses+v_intereses_c) AS valor_debito,
				    0::numeric as valor_credito,
				    --pr.nit,
				    CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE PR.nit END AS nit,
				    (CASE
					 WHEN D.TIPO_IDEN='CED' THEN 'CC'
					 WHEN D.TIPO_IDEN='RIF' THEN 'CE'
					 WHEN D.TIPO_IDEN='' THEN 'CC'
					 WHEN D.TIPO_IDEN='NIT' THEN 'NIT'
					 ELSE
					 'CC' END) AS TERCER_CODIGO____TIT____B,
					 PR.DIGITO_VERIFICACION AS TERCER_DIGICHEQ__B,
					 (D.NOMBRE1||' '||D.NOMBRE2) AS TERCER_NOMBCORT__B,
					 (D.APELLIDO1||' '||D.APELLIDO2) AS TERCER_APELLIDOS_B,
					 D.NOMBRE AS TERCER_NOMBEXTE__B,
					 (CASE
					 WHEN PR.GRAN_CONTRIBUYENTE='N' AND PR.AGENTE_RETENEDOR='N' THEN 'RCOM'
					 WHEN PR.GRAN_CONTRIBUYENTE='N' AND PR.AGENTE_RETENEDOR='S' THEN 'RCAU'
					 WHEN PR.GRAN_CONTRIBUYENTE='S' AND PR.AGENTE_RETENEDOR='N' THEN 'GCON'
					 WHEN PR.GRAN_CONTRIBUYENTE='S' AND PR.AGENTE_RETENEDOR='S' THEN 'GCAU'
					 ELSE 'PNAL' END) AS TERCER_CODIGO____TT_____B,
					 D.DIRECCION AS TERCER_DIRECCION_B,
					 (CASE
					 WHEN F.CODIGO_DANE2!='' THEN F.CODIGO_DANE2
					 ELSE '08001' END) AS TERCER_CODIGO____CIUDAD_B,
					 D.TELEFONO AS TERCER_TELEFONO1_B
				FROM egresodet e
				INNER JOIN egreso eg ON (eg.dstrct= e.dstrct AND eg.branch_code =e.branch_code AND eg.bank_account_no=e.bank_account_no
				    AND eg.document_no =e.document_no)
				LEFT JOIN proveedor pr ON (pr.dstrct = e.dstrct AND pr.nit=eg.nit)
				LEFT JOIN fin.cxp_doc cxp ON (cxp.dstrct=e.dstrct AND cxp.proveedor=eg.nit_proveedor AND cxp.tipo_documento=e.tipo_documento
				    AND cxp.documento=e.documento)
				LEFT JOIN con.cmc_doc cmc ON (cmc.dstrct=e.dstrct AND cmc.tipodoc ='EGR' AND cmc.cmc=cxp.handle_code AND cmc.reg_status!='A')
				LEFT JOIN NIT D ON(D.CEDULA=pr.NIT)
				LEFT JOIN CIUDAD F ON(F.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=pr.NIT)
				WHERE e.reg_status!='A' AND e.dstrct = 'FINV'
				AND e.document_no = r_detalle_credito.doc_pago
				AND e.documento = r_detalle_credito.documento and
				(e.vlr-(v_intereses+v_intereses_c))!=0
				UNION ALL
				SELECT cxp.periodo,
					cxp.creation_date,
				      cxp_det.documento,
				      CXP.TIPO_DOCUMENTO,
				      cxp_det.codigo_cuenta,
				      cxp_det.descripcion,
				      cxp_det.vlr as valor_debito,
				      0::numeric as valor_credito,
				      --C.nit,
				      CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE C.nit END AS nit,
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
				FROM fin.cxp_items_doc cxp_det
				INNER JOIN fin.cxp_doc  cxp ON cxp.dstrct = cxp_det.dstrct AND  cxp.tipo_documento = cxp_det.tipo_documento AND cxp.documento = cxp_det.documento
				LEFT JOIN PROVEEDOR C ON(C.NIT=CXP.PROVEEDOR)
				LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=CXP.PROVEEDOR)
				WHERE cxp_det.reg_status!='A' AND cxp_det.dstrct = 'FINV' AND cxp_det.documento = r_detalle_credito.doc_intereses and cxp_det.vlr!=0
				UNION ALL
				SELECT cxp.periodo,
					cxp.creation_date,
				      cxp_det.documento,
				      'ND' as TIPO_DOCUMENTO,
				       '21051008' as codigo_cuenta,
				      cxp_det.descripcion,
				      cxp_det.vlr as valor_debito,
				      0::numeric as valor_credito,
				      --C.nit,
				      CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE C.nit END AS nit,
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
				FROM fin.cxp_items_doc cxp_det
				INNER JOIN fin.cxp_doc  cxp ON cxp.dstrct = cxp_det.dstrct AND  cxp.tipo_documento = cxp_det.tipo_documento AND cxp.documento = cxp_det.documento
				LEFT JOIN PROVEEDOR C ON(C.NIT=CXP.PROVEEDOR)
				LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
				LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=CXP.PROVEEDOR)
				WHERE cxp_det.reg_status!='A' AND cxp_det.dstrct = 'FINV' AND cxp_det.documento = documento_int_ and cxp_det.vlr!=0
				UNION ALL
				SELECT eg.periodo,
					eg.creation_date,
					 e.document_no,
					 'EGR' as TIPO_DOCUMENTO,
					 b.codigo_cuenta,
					 e.branch_code,
					 0::numeric as valor_debito,
					 e.vlr/*+(SELECT
						cxp_det.vlr
					FROM fin.cxp_items_doc cxp_det
					WHERE cxp_det.reg_status!='A' AND cxp_det.dstrct = 'FINV' AND cxp_det.documento = documento_int_ and cxp_det.vlr!=0)*/ as valor_credito,
					 --C.nit,
					 CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE c.NIT END AS NIT,
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
					 WHEN F.CODIGO_DANE2!='' THEN F.CODIGO_DANE2
					 ELSE '08001' END) AS TERCER_CODIGO____CIUDAD_B,
					 D.TELEFONO AS TERCER_TELEFONO1_B
				from egreso eg
				inner join egresodet e ON (eg.dstrct= e.dstrct AND eg.branch_code = e.branch_code   AND eg.bank_account_no = e.bank_account_no
					AND eg.document_no = e.document_no)
				left join banco b on (b.branch_code=e.branch_code and b.bank_account_no=e.bank_account_no)
				LEFT JOIN PROVEEDOR C ON(C.NIT=eg.nit)
				LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
				LEFT JOIN CIUDAD F ON(F.CODCIU=D.CODCIU)
				LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=eg.nit)
				where eg.reg_status!='A' AND eg.dstrct = 'FINV' AND e.document_no = r_detalle_credito.doc_pago AND e.documento = r_detalle_credito.documento and e.vlr!=0

			LOOP
			-- Insertamos los datos del Crédito en la tabla de Apoteosys
				FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r_detalle_credito.fecha_final::DATE,1,7),'-','')=r_detalle_credito.periodo THEN r_detalle_credito.fecha_final::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(r_detalle_credito.periodo,1,4),SUBSTRING(r_detalle_credito.periodo,5,2)::INT)::DATE END ;

				if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 6)='S')then
					MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
					MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
				else
					MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
					MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

				end if;

				MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
				MCTYPE.MC_____CODIGO____TD_____B := 'EGRN' ;
				MCTYPE.MC_____CODIGO____CD_____B := 'EGEB'  ;
				MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
				MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
				MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
				MCTYPE.MC_____SECUINTE__B := CONSEC  ;
				MCTYPE.MC_____REFERENCI_B := r_detalle_credito.DOCUMENTO  ;
				MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(r_detalle_credito.periodo,1,4)::INT;
				MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(r_detalle_credito.periodo,5,2)::INT;
				MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
				MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_asiento.tipo_documento, R_ASIENTO.CUENTA,'', 1)  ;
				MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', 'CC', r_detalle_credito.cupo,'', 2)  ;
				MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(R_ASIENTO.NIT)>10 THEN SUBSTR(R_ASIENTO.NIT,1,10) ELSE R_ASIENTO.NIT END;
				MCTYPE.MC_____DEBMONORI_B := 0  ;
				MCTYPE.MC_____CREMONORI_B := 0 ;
				MCTYPE.MC_____DEBMONLOC_B := CASE WHEN R_ASIENTO.VALOR_DEBITO::NUMERIC>0 THEN R_ASIENTO.VALOR_DEBITO::NUMERIC ELSE 0 END ;
				MCTYPE.MC_____CREMONLOC_B := CASE WHEN R_ASIENTO.VALOR_DEBITO::NUMERIC<0 THEN R_ASIENTO.VALOR_DEBITO::NUMERIC*-1 ELSE R_ASIENTO.VALOR_CREDITO::NUMERIC END ;
				MCTYPE.MC_____INDTIPMOV_B := 4  ;
				MCTYPE.MC_____INDMOVREV_B := 'N'  ;
				MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION||'-'||R_DETALLE_CREDITO.DOC_PAGO;
				MCTYPE.MC_____FECHORCRE_B := r_detalle_credito.fecha_final::TIMESTAMP  ;
				MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
				MCTYPE.MC_____FEHOULMO__B := r_detalle_credito.fecha_final::TIMESTAMP  ;
				MCTYPE.MC_____AUTULTMOD_B := ''  ;
				MCTYPE.MC_____VALIMPCON_B := 0  ;
				MCTYPE.MC_____NUMERO_OPER_B := r_detalle_credito.DOCUMENTO;
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
				MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_asiento.tipo_documento, R_ASIENTO.CUENTA,'', 3);

				MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_asiento.tipo_documento, R_ASIENTO.CUENTA,'', 5)::INT;

				if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_asiento.tipo_documento, R_ASIENTO.CUENTA,'', 4)='S')then
					MCTYPE.MC_____NUMDOCSOP_B := r_detalle_credito.DOCUMENTO;
				else
					MCTYPE.MC_____NUMDOCSOP_B := '';
				end if;

				if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDEUDAMIENTO', r_asiento.tipo_documento, R_ASIENTO.CUENTA,'', 5)::int=1)then
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
				 AND MC_____CODIGO____TD_____B = 'EGRN' AND  MC_____CODIGO____CD_____B = 'EGEB'  ;

				CONSEC:=1;
				CONTINUE;
			END IF;

			-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
			IF(SW='S')THEN
				-- ACTUALIZAMOS EN CREDITO_BANCARIO_DETALLE EL CAMPO DE APOTEOSYS COMO "S"
				UPDATE
					FIN.CREDITO_BANCARIO_DETALLE
				SET
					PROCESADO_APO = 'S'
				WHERE
					DSTRCT = R_DETALLE_CREDITO.DSTRCT  AND
					DOC_PAGO = R_DETALLE_CREDITO.DOC_PAGO AND
					DOCUMENTO = R_DETALLE_CREDITO.DOCUMENTO;

				SW:='N';
			END IF;

			CONSEC:=1;

	END LOOP;

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_endeudamiento_egresos()
  OWNER TO postgres;
