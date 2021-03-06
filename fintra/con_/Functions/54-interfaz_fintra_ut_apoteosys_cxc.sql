-- Function: con.interfaz_fintra_ut_apoteosys_cxc()

-- DROP FUNCTION con.interfaz_fintra_ut_apoteosys_cxc();

CREATE OR REPLACE FUNCTION con.interfaz_fintra_ut_apoteosys_cxc()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION ARMA LA CORRIDA DE UT
  *Y CONTRUYE EL ASIENTO CONTABLE QUE MAS ADELANTE
  *SE TRASLADARA A APOTEOSYS.
  *DOCUMENTACION:=
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2018-01-22
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

REC_OS RECORD;
REC_CXC RECORD;
SECUENCIA_CXC INTEGER;
CONSEC INTEGER:=1;
FECHADOC_ TEXT:='';
 SW TEXT:='N';
_ARRCUENTASCXC VARCHAR[] :='{}';
MCTYPE CON.TYPE_INSERT_MC;


 BEGIN

	--SE CONSULTA EL VECTOR DE CUENTAS Y SE ASIGNA
	_ARRCUENTASCXC:=ETES.GET_CUENTAS_PERFIL('CORRIDA_TRANSFERENCIA');

	--SE CONSULTAN LAS R QUE SE VAN A TRANSPORTAR HACIA APOTEOSYS

	FOR REC_OS IN

		--QUERY PRINCIPAL DONDE SALEN LAS R DE CORRIDAS
		SELECT
			TIPO_DOCUMENTO AS TIPODOC,
			A.FACTURA_CXC,
			B.FECHA_FACTURA,
			REPLACE(SUBSTRING(B.FECHA_FACTURA,1,7),'-','') AS PERIODO,
			B.DESCRIPCION,
			B.CREATION_DATE,
			B.CREATION_USER,
			B.LAST_UPDATE,
			B.USER_UPDATE
		FROM
			CON.PLANILLAS_PROCESADAS_UT A
		INNER JOIN
			CON.FACTURA B ON(B.DOCUMENTO=A.FACTURA_CXC)
		WHERE
			PROCESADO_NACIMIENTO='S' AND
			PROCESADO_EGRESO='S' AND
			PROCESADO_CXC='N' AND
			REPLACE(SUBSTRING(B.FECHA_FACTURA,1,7),'-','')=REPLACE(SUBSTRING(now(),1,7),'-','')
			--AND A.FACTURA_CXC='R0034364'
		GROUP BY
			TIPO_DOCUMENTO,
			A.FACTURA_CXC,
			B.FECHA_FACTURA,
			B.DESCRIPCION,
			B.CREATION_DATE,
			B.CREATION_USER,
			B.LAST_UPDATE,
			B.USER_UPDATE
