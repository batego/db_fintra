-- Function: con.interfaz_inversionistas_ingreso_apoteosys()

-- DROP FUNCTION con.interfaz_inversionistas_ingreso_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_inversionistas_ingreso_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
	Ingresos record;
	r_asiento record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;

BEGIN
	-- 1. Buscamos los créditos con saldo 0 que no se hayan enviado a Apoteosys
	FOR Ingresos IN

		SELECT
			ing.num_ingreso,
			ing.tipo_documento,
			ing.descripcion_ingreso,
			ing.fecha_ingreso
		FROM con.ingreso  ing
		INNER JOIN con.ingreso_detalle  ingdet on (ingdet.num_ingreso=ing.num_ingreso AND ingdet.tipo_documento=ing.tipo_documento)
		WHERE
			ing.reg_status='' AND
			ing.descripcion_ingreso ILIKE 'Ingreso de inversi&oacute;n%'  AND
			ing.periodo = REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
			AND (ingdet.procesado_ica IS NULL OR ingdet.procesado_ica='N')
			--and  ing.num_ingreso='IC243505'
		ORDER BY ing.periodo

	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_BINGRESO_APOTEOSYS');

		For r_asiento in

			SELECT ing.num_ingreso,
			       ing.cuenta as cuenta,
			       ing.tipo_documento,
			       ing.creation_date,
			       ing.periodo,
			       ing.concepto,
			       ing.fecha_consignacion,
			       ing.fecha_ingreso,
			       ing.branch_code,
			       ing.bank_account_no,
			       ing.descripcion_ingreso as descripcion,
			       CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE ing.nitcli END AS nitcli,
--			       ing.nitcli,
			       ing.vlr_ingreso as valor_debito,
			       0 as valor_credito,
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
			FROM con.ingreso  ing
			inner join con.ingreso_detalle  ingdet on (ingdet.num_ingreso=ing.num_ingreso AND ingdet.tipo_documento=ing.tipo_documento)
			LEFT JOIN PROVEEDOR C ON(C.NIT=ing.nitcli)
			LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=ing.nitcli)
			where
				descripcion_ingreso ilike 'Ingreso de inversi&oacute;n%' and
				ing.num_ingreso=Ingresos.num_ingreso --debito
			Union all
			SELECT ing.num_ingreso,
			       ingdet.cuenta as cuenta,
			       ing.tipo_documento,
			       ing.creation_date,
			       ing.periodo,
			       ing.concepto,
			       ing.fecha_consignacion,
			       ing.fecha_ingreso,
			       ing.branch_code,
			       ing.bank_account_no,
			       ing.descripcion_ingreso,
			       CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE ing.nitcli END AS nitcli,
			       --ing.nitcli,
			       0 as valor_debito,
			       ing.vlr_ingreso as valor_credito,
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
			FROM con.ingreso  ing
			inner join con.ingreso_detalle  ingdet on (ingdet.num_ingreso=ing.num_ingreso AND ingdet.tipo_documento=ing.tipo_documento)
			LEFT JOIN PROVEEDOR C ON(C.NIT=ing.nitcli)
			LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=ing.nitcli)
			where
				descripcion_ingreso ilike 'Ingreso de inversi&oacute;n%' and
				ing.num_ingreso=Ingresos.num_ingreso

		LOOP

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(R_ASIENTO.CREATION_DATE::DATE,1,7),'-','')=R_ASIENTO.PERIODO THEN R_ASIENTO.CREATION_DATE::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(R_ASIENTO.PERIODO,1,4),SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'INGN' ;
			MCTYPE.MC_____CODIGO____CD_____B := 'IGIV'  ;
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := Ingresos.num_ingreso;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(R_ASIENTO.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(R_ASIENTO.nitcli)>10 THEN SUBSTR(R_ASIENTO.nitcli,1,10) ELSE R_ASIENTO.nitcli END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION  ;
			MCTYPE.MC_____FECHORCRE_B := R_ASIENTO.CREATION_DATE::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := R_ASIENTO.CREATION_DATE::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := Ingresos.num_ingreso;
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 4)='S')then
				MCTYPE.MC_____NUMDOCSOP_B := INGRESOS.NUM_INGRESO;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC_INVERSIONISTAS____(MCTYPE);
			CONSEC:=CONSEC+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'INVERSIONISTAS') ='N' THEN
			SW='N';

			--BORRAMOS EL COMPROBANTE DE EXT
			DELETE FROM CON.MC____
			WHERE MC_____NUMERO____B = SECUENCIA_GEN AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'INGN' AND  MC_____CODIGO____CD_____B = 'IGIV'  ;

			CONTINUE;
		END IF;

		-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
		IF(SW='S')THEN

			UPDATE
				con.ingreso_detalle
			SET
				PROCESADO_ICA='S'
			WHERE
				TIPO_DOCUMENTO=Ingresos.tipo_documento and
				num_ingreso=Ingresos.num_ingreso;

			SW:='N';
		END IF;

		CONSEC:=1;

	END LOOP;


RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_inversionistas_ingreso_apoteosys()
  OWNER TO postgres;
