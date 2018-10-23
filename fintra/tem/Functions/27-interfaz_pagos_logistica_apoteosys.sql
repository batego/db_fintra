-- Function: tem.interfaz_pagos_logistica_apoteosys()

-- DROP FUNCTION tem.interfaz_pagos_logistica_apoteosys();

CREATE OR REPLACE FUNCTION tem.interfaz_pagos_logistica_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
	r_ingreso record;
	r_asiento record;
	R_SALDO_R RECORD;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;
	VALOR_ACUM_ numeric:=0.00;
	CUENTA_BANCO TEXT:='';
	cuota_ text:='';
	saldoxcc numeric:=0.00;
	saldoingreso numeric:=0.00;
	--_CLASEDOC TEXT := 'IA'||SUBSTRING(_unidadNego,1,2);
	_PROCESOHOM TEXT := 'RECAUDO_LG';
	_NEGOCIO TEXT = '';

BEGIN

	FOR r_ingreso IN
--1). SE EJECUTA ESTE SELECT
--2). SE EJECUTA LA FUNCION COMPLETA

			SELECT substring(idet.periodo,1,4) as anio,
			      idet.periodo,
			      substring(ing.fecha_consignacion,1,4) as anio_consignacion,
			      replace(substring(ing.fecha_consignacion,1,7),'-','') as periodo_consignacion,
			      ing.branch_code,
			      ing.bank_account_no,
			      ing.num_ingreso,
			      ing.tipo_documento,
			      ing.creation_date,
			      idet.nitcli,
			      get_nombc(idet.nitcli) AS nombre_cliente,
			      ing.fecha_consignacion,
			      idet.cuenta,
			      idet.documento,
			      idet.tipo_doc,
			      sum(idet.valor_ingreso) as valor_ingreso,
			      idet.creation_user,
			      idet.procesado_ica,
			      fac.num_doc_fen as cuota,
			      idet.descripcion
			FROM con.ingreso ing
			INNER JOIN con.ingreso_detalle idet ON (ing.num_ingreso=idet.num_ingreso AND ing.tipo_documento=idet.tipo_documento)
			LEFT JOIN con.factura fac on (fac.documento=idet.documento AND     fac.tipo_documento=idet.tipo_doc AND fac.negasoc !='')
			WHERE
			branch_code in ('SUPEREFECTIVO','BANCOLOMBIA','BANCO OCCIDENTE'
					     ,'BCO COLPATRIA','CAJA TESORERIA','CAJA UNIATONOMA'
					     ,'FID COLP RECFEN','FENALCO ATLANTI','BANCOLMBIA MC','EFECTY','BCO CREDITO')
			AND bank_account_no in ('SUPEREFECTIVO','CA','CTE 802027144','BARRANQUILLA'
					    ,'UNIATONOMA','FIDCOLP REC FENALCO','CORFICOLOMBIANA'
				    ,'MICROCREDITO','EFECTY','CAJA', 'CC','CPAG','CROT')
			AND ing.reg_status=''
			AND idet.reg_status=''
			AND idet.num_ingreso in ('IC239570')
			--AND COALESCE(idet.procesado_ica,'N') = 'N'
			AND ing.fecha_consignacion::DATE > '2016-12-31'::DATE
			AND idet.periodo>='201701'  --PARA EL PERIODO
			AND idet.nitcli ='8901031611'
			AND idet.documento LIKE 'R0%'
			AND idet.documento in('R0033028',
'R0033029',
'R0033030',
'R0033031',
'R0033032')
			--and upper(idet.descripcion) like '%FATORI%'
			GROUP BY
			      idet.periodo,
			      ing.branch_code,
			      ing.bank_account_no,
			      ing.num_ingreso,
			      ing.tipo_documento,
			      ing.creation_date,
			      idet.nitcli,
			      ing.fecha_consignacion,
			      idet.cuenta,
			      idet.documento,
			      idet.tipo_doc,
			      idet.creation_user,
			      idet.procesado_ica,
			      fac.num_doc_fen,
			      idet.descripcion
			ORDER BY
			ing.num_ingreso,
			ing.fecha_consignacion,
			idet.periodo,
			branch_code,
			documento desc

