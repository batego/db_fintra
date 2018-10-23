-- Function: con.interfaz_egresos_lb_apoteosys()

-- DROP FUNCTION con.interfaz_egresos_lb_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_egresos_lb_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: CREA LOS ASIENTOS DE LOS EGRESOS
  *DE LOS FA, FB, LI
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2018-04-04
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  *
  ************************************************/

NEGOCIO_ RECORD;
INFOCLIENTE RECORD;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
CUENTA_ASIENTO VARCHAR;
ITEMS_ASIENTOS_ integer[] := '{2}';--> indica la cantidad de items que tiene el asiento
ITERACIONES integer;
I integer;
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
cuenta_ text;
FECHADOC_ VARCHAR:= '';
BEGIN

	/**LISTADO DE FACTURAS A PASAR*/
	FOR NEGOCIO_ IN
		SELECT
			neg.cod_neg,
			CXP.TIPO_DOCUMENTO,
			CXP.DOCUMENTO,
			CXP.CHEQUE,
			COALESCE((SELECT CODIGO_CUENTA FROM BANCO  WHERE BRANCH_CODE =(CASE WHEN EG.BRANCH_CODE='BANCOLOMBIAPAB' THEN 'BANCOLOMBIA' ELSE EG.BRANCH_CODE END) AND BANK_ACCOUNT_NO=EG.BANK_ACCOUNT_NO),'00000000') AS CUENTA_BANCO,
			hc.CUENTA,
			CXP.HANDLE_CODE,
			EG.VLR,
			EG.BRANCH_CODE,
			EG.BANK_ACCOUNT_NO,
			substring(sp_uneg_negocio_name(neg.cod_neg),1,1) AS PREFIJO,
			CONV.AGENCIA,
			neg.f_desem::date as FECHA_EMISION,
			neg.f_desem::date as FECHA_VENCIMIENTO,
			replace(substring(neg.f_desem,1,7),'-','') as periodo,
			--EG.FECHA_CHEQUE AS FECHA_EMISION,
			--EG.FECHA_CHEQUE	AS FECHA_VENCIMIENTO,
			--eg.periodo,
			eg.nit as tercero,
			CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE eg.nit END AS tercero2,
			cxp.descripcion
		FROM
			NEGOCIOS NEG
		INNER JOIN
			CONVENIOS CONV ON(CONV.ID_CONVENIO=NEG.ID_CONVENIO)
		INNER JOIN
			FIN.CXP_DOC CXP ON(CXP.tipo_documento_rel='NEG' and CXP.DOCUMENTO_RELACIONADO=NEG.COD_NEG)
		INNER JOIN
			CON.CMC_DOC  hc ON (hc.CMC=CXP.HANDLE_CODE AND hc.TIPODOC=CXP.TIPO_DOCUMENTO)
		INNER JOIN
			EGRESO EG ON(EG.DSTRCT='FINV' AND EG.BRANCH_CODE=CXP.BANCO AND EG.BANK_ACCOUNT_NO=CXP.SUCURSAL AND EG.DOCUMENT_NO=CXP.CHEQUE)
		INNER JOIN
			EGRESODET EGDET ON(EGDET.DSTRCT=EG.DSTRCT AND EGDET.BRANCH_CODE=EG.BRANCH_CODE AND EGDET.BANK_ACCOUNT_NO=EG.BANK_ACCOUNT_NO AND EGDET.DOCUMENT_NO=EG.DOCUMENT_NO)
		LEFT JOIN
			CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=eg.nit)
		WHERE
			neg.estado_neg in ('T','A') and
			SUBSTRING(neg.cod_neg,1,2) IN('LB') AND
			(neg.procesado_mc='S' OR neg.procesado_lib='S')
			and neg.cod_neg not in (select negocio_reestructuracion from rel_negocios_reestructuracion) and
			--replace(substring(neg.f_desem,1,7),'-','')>='201701'--REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
			eg.periodo>='201701'
			and COALESCE(egdet.PROCESADO,'N')='N'
			and CXP.cheque != ''
			--AND neg.cod_neg='FB04242'
			--AND CXP.DOCUMENTO='LP0000546'
			--and cxp.cheque='EG47213'
		 GROUP BY neg.cod_neg,CXP.BANCO,CXP.SUCURSAL,CXP.TIPO_DOCUMENTO,CXP.DOCUMENTO, CXP.CHEQUE, EG.BRANCH_CODE, EG.BANK_ACCOUNT_NO, hc.CUENTA, EG.VLR,CXP.HANDLE_CODE,
 			EG.BRANCH_CODE, EG.BANK_ACCOUNT_NO, CONV.AGENCIA,neg.f_desem,/* EG.FECHA_CHEQUE,eg.periodo,*/ eg.nit,ht.nit_apoteosys, cxp.descripcion
		ORDER BY CXP.DOCUMENTO

	LOOP

		select INTO INFOCLIENTE
			(CASE
			WHEN tipo_iden ='CED' THEN 'CC'
			WHEN tipo_iden ='RIF' THEN 'CE'
			WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
			'CC' END) as tipo_doc,
			(CASE
			WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
			WHEN tipo_iden in  ('CED')  THEN 'RSCP'
			else
			'RSCP'
			END) as codigo,
			(CASE
			WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
			ELSE '08001' END) as codigociu,
			(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
			(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
			*
		from  NIT D --ON(D.CEDULA=prov.NIT)
		LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
		where cedula = NEGOCIO_.tercero;

		--OBTENEMOS LA SECUENCIA
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_EGRESO_APOTEOSYS');

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'EGRN';
		MCTYPE.MC_____CODIGO____CD_____B := 'EGF'||NEGOCIO_.PREFIJO;
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		SECUENCIA_INT:=1;

		ITERACIONES := ITEMS_ASIENTOS_[1];

		FOR I IN 1..
			ITERACIONES
		LOOP

			RAISE NOTICE 'I:%',I;
			cuenta_ := '';

			if(I=1)then
				cuenta_ := NEGOCIO_.PREFIJO||'-'||NEGOCIO_.CUENTA;
			else
				cuenta_ := NEGOCIO_.PREFIJO||'-'||NEGOCIO_.CUENTA_BANCO;
			end if;

			raise notice 'Cuenta:%',cuenta_;
			raise notice 'Tipo documento:%',NEGOCIO_.tipo_documento;
			raise notice 'Agencia:%',NEGOCIO_.agencia;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FA_FB',NEGOCIO_.tipo_documento, CUENTA_::VARCHAR, NEGOCIO_.agencia, 6)='S')THEN
				MCTYPE.MC_____FECHEMIS__B = NEGOCIO_.FECHA_EMISION; --fecha creacion
				MCTYPE.MC_____FECHVENC__B = NEGOCIO_.fecha_vencimiento; --fecha vencimiento
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(NEGOCIO_.FECHA_EMISION,1,7),'-','') = NEGOCIO_.periodo THEN NEGOCIO_.FECHA_EMISION::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(NEGOCIO_.periodo,1,4), SUBSTRING(NEGOCIO_.periodo,5,2)::INT)::DATE END;
			MCTYPE.MC_____FECHA_____B :=FECHADOC_;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := NEGOCIO_.cod_neg;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( NEGOCIO_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( NEGOCIO_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FA_FB', NEGOCIO_.tipo_documento, cuenta_,NEGOCIO_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FA_FB', NEGOCIO_.tipo_documento, cuenta_,NEGOCIO_.agencia, 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := case when length(NEGOCIO_.tercero2)>9 and INFOCLIENTE.tipo_doc='NIT' then substring(NEGOCIO_.tercero2, 1,9) else NEGOCIO_.tercero2 end;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;

			IF(i = 1)THEN
				MCTYPE.MC_____DEBMONLOC_B := NEGOCIO_.VLR::NUMERIC;
				MCTYPE.MC_____CREMONLOC_B := 0::NUMERIC;
			ELSE
				MCTYPE.MC_____CREMONLOC_B := NEGOCIO_.VLR::NUMERIC;
				MCTYPE.MC_____DEBMONLOC_B := 0;
			END IF;

			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := NEGOCIO_.descripcion||' '||NEGOCIO_.fecha_vencimiento||' '||NEGOCIO_.cod_neg||'-'||NEGOCIO_.CHEQUE;
			MCTYPE.MC_____FECHORCRE_B := NEGOCIO_.FECHA_EMISION::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := NEGOCIO_.FECHA_EMISION::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.tipo_doc;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTR(INFOCLIENTE.nombre_corto,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTR (INFOCLIENTE.nombre,1,64);
			MCTYPE.TERCER_APELLIDOS_B := SUBSTR(INFOCLIENTE.apellidos,1,32);
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.codigo;
			MCTYPE.TERCER_DIRECCION_B := SUBSTR(INFOCLIENTE.direccion,1,64);
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.codigociu;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.telefono)>15 THEN SUBSTR(INFOCLIENTE.telefono,1,15) ELSE INFOCLIENTE.telefono END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FA_FB',NEGOCIO_.tipo_documento, cuenta_,NEGOCIO_.agencia, 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FA_FB', NEGOCIO_.tipo_documento, cuenta_,NEGOCIO_.agencia, 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := NEGOCIO_.DOCUMENTO;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EGR_FA_FB', NEGOCIO_.tipo_documento, cuenta_, NEGOCIO_.agencia, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			--raise notice 'MCTYPE %',MCTYPE;
	 		SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
	 		SECUENCIA_INT :=SECUENCIA_INT+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'EGRESO_ECA') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then
			UPDATE egresodet SET PROCESADO='S' where dstrct='FINV' and branch_code=NEGOCIO_.branch_code and bank_account_no=NEGOCIO_.bank_account_no and document_no=NEGOCIO_.CHEQUE;
		end if;

	END LOOP;

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_egresos_lb_apoteosys()
  OWNER TO postgres;
