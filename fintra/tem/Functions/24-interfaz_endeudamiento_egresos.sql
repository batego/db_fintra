-- Function: tem.interfaz_endeudamiento_egresos()

-- DROP FUNCTION tem.interfaz_endeudamiento_egresos();

CREATE OR REPLACE FUNCTION tem.interfaz_endeudamiento_egresos()
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
				SELECT  cbd.dstrct,
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
					AND cbd.procesado_apo = 'S'
					AND cbd.doc_pago != ''
					AND cbd.creation_date BETWEEN '2017-01-01' AND CURRENT_DATE
					AND (substring(cbd.fecha_final,1,4)||substring(cbd.fecha_final,6,2))=201710
					AND cbd.documento in('206080027195')--,'206080027193')
					--AND CBD.DOC_INTERESES='80200098143-ND33'
					--AND CBD.DOCUMENTO='80200098143'
				--GROUP BY cbd.documento
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
		RAISE NOTICE 'r_detalle_credito %', r_detalle_credito;
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

				RAISE NOTICE 'documento : %  debito : % credito: %', r_detalle_credito.documento ,r_asiento.valor_debito,r_asiento.valor_credito;

			END LOOP;

	END LOOP;

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.interfaz_endeudamiento_egresos()
  OWNER TO postgres;
