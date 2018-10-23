-- Function: con.interfaz_inversionistas_egreso_apoteosys()

-- DROP FUNCTION con.interfaz_inversionistas_egreso_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_inversionistas_egreso_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
	r_egreso record;
	r_asiento record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;

BEGIN

	FOR r_egreso IN

		SELECT i.nombre_subcuenta,
		       i.nit,
		       m.no_transaccion as documento_cxp,
		       m.estado,
		       m.banco,
		       m.fecha,
		       m.concepto_transaccion,
		       cxp.cheque as egreso,
		       cxp.periodo,
		       cxp.creation_date
		FROM movimientos_captaciones m
		INNER JOIN inversionista i on(i.nit=m.nit and i.subcuenta=m.subcuenta)
		inner join fin.cxp_doc cxp on(cxp.tipo_documento='FAP' and cxp.documento=m.no_transaccion)
		WHERE m.reg_status != 'A'
		      --AND m.no_transaccion='T07046'
		      --and cxp.cheque='EG47236'
		      and cxp.periodo = REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
		      AND m.tipo_movimiento='RP'
		      AND m.estado='T'
		      AND m.procesado='N'
		ORDER BY m.subcuenta, m.fecha, m.no_transaccion

/**
SELECT con.interfaz_inversionistas_egreso_apoteosys();
*/

	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_EGRESO_APOTEOSYS');

		For r_asiento in

			select
				cxp.documento,
				cxpd.codigo_cuenta as cuenta,
				cxp.tipo_documento,
				cxp.creation_date,
				cxp.periodo,
				cxp.descripcion,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE cxp.proveedor END AS proveedor,
				--cxp.proveedor,
				0 as valor_credito,
				cxpd.vlr as valor_debito,
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
			from
				fin.cxp_doc cxp
			inner join fin.cxp_items_doc cxpd on(cxpd.dstrct=cxp.dstrct and cxpd.proveedor=cxp.proveedor and cxpd.tipo_documento=cxp.tipo_documento and cxpd.documento=cxp.documento)
			LEFT JOIN PROVEEDOR C ON(C.NIT=cxp.proveedor)
			LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=cxp.proveedor)
			where
				cxp.tipo_documento='FAP' and
				cxp.documento=r_egreso.documento_cxp
			union all
			SELECT
				eg.document_no as documento,
				con.cuenta,
				con.tipodoc as tipo_documento,
				eg.creation_date,
				eg.periodo,
				egd.description as descripcion,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE eg.nit END AS nit,
				--eg.nit,
				eg.vlr as valor_credito,
				0 as valor_debito,
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
				egreso eg
			inner join egresodet egd on(egd.dstrct=eg.dstrct and egd.branch_code=eg.branch_code and egd.bank_account_no=eg.bank_account_no and egd.document_no=eg.document_no)
			inner join con.comprodet con on(con.dstrct=eg.dstrct and con.tipodoc='EGR' and con.numdoc=eg.document_no and con.documento_rel=eg.document_no and con.grupo_transaccion=eg.transaccion)
			LEFT JOIN PROVEEDOR C ON(C.NIT=eg.nit)
			LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=eg.nit)
			where
				eg.document_no=r_egreso.egreso and
				eg.periodo=r_egreso.periodo

		LOOP

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r_egreso.CREATION_DATE::DATE,1,7),'-','')=R_egreso.PERIODO THEN R_egreso.CREATION_DATE::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(R_egreso.PERIODO,1,4),SUBSTRING(R_egreso.PERIODO,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'EGRN' ;
			MCTYPE.MC_____CODIGO____CD_____B := 'EGIV'  ;
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := r_egreso.egreso;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(R_ASIENTO.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('INVERSIONISTAS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(R_ASIENTO.proveedor)>10 THEN SUBSTR(R_ASIENTO.proveedor,1,10) ELSE R_ASIENTO.proveedor END;
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
			MCTYPE.MC_____NUMERO_OPER_B := r_egreso.egreso;
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
				--MCTYPE.MC_____NUMDOCSOP_B := r_egreso.egreso;
				MCTYPE.MC_____NUMDOCSOP_B := R_ASIENTO.proveedor;
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
			DELETE FROM CON.MC_INVERSIONISTAS____
			WHERE MC_____NUMERO____B = SECUENCIA_GEN AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'EGRN' AND  MC_____CODIGO____CD_____B = 'EGIV'  ;

			CONTINUE;
		END IF;

		-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
		IF(SW='S')THEN

			UPDATE
				movimientos_captaciones
			set
				procesado='S'
			where
				no_transaccion=r_egreso.documento_cxp;

			SW:='N';
		END IF;

		CONSEC:=1;

	END LOOP;


RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_inversionistas_egreso_apoteosys()
  OWNER TO postgres;
