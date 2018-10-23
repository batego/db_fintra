-- Function: con.interfaz_endoso_cdiario_apoteosys()

-- DROP FUNCTION con.interfaz_endoso_cdiario_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_endoso_cdiario_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
	r_cdiario record;
	r_asiento record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;

BEGIN

	FOR r_cdiario IN
		select
			c.TIPODOC,
			c.NUMDOC,
			c.PERIODO,
			c.FECHADOC,
			c.TOTAL_DEBITO,
			c.convenio,
			substring(c.convenio,1,1) as prefijo,
			c.agencia,
			case when c.estado='ENDOSO' then 'CDEN' else 'CDDE' end as tipo
		from
		(SELECT
			a.TIPODOC,
			a.NUMDOC,
			a.PERIODO,
			a.FECHADOC,
			a.TOTAL_DEBITO,
			b.referencia_1,
			sp_uneg_negocio_name(b.referencia_1) as convenio,
			c.agencia,
			case when cuenta ILIKE '162521%' and valor_debito>0 then 'ENDOSO' ELSE 'DESENDOSO' END AS estado
		FROM
			CON.COMPROBANTE a
		inner join con.comprodet b on (b.tipodoc=a.tipodoc and b.numdoc=a.numdoc and b.grupo_transaccion=a.grupo_transaccion)
		inner join negocios neg on(neg.cod_neg=b.referencia_1)
		inner join convenios c on(c.id_convenio=neg.id_convenio)
		WHERE
			a.reg_status='' and
			a.dstrct='FINV' and
			a.tipodoc='CDIAR' and
			a.periodo>='201701' and
			a.detalle ilike '%DIARIO DE ENDOSO%' and
			a.numdoc ilike 'CEN%' AND
			(REF_2='N' OR REF_2='') and
			a.creation_user='APOTEOSYS' and
			b.cuenta ILIKE '162521%'
			and a.numdoc IN('CEN00000404',
'CEN00000405',
'CEN00000408')
			) as c
		group by
			c.TIPODOC,
			c.NUMDOC,
			c.PERIODO,
			c.FECHADOC,
			c.TOTAL_DEBITO,
			c.convenio,
			c.agencia,
			c.estado
		ORDER BY
			NUMDOC


/**
SELECT con.interfaz_endoso_cdiario_apoteosys();
*/