/**
SELECT con.interfaz_fintra_ut_apoteosys_cxc();
select * from con.factura_detalle where documento='R0034332'

SELECT *
FROM con.mc____  where  MC_____CODIGO____TD_____B = 'CXCN' AND MC_____CODIGO____CD_____B = 'CRLG'  AND procesado='N';

SELECT MC_____NUMERO____PERIOD_B,COUNT(MC_____NUMERO____PERIOD_B)
FROM con.mc____  where  MC_____CODIGO____TD_____B = 'CXCN' AND MC_____CODIGO____CD_____B = 'CRLG'  AND procesado='N' group by MC_____NUMERO____PERIOD_B;

select * from etes.manifiesto_carga where cxc_corrida='R0034332'

delete from con.mc____ where MC_____CODIGO____TD_____B = 'OPER' and MC_____CODIGO____CD_____B = 'AGA'  AND PROCESADO='N';

*/
	LOOP

		raise notice 'CORRIDA R: %',REC_OS.FACTURA_CXC;

		SECUENCIA_CXC:=0;
		CONSEC :=1;

		--SECUENCIA DE LA TRANSACCION
		SELECT INTO SECUENCIA_CXC NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');

		FOR REC_CXC IN

			--QUERY DONDE SE DETALLA LA CORRIDA
			select
				_ARRCUENTASCXC[1] as cuenta,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE a.nit END AS NIT,
				a.valor_factura as valor_debito,
				0 as valor_credito,
				a.documento as doc_soporte,
				a.DESCRIPCION AS detalle,
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
			from
				con.factura a
			LEFT JOIN
				PROVEEDOR C ON(C.NIT=A.nit)
			LEFT JOIN
				NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN
				CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN
				CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=A.nit)
			where
				a.reg_status='' and
				a.tipo_documento='FAC' and
				a.documento=REC_OS.FACTURA_CXC
			union all
			select
				_ARRCUENTASCXC[2] as cuenta,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE com.tercero END AS NIT,
				0 as valor_debito,
				a.valor_planilla as valor_credito,
				a.planilla as doc_soporte,
				'CORRIDA PLANILLA:'||a.planilla as detalle,
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
			from
				etes.manifiesto_carga a
 			INNER JOIN
 				CON.PLANILLAS_PROCESADAS_UT B ON(B.PLANILLA=A.PLANILLA)
 			INNER JOIN
				CON.COMPRODET COM ON(COM.TIPODOC='FAC' AND COM.DOCUMENTO_REL=A.PLANILLA AND COM.CUENTA='13802802')
			LEFT JOIN
				PROVEEDOR C ON(C.NIT=com.tercero)
			LEFT JOIN
				NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN
				CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN
				CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=com.tercero)
			where
				a.reg_status='' and
				a.cxc_corrida=REC_OS.FACTURA_CXC
			union all
			select
				_ARRCUENTASCXC[2] as cuenta,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE com.tercero END AS NIT,
				0 as valor_debito,
				a.valor_reanticipo as valor_credito,
				a.planilla as doc_soporte,
				'CORRIDA PLANILLA:'||a.planilla as detalle,
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
			from
				etes.manifiesto_reanticipos a
 			INNER JOIN
 				CON.PLANILLAS_PROCESADAS_UT B ON(B.PLANILLA=A.PLANILLA)
 			INNER JOIN
				CON.COMPRODET COM ON(COM.TIPODOC='FAC' AND COM.DOCUMENTO_REL=A.PLANILLA AND COM.CUENTA='13802802')
			LEFT JOIN
				PROVEEDOR C ON(C.NIT=com.tercero)
			LEFT JOIN
				NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN
				CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN
				CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=com.tercero)
			where
				a.reg_status='' and
				a.cxc_corrida=REC_OS.FACTURA_CXC

		LOOP

			raise notice 'CUENTA: %',REC_CXC.cuenta;
			raise notice 'DOC SOPORTE: %',REC_CXC.doc_soporte;

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(REC_OS.CREATION_DATE,1,7),'-','')=REC_OS.PERIODO THEN REC_OS.CREATION_DATE::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(REC_OS.PERIODO,1,4),SUBSTRING(REC_OS.PERIODO,5,2)::INT)::DATE END ;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('TRANSFERENCIA', REC_OS.TIPODOC, REC_CXC.CUENTA,'', 6)='S')THEN
				MCTYPE.MC_____FECHEMIS__B=FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B=FECHADOC_::DATE;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			END IF;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'CXCN' ;
			MCTYPE.MC_____CODIGO____CD_____B := 'CRLG'  ;
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_CXC  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := REC_OS.FACTURA_CXC;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(REC_OS.PERIODO,1,4)::INT  ;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(REC_OS.PERIODO,5,2)::INT  ;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('TRANSFERENCIA', REC_OS.TIPODOC, REC_CXC.CUENTA,'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('TRANSFERENCIA', REC_OS.TIPODOC, REC_CXC.CUENTA,'', 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B := CASE WHEN CHAR_LENGTH(REC_CXC.NIT)>10 THEN SUBSTR(REC_CXC.NIT,1,10) ELSE REC_CXC.NIT END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := REC_CXC.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := REC_CXC.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := REC_CXC.DETALLE ||'-UT';
			MCTYPE.MC_____FECHORCRE_B := REC_OS.CREATION_DATE::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := REC_OS.LAST_UPDATE::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := REC_OS.FACTURA_CXC;
			MCTYPE.TERCER_CODIGO____TIT____B := REC_CXC.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := CASE WHEN CHAR_LENGTH(REC_CXC.TERCER_NOMBCORT__B)>32 THEN SUBSTR(REC_CXC.TERCER_NOMBCORT__B,1,32) ELSE REC_CXC.TERCER_NOMBCORT__B END;
			MCTYPE.TERCER_NOMBEXTE__B := REC_CXC.TERCER_NOMBEXTE__B  ;
			MCTYPE.TERCER_APELLIDOS_B := CASE WHEN CHAR_LENGTH(REC_CXC.TERCER_APELLIDOS_B)>32 THEN SUBSTR(REC_CXC.TERCER_APELLIDOS_B,1,32) ELSE REC_CXC.TERCER_APELLIDOS_B END;
			MCTYPE.TERCER_CODIGO____TT_____B := REC_CXC.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := REC_CXC.TERCER_DIRECCION_B  ;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := REC_CXC.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(REC_CXC.TERCER_TELEFONO1_B)>15 THEN SUBSTR(REC_CXC.TERCER_TELEFONO1_B,1,15) ELSE REC_CXC.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('TRANSFERENCIA', REC_OS.TIPODOC, REC_CXC.CUENTA,'', 3);

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('TRANSFERENCIA', REC_OS.TIPODOC, REC_CXC.CUENTA,'', 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := REC_CXC.doc_soporte;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('TRANSFERENCIA', REC_OS.TIPODOC, REC_CXC.CUENTA,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC( MCTYPE);
			CONSEC:=CONSEC+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'LOGISTICA') ='N' THEN
			SW='N';
			CONTINUE;
		END IF;

		--ACTUALIZAMOS EL REGISTRO EN OS PARA SABER QUE SE PROCESO
		IF(SW='S')THEN
			UPDATE
				con.planillas_procesadas_ut
			SET
				PROCESADO_CXC='S'
			WHERE
				FACTURA_CXC=REC_OS.FACTURA_CXC;

			SW:='N';
		END IF;


	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_fintra_ut_apoteosys_cxc()
  OWNER TO postgres;