/**
SELECT tem.interfaz_pagos_logistica_apoteosys()
SELECT * FROM con.mc_recaudo____ where MC_____CODIGO____CD_____B='ICLG' AND procesado='N' AND mc_____numero____period_b=9
UPDATE con.mc_recaudo____ SET PROCESADO='N' where MC_____CODIGO____CD_____B='ICLG' AND procesado='X' AND MC_____NUMERO____B NOT IN(69524,69525)
UPDATE con.mc_recaudo____ SET procesado='N' where MC_____CODIGO____CD_____B='ICLG' AND procesado='R' AND MC_____NUMERO____B IN('73586')
DELETE FROM con.mc_recaudo____ where MC_____CODIGO____CD_____B='ICLG' and procesado IN('N')
SELECT mc_____numero____period_b,COUNT(mc_____numero____period_b) FROM con.mc_recaudo____ where procesado='N' AND MC_____CODIGO____CD_____B='ICLG'
GROUP BY mc_____numero____period_b
*/
	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_BINGRESO_APOTEOSYS');
		CONSEC:=1;
		--
		--Calculamos el saldo de la R
		--
				RAISE NOTICE 'saldoingreso1:%', saldoingreso;
				RAISE NOTICE 'SALDOXCC1:%', SALDOXCC;
				--SI LA R TODAVIA QUEDA CON SALDO A ABONAR QUIERE DECIR QUE SOLO SE HARA POR UN CENTRO DE COSTO
				--IF(R_SALDO_R.SALDO>0 AND (R_SALDO_R.SALDO-saldoingreso)>0 AND SALDOXCC!=R_INGRESO.VALOR_INGRESO)THEN
					FOR r_asiento IN


						SELECT 1 as n,
							ing.num_ingreso,
						       ing.periodo,
						       --ingb.nitcli as nit_cliente,
						       CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE ing.nitcli END AS nit_cliente,
						       get_nombc(ing.nitcli) AS nombre_cliente,
						       ing.fecha_consignacion,
						       ing.fecha_ingreso,
						       ing.branch_code,
						       ing.bank_account_no,
						       ing.descripcion_ingreso,
						       --sum(idet.valor_ingreso) as valor_debito,
						       r_ingreso.VALOR_INGRESO AS VALOR_DEBITO,
							0.00 as valor_credito,
						       r_ingreso.NUM_INGRESO as documento_soporte,
						       --ing.descripcion_ingreso as documento_soporte,
						       --idet.cuenta,
						       COALESCE((SELECT codigo_cuenta FROM banco  WHERE branch_code =ing.branch_code AND bank_account_no=ing.bank_account_no),'00000000') as cuenta,
						       ing.descripcion_ingreso,
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
						FROM con.ingreso ing
						INNER JOIN con.ingreso_detalle idet on (ing.num_ingreso=idet.num_ingreso AND ing.tipo_documento=idet.tipo_documento AND ing.nitcli=idet.nitcli )
						left JOIN con.ingreso ingb on (ingb.num_ingreso=ing.descripcion_ingreso)
						LEFT JOIN con.factura fac on (fac.documento=idet.documento AND 	fac.tipo_documento=idet.tipo_doc AND fac.negasoc !='')
						LEFT JOIN PROVEEDOR C ON(C.NIT=ing.nitcli)
						LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
						LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
						LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=ing.nitcli)
						WHERE idet.reg_status = '' and ing.reg_status = '' and ing.num_ingreso=r_ingreso.NUM_INGRESO
						group by
						ing.num_ingreso,
						ing.periodo,
						HT.NIT_APOTEOSYS,
						ing.nitcli,
						ing.fecha_consignacion,
						ing.fecha_ingreso,
						ing.branch_code,
						ing.bank_account_no,
						ing.descripcion_ingreso,
						D.TIPO_IDEN,
						c.digito_verificacion,
						d.nombre1,
						D.NOMBRE2,
						D.APELLIDO1,
						D.APELLIDO2,
						D.NOMBRE,
						c.gran_contribuyente,
						C.AGENTE_RETENEDOR,
						D.DIRECCION,
						E.CODIGO_DANE2,
						D.TELEFONO
						UNION ALL
						SELECT 2 as n,ing.num_ingreso,
						       ing.periodo,
						       --ing.nitcli as nit_cliente,
						       CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE ing.nitcli END AS nit_cliente,
						       get_nombc(ing.nitcli) AS nombre_cliente,
						       ing.fecha_consignacion,
						       ing.fecha_ingreso,
						       ing.branch_code,
						       ing.bank_account_no,
						       ing.descripcion_ingreso,
						       0.00 as valor_credito,
						       r_ingreso.VALOR_INGRESO AS VALOR_CREDITO,
						       --idet.valor_ingreso as valor_credito,
						       idet.documento as documento_soporte,
						       idet.cuenta,
						       idet.descripcion,
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
						FROM con.ingreso ing
						INNER JOIN con.ingreso_detalle idet on (ing.num_ingreso=idet.num_ingreso AND ing.tipo_documento=idet.tipo_documento AND ing.nitcli=idet.nitcli )
						LEFT JOIN con.factura fac on (fac.documento=idet.documento AND 	fac.tipo_documento=idet.tipo_doc AND fac.negasoc !='')
						LEFT JOIN PROVEEDOR C ON(C.NIT=ing.nitcli)
						LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
						LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
						LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=ing.nitcli)
						WHERE idet.reg_status = '' and ing.reg_status = '' and idet.documento=r_ingreso.DOCUMENTO AND ing.num_ingreso=r_ingreso.NUM_INGRESO
					LOOP
						--SELECT INTO _NEGOCIO CON.INTERFAZ_NEGOCIOXDOCUMENTO(r_asiento.documento_soporte);

						FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r_asiento.FECHA_INGRESO::DATE,1,7),'-','')=R_ASIENTO.PERIODO THEN r_asiento.FECHA_INGRESO::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(R_ASIENTO.PERIODO,1,4),SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT)::DATE END ;

						if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', 'P-'|| R_ASIENTO.CUENTA,'', 6)='S')then
							--MCTYPE.MC_____FECHEMIS__B = R_INGRESO.CREATION_DATE::DATE;
							MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
							MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
						else
							MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
							MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

						end if;

						MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
						MCTYPE.MC_____CODIGO____TD_____B := 'INGN' ;
						MCTYPE.MC_____CODIGO____CD_____B := 'ICLG';
						MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
						MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
						MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
						MCTYPE.MC_____SECUINTE__B := CONSEC  ;
						MCTYPE.MC_____REFERENCI_B := r_ingreso.NUM_INGRESO;
						MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(R_ASIENTO.PERIODO,1,4)::INT;
						MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT;
						MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
						MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', 'P-'|| R_ASIENTO.CUENTA,'', 1)  ;
						MCTYPE.MC_____CODIGO____CU_____B := 'A1111F23201';
						MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(R_ASIENTO.nit_cliente)>10 THEN SUBSTR(R_ASIENTO.nit_cliente,1,10) ELSE R_ASIENTO.nit_cliente END;
						MCTYPE.MC_____DEBMONORI_B := 0  ;
						MCTYPE.MC_____CREMONORI_B := 0 ;
						MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
						MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
						MCTYPE.MC_____INDTIPMOV_B := 4  ;
						MCTYPE.MC_____INDMOVREV_B := 'N'  ;
						MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION_INGRESO ||'- Ingreso: '||r_ingreso.num_ingreso ;
						MCTYPE.MC_____FECHORCRE_B := r_asiento.FECHA_INGRESO::TIMESTAMP  ;
						MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
						MCTYPE.MC_____FEHOULMO__B := r_asiento.FECHA_INGRESO::TIMESTAMP  ;
						MCTYPE.MC_____AUTULTMOD_B := ''  ;
						MCTYPE.MC_____VALIMPCON_B := 0  ;
						MCTYPE.MC_____NUMERO_OPER_B := R_ASIENTO.num_ingreso;
						MCTYPE.TERCER_CODIGO____TIT____B := R_ASIENTO.TERCER_CODIGO____TIT____B  ;
						MCTYPE.TERCER_NOMBCORT__B := R_ASIENTO.TERCER_NOMBCORT__B  ;
						MCTYPE.TERCER_NOMBEXTE__B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_NOMBEXTE__B)>64 THEN SUBSTR(R_ASIENTO.TERCER_NOMBEXTE__B,1,64) ELSE R_ASIENTO.TERCER_NOMBEXTE__B END;
						MCTYPE.TERCER_APELLIDOS_B := R_ASIENTO.TERCER_APELLIDOS_B  ;
						MCTYPE.TERCER_CODIGO____TT_____B := R_ASIENTO.TERCER_CODIGO____TT_____B  ;
						MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_DIRECCION_B)>64 THEN SUBSTR(R_ASIENTO.TERCER_DIRECCION_B,1,64) ELSE R_ASIENTO.TERCER_DIRECCION_B END;
						MCTYPE.TERCER_CODIGO____CIUDAD_B := R_ASIENTO.TERCER_CODIGO____CIUDAD_B  ;
						MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_TELEFONO1_B)>15 THEN SUBSTR(R_ASIENTO.TERCER_TELEFONO1_B,1,15) ELSE R_ASIENTO.TERCER_TELEFONO1_B END;
						MCTYPE.TERCER_TIPOGIRO__B := 1 ;
						MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
						MCTYPE.TERCER_SUCURSAL__B := ''  ;
						MCTYPE.TERCER_NUMECUEN__B := ''  ;
						MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', 'P-'|| R_ASIENTO.CUENTA,'', 3);
						--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
						MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', 'P-'|| R_ASIENTO.CUENTA,'', 5)::INT;

						if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', 'P-'|| R_ASIENTO.CUENTA,'', 4)='S')then
							MCTYPE.MC_____NUMDOCSOP_B := R_ASIENTO.DOCUMENTO_SOPORTE;
						else
							MCTYPE.MC_____NUMDOCSOP_B := '';
						end if;

						if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', 'P-'|| R_ASIENTO.CUENTA,'', 5)::int=1)then
							MCTYPE.MC_____NUMEVENC__B := 1;
						else
							MCTYPE.MC_____NUMEVENC__B := null;
						end if;

						-- Insertamos en la tabla de Apoteosys
						--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
						SW:=CON.SP_INSERT_TABLE_MC_RECAUDO____(MCTYPE);
						CONSEC:=CONSEC+1;

					END LOOP;



		---------------------------------------------------------------------------

		--------------Revision de la transaccion-----------------
		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'RECAUDO') ='N' THEN
			SW='N';

			--BORRAMOS EL COMPROBANTE DE EXT
			DELETE FROM CON.mc_recaudo____
			WHERE MC_____NUMERO____B = SECUENCIA_GEN AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'INGN' AND  MC_____CODIGO____CD_____B = 'ICLG';

			CONTINUE;
		END IF;

		-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
		IF(SW='S')THEN

			UPDATE
				con.ingreso_detalle
			SET
				PROCESADO_ICA='S'
			WHERE
				TIPO_DOCUMENTO=r_ingreso.tipo_documento and
				num_ingreso=r_ingreso.num_ingreso and documento=r_ingreso.documento;

			SW:='N';
		END IF;

		---------------------------------------------------------------

	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.interfaz_pagos_logistica_apoteosys()
  OWNER TO postgres;