/**
select MC_____CODIGO____CD_____B, MC_____CODIGO____PF_____B,MC_____NUMERO____PERIOD_B, COUNT(*) from con.mc_cd_endoso____  where procesado in('N') and MC_____CODIGO____TD_____B='DIAR'
GROUP BY MC_____CODIGO____CD_____B, MC_____CODIGO____PF_____B,MC_____NUMERO____PERIOD_B
order by MC_____CODIGO____PF_____B,MC_____NUMERO____PERIOD_B;
select * from con.mc_cd_endoso____  where procesado in('R') and MC_____CODIGO____TD_____B='DIAR'  and MC_____CODIGO____PF_____B=2017 and MC_____NUMERO____PERIOD_B=2;
select * from con.mc_cd_endoso____  where MC_____CODIGO____TD_____B='DIAR'  and MC_____CODIGO____PF_____B=2017 and MC_____NUMERO____PERIOD_B=2 AND MC_____REFERENCI_B='CEN00000118';
select DISTINCT MC_____REFERENCI_B from con.mc_cd_endoso____  where MC_____CODIGO____TD_____B='DIAR'  and MC_____CODIGO____PF_____B=2017 and MC_____NUMERO____PERIOD_B=2 AND PROCESADO='N';
DELETE from con.mc_cd_endoso____  where procesado='N' and MC_____CODIGO____TD_____B='DIAR' and MC_____REFERENCI_B in('CEN00000173','CEN00000174');
update con.mc_cd_endoso____  set procesado='N' where procesado='S' and MC_____CODIGO____TD_____B='DIAR' AND MC_____REFERENCI_B='CEN00000132';
*/

	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_EGRESO_APOTEOSYS');

		RAISE NOTICE 'COMPROBANTE:%',R_CDIARIO.NUMDOC;

		For r_asiento in

			SELECT
				com.numdoc,
				comp.cuenta,
				substr(com.tipodoc,1,3) as tipo_documento,
				com.creation_date,
				com.periodo,
				com.detalle as descripcion,
				--com.tercero,
				round(comp.valor_debito,0) as valor_debito,
				round(comp.valor_credito,0) as valor_credito,
				--comp.tercero,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE comp.auxiliar END AS tercero,
				comp.detalle,
				case when comp.detalle ilike '%CUOTA ADM%' THEN 'CM'
				WHEN comp.detalle ilike '%ANTICIPADO%FENALCO%' THEN 'IF'
				ELSE 'N' END AS TIPO_INT,
				comp.transaccion,
				comp.documento_rel,
				comp.referencia_1,
				case
				when substring(comp.documento_rel,1,1)='F' AND substring(comp.documento_rel,8,2)!='00' AND comp.cuenta in(27050591,27050901,27059702,27059601,27059602,27050596,27050597,16252135,16252136) then b.documento
				else comp.documento_rel end as documento,
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
				 WHEN D.TIPO_IDEN='CED' THEN 'RSCP'
				 WHEN D.TIPO_IDEN='NIT' THEN 'RCOM'
				 ELSE 'PNAL' END) AS TERCER_CODIGO____TT_____B,
				 D.DIRECCION AS TERCER_DIRECCION_B,
				 (CASE
				 WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				 ELSE '08001' END) AS TERCER_CODIGO____CIUDAD_B,
				 D.TELEFONO AS TERCER_TELEFONO1_B
			FROM
				con.comprobante com
			INNER JOIN con.comprodet comp on(comp.tipodoc=com.tipodoc and comp.numdoc=com.numdoc)
			left JOIN (SELECT reg_status, CODNEG,
					       SUBSTRING(COD,1,2) AS PREFIJO,
					       COD AS DOCUMENTO,
					       LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00') AS CUOTA,
					       FECHA_DOC::DATE AS FECHA_VEN,
					       VALOR,
					       TIPODOC
					FROM ING_FENALCO --WHERE reg_status=''
				) B on (comp.referencia_1=B.CODNEG AND B.TIPODOC=(
										case when comp.detalle ilike '%CUOTA ADM%' THEN 'CM'
										WHEN comp.detalle ilike '%ANTICIPADO%FENALCO%' THEN 'IF'
										WHEN comp.detalle ilike '%NATICIPADO%FEN%' THEN 'IF'
										ELSE 'N' END)
					AND SUBSTRING(comp.documento_rel,8,2) =B.CUOTA)
			LEFT JOIN PROVEEDOR C ON(C.NIT=comp.auxiliar)
			LEFT JOIN NIT D ON(D.CEDULA=comp.auxiliar)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=comp.auxiliar)
			WHERE
				COM.TIPODOC='CDIAR' AND
				COM.NUMDOC=r_cdiario.numdoc AND --TRANSACCION=32244368 AND
				(COMP.VALOR_DEBITO!=0 OR COMP.VALOR_CREDITO!=0)
				--AND REFERENCIA_1='FA30549'
			order by
				documento_rel, transaccion

		LOOP

			RAISE NOTICE 'CUENTA:%',R_CDIARIO.PREFIJO||'-'||R_ASIENTO.CUENTA;
			RAISE NOTICE 'DEBITO:%',R_ASIENTO.VALOR_DEBITO;
			RAISE NOTICE 'CREDITO:%',R_ASIENTO.VALOR_CREDITO;
			RAISE NOTICE 'TRANSACCION:%',R_ASIENTO.TRANSACCION;

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r_cdiario.FECHADOC::DATE,1,7),'-','')=r_cdiario.PERIODO THEN r_cdiario.FECHADOC::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(r_cdiario.PERIODO,1,4),SUBSTRING(r_cdiario.PERIODO,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CDIARIO_R', R_ASIENTO.TIPO_DOCUMENTO, r_cdiario.prefijo||'-'||R_ASIENTO.CUENTA, r_cdiario.agencia, 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'DIAR' ;
			MCTYPE.MC_____CODIGO____CD_____B := r_cdiario.tipo;
			MCTYPE.MC_____SECUINTE__DCD____B := 0  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := R_CDIARIO.NUMDOC;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(R_ASIENTO.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CDIARIO_R', R_ASIENTO.TIPO_DOCUMENTO, r_cdiario.prefijo||'-'||R_ASIENTO.CUENTA,r_cdiario.agencia, 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CDIARIO_R', R_ASIENTO.TIPO_DOCUMENTO, r_cdiario.prefijo||'-'||R_ASIENTO.CUENTA,r_cdiario.agencia, 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(r_asiento.tercero)>10 THEN SUBSTR(r_asiento.tercero,1,10) ELSE r_asiento.tercero END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION||'-'||R_ASIENTO.REFERENCIA_1;
			MCTYPE.MC_____FECHORCRE_B := R_ASIENTO.CREATION_DATE::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := R_ASIENTO.CREATION_DATE::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := r_cdiario.numdoc;
			MCTYPE.TERCER_CODIGO____TIT____B := R_ASIENTO.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := R_ASIENTO.TERCER_NOMBCORT__B  ;
			MCTYPE.TERCER_NOMBEXTE__B := R_ASIENTO.TERCER_NOMBEXTE__B  ;
			MCTYPE.TERCER_APELLIDOS_B := R_ASIENTO.TERCER_APELLIDOS_B  ;
			MCTYPE.TERCER_CODIGO____TT_____B := R_ASIENTO.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_DIRECCION_B)>64 THEN SUBSTR(R_ASIENTO.TERCER_DIRECCION_B,1,64) ELSE R_ASIENTO.TERCER_DIRECCION_B END  ;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := R_ASIENTO.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_TELEFONO1_B)>15 THEN SUBSTR(R_ASIENTO.TERCER_TELEFONO1_B,1,15) ELSE R_ASIENTO.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____BASE______B := CASE WHEN R_ASIENTO.cuenta in('23680107','23653507') THEN r_cdiario.total_debito ELSE 0 END;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CDIARIO_R', R_ASIENTO.TIPO_DOCUMENTO, r_cdiario.prefijo||'-'||R_ASIENTO.CUENTA,r_cdiario.agencia, 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CDIARIO_R', R_ASIENTO.TIPO_DOCUMENTO, r_cdiario.prefijo||'-'||R_ASIENTO.CUENTA,r_cdiario.agencia, 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CDIARIO_R', R_ASIENTO.TIPO_DOCUMENTO, r_cdiario.prefijo||'-'||R_ASIENTO.CUENTA,r_cdiario.agencia, 4)='S')then
				MCTYPE.MC_____NUMDOCSOP_B := R_ASIENTO.documento;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CDIARIO_R', R_ASIENTO.TIPO_DOCUMENTO, r_cdiario.prefijo||'-'||R_ASIENTO.CUENTA,r_cdiario.agencia, 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC_CD_ENDOSO____(MCTYPE);
			CONSEC:=CONSEC+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'CD_ENDOSO') ='N' THEN
			SW='N';

			--BORRAMOS EL COMPROBANTE DE EXT
			DELETE FROM CON.MC_CD_ENDOSO____
			WHERE MC_____NUMERO____B = SECUENCIA_GEN AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'DIAR' AND  MC_____CODIGO____CD_____B = 'CDEN'  ;

			CONTINUE;
		END IF;

		-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
		IF(SW='S')THEN

			UPDATE
				con.comprobante
			set
				ref_2='S'
			where
				tipodoc=r_cdiario.tipodoc and
				numdoc=r_cdiario.numdoc;

			SW:='N';
		END IF;

		CONSEC:=1;


	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_endoso_cdiario_apoteosys()
  OWNER TO postgres;
