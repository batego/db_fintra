-- Function: con.interfaz_sl_doc_cxp_contratistas_selectrik_apoteosys()

-- DROP FUNCTION con.interfaz_sl_doc_cxp_contratistas_selectrik_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_sl_doc_cxp_contratistas_selectrik_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
 /************************************************
  *DESCRIPCION:
  *AUTOR		:=		@BTERRAZA
  *FECHA CREACION	:=		2018-01-10
  *LAST_UPDATE		:=	 	2018-01-10
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/


FACTURA_NM RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD NUMERIC;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT INTEGER:= 1;
CUENTAS_IVA VARCHAR[] := '{}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
VALIDACIONES TEXT;
_EXISTE CHARACTER VARYING :='';
_VALOR_AJUSTE NUMERIC;

BEGIN

	--Paso 2 Dinamica Cxp Contratista selectrik
	FOR FACTURA_NM IN

				SELECT
					A.TIPO_DOCUMENTO,
					A.FECHA_DOCUMENTO AS FECHA_FACTURA,
					A.FECHA_VENCIMIENTO,
					A.PERIODO,
					A.PROVEEDOR AS NIT,
					A.DESCRIPCION,
					A.DOCUMENTO,
					A.VLR_NETO,
					A.HANDLE_CODE
				FROM FIN.CXP_DOC AS A
				INNER JOIN PROVEEDOR AS PROV ON (PROV.NIT=A.PROVEEDOR)
				LEFT JOIN TEM.TRASLADO_CXP_CONTRATISTAS_FINTRA_SELECTRIK TEM ON (A.HANDLE_CODE=TEM.HANDLE_CODE AND A.TIPO_DOCUMENTO=TEM.TIPO_DOCUMENTO AND A.PERIODO=TEM.PERIODO
													AND  A.PROVEEDOR= TEM.PROVEEDOR   AND  A.DOCUMENTO= TEM.DOCUMENTO   )
				WHERE A.TIPO_DOCUMENTO	= 'FAP'
				AND A.HANDLE_CODE = 'SL'
				AND A.PERIODO = REPLACE(SUBSTRING(NOW(),1,7),'-','')
				AND A.REG_STATUS = ''
				AND A.DESCRIPCION = 'CXP A SELECTRICK INGRESOS'
				AND TEM.PROCESADO IS NULL
				--and a.documento='S00000720'

/**
select con.interfaz_sl_doc_cxp_contratistas_selectrik_apoteosys()
'NM11630_11'
select * from
update
con.mc_doc_cxp_cont_fin set procesado='S' where procesado='R' and MC_____CODIGO____CD_____B='CPSL' and MC_____CODIGO____PF_____B = 2017
and MC_____NUMERO____PERIOD_B=2
mc_____numero____b not in('615579',
'615589')
update con.mc_doc_cxp_cont_fin set procesado='N' where procesado='R' and MC_____CODIGO____CD_____B='CPSL' and mc_____numero____period_b=4

delete from  con.mc_doc_cxp_cont_fin where
procesado='N' and
MC_____CODIGO____CD_____B='CPSL'

*/

	LOOP

		-- SELECT INTO INFOCLIENTE
-- 			'NIT' AS TIPO_DOC,
-- 			(CASE
-- 			WHEN GRAN_CONTRIBUYENTE ='N' AND AGENTE_RETENEDOR ='N' THEN 'RCOM'
-- 			WHEN GRAN_CONTRIBUYENTE ='N' AND AGENTE_RETENEDOR ='S' THEN 'RCAU'
-- 			WHEN GRAN_CONTRIBUYENTE ='S' AND AGENTE_RETENEDOR ='N' THEN 'GCON'
-- 			WHEN GRAN_CONTRIBUYENTE ='S' AND AGENTE_RETENEDOR ='S' THEN 'GCAU'
-- 			ELSE 'PNAL' END) AS CODIGO,
-- 			'08001'AS CODIGOCIU,
-- 			(D.NOMBRE1||' '||D.NOMBRE2) AS NOMBRE_CORTO,
-- 			PAYMENT_NAME AS  NOMBRE,
-- 			(D.APELLIDO1||' '||D.APELLIDO2) AS APELLIDOS,
-- 			DIRECCION,
-- 			TELEFONO
-- 		FROM PROVEEDOR PROV
-- 		LEFT JOIN NIT D ON(D.CEDULA=PROV.NIT)
-- 		LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
-- 		WHERE NIT =  FACTURA_NM.NIT;

		----SECUENCIA GENERAL
		SELECT INTO SECUENCIA_GEN  NEXTVAL('CON.INTERFAZ_SECUENCIA_CXP_APOTEOSYS');

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'CXPN';
		MCTYPE.MC_____CODIGO____CD_____B := 'CPSL';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/

		FOR INFOITEMS_ IN

			select
				codigo_cuenta as cuenta,
				'9008439923' as proveedor,
				documento,
				tipo_documento,
				case when vlr<0 then vlr*-1 else vlr end as valor_deb,
				0 as valor_cre,
				descripcion,
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
				fin.cxp_items_doc
			LEFT JOIN
				PROVEEDOR C ON(C.NIT='9008439923')
			LEFT JOIN
				NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN
				CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN
				CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=C.NIT)
			where
				tipo_documento='FAP' and
				tipo_referencia_1='ACC' and
				referencia_1 in(select referencia_1 from fin.cxp_items_doc where documento=FACTURA_NM.documento group by referencia_1)
				and descripcion ilike 'BONIFICACION%'
			union all
			SELECT
				A.CODIGO_CUENTA AS CUENTA,
				nm.nit as PROVEEDOR,
				nm.documento,
				A.TIPO_DOCUMENTO,
				CASE WHEN valor_unitario>0 THEN valor_unitario ELSE 0 END AS VALOR_DEB,
				CASE WHEN valor_unitario<0 THEN valor_unitario*-1 ELSE 0 END AS VALOR_CREDT,
				A.DESCRIPCION,
				'NIT' AS TERCER_CODIGO____TIT____B,
				'' AS TERCER_DIGICHEQ__B,
				'' AS TERCER_NOMBCORT__B,
				'' AS TERCER_APELLIDOS_B,
				cl.nomcli AS TERCER_NOMBEXTE__B,
				'RCOM' AS TERCER_CODIGO____TT_____B,
				cl.direccion AS TERCER_DIRECCION_B,
				'08001' AS TERCER_CODIGO____CIUDAD_B,
				cl.telefono AS TERCER_TELEFONO1_B
			FROM
				FIN.CXP_ITEMS_DOC A
			INNER JOIN
				FIN.CXP_DOC B ON(B.DSTRCT = A.DSTRCT AND B.TIPO_DOCUMENTO = A.TIPO_DOCUMENTO AND B.PROVEEDOR = A.PROVEEDOR AND B.DOCUMENTO = A.DOCUMENTO)
			INNER JOIN
				sl_centro_costos_selectrik_dblink AS CCS     ON (A.REFERENCIA_1 = CCS.ID_ACCION )
			inner join
				con.factura nm on(nm.tipo_documento='FAC' and nm.documento ilike 'NM%' and nm.ref1=CCS.NUM_OS)
			inner join
				con.factura_detalle fd on(fd.tipo_documento=nm.tipo_documento and fd.documento=nm.documento and fd.referencia_1=a.referencia_1 and codigo_cuenta_contable=a.codigo_cuenta )
			left join
				cliente cl on(cl.codcli=nm.codcli)
			WHERE
				A.TIPO_DOCUMENTO = 'FAP'
				and a.descripcion != 'CONCEPTO_BONIFICACION'
				AND A.DOCUMENTO = FACTURA_NM.documento
				AND B.HANDLE_CODE = 'SL'
				AND A.PROVEEDOR = FACTURA_NM.nit
				AND A.REG_STATUS = ''
				AND A.VLR != 0
				AND NM.REG_STATUS = ''
				AND FD.REG_STATUS = ''
			union all
			/*SELECT
				--CMC.CUENTA,
				'53959502' as cuenta,
				A.PROVEEDOR,
				'' AS DOCUMENTO,
				A.TIPO_DOCUMENTO,
				sum(vlr) AS VALOR_DEB,
				0 AS VALOR_CREDT,
				'AJUSTE '||a.descripcion||' Accion: '||a.referencia_1 as DESCRIPCION,
				--a.referencia_1 AS accion,
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
			FROM
				FIN.CXP_ITEMS_DOC A
			INNER JOIN
				FIN.CXP_DOC B ON(B.DSTRCT = A.DSTRCT AND B.TIPO_DOCUMENTO = A.TIPO_DOCUMENTO AND B.PROVEEDOR = A.PROVEEDOR AND B.DOCUMENTO = A.DOCUMENTO)
			INNER JOIN
				CON.CMC_DOC AS CMC  ON (B.HANDLE_CODE = CMC.CMC AND CMC.TIPODOC = B.TIPO_DOCUMENTO )
			INNER JOIN
				sl_centro_costos_selectrik_dblink AS CCS ON (A.REFERENCIA_1 = CCS.ID_ACCION )
			LEFT JOIN
				PROVEEDOR C ON(C.NIT=A.PROVEEDOR)
			LEFT JOIN
				NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN
				CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN
				CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=C.NIT)
			WHERE
				A.TIPO_DOCUMENTO = 'FAP'
				AND B.HANDLE_CODE ='SL'
				AND A.DOCUMENTO  =FACTURA_NM.documento
				AND A.PROVEEDOR = FACTURA_NM.nit
				AND A.REG_STATUS =''
				AND A.VLR != 0
				AND A.REFERENCIA_1 IN ('9042626')
				AND A.CODIGO_CUENTA != 28151002
			GROUP BY
				A.DOCUMENTO,
				A.TIPO_DOCUMENTO,
				codigo_cuenta,
				A.DESCRIPCION,
				A.PROVEEDOR,
				D.TIPO_IDEN,
				C.DIGITO_VERIFICACION,
				D.NOMBRE1,
				D.NOMBRE2,
				D.APELLIDO1,
				D.APELLIDO2,
				D.NOMBRE,
				C.GRAN_CONTRIBUYENTE,
				C.AGENTE_RETENEDOR,
				D.DIRECCION,
				E.CODIGO_DANE2,
				D.TELEFONO
				,a.referencia_1
			union all*/
			SELECT
				CMC.CUENTA,
				A.PROVEEDOR,
				A.DOCUMENTO,
				A.TIPO_DOCUMENTO,
				0 AS VALOR_DEB,
				sum(vlr) AS VALOR_CREDT,
				'CXP A SELECTRICK' as DESCRIPCION,
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
			FROM
				FIN.CXP_ITEMS_DOC A
			INNER JOIN
				FIN.CXP_DOC B ON(B.DSTRCT = A.DSTRCT AND B.TIPO_DOCUMENTO = A.TIPO_DOCUMENTO AND B.PROVEEDOR = A.PROVEEDOR AND B.DOCUMENTO = A.DOCUMENTO)
			INNER JOIN
				CON.CMC_DOC AS CMC  ON (B.HANDLE_CODE = CMC.CMC AND CMC.TIPODOC = B.TIPO_DOCUMENTO )
			--INNER JOIN
			--	sl_centro_costos_selectrik_dblink AS CCS ON (A.REFERENCIA_1 = CCS.ID_ACCION )
			LEFT JOIN
				PROVEEDOR C ON(C.NIT=A.PROVEEDOR)
			LEFT JOIN
				NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN
				CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN
				CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=C.NIT)
			WHERE
				A.TIPO_DOCUMENTO = 'FAP'
				AND B.HANDLE_CODE ='SL'
				AND A.DOCUMENTO  =FACTURA_NM.documento
				AND A.PROVEEDOR = FACTURA_NM.nit
				AND A.REG_STATUS =''
				AND A.VLR != 0
			GROUP BY
				A.DOCUMENTO,
				A.TIPO_DOCUMENTO,
				CMC.CUENTA,
				A.PROVEEDOR,
				D.TIPO_IDEN,
				C.DIGITO_VERIFICACION,
				D.NOMBRE1,
				D.NOMBRE2,
				D.APELLIDO1,
				D.APELLIDO2,
				D.NOMBRE,
				C.GRAN_CONTRIBUYENTE,
				C.AGENTE_RETENEDOR,
				D.DIRECCION,
				E.CODIGO_DANE2,
				D.TELEFONO
			order by 3,7

		LOOP

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_FIN','FAP', INFOITEMS_.CUENTA,'', 6)='S')THEN
				MCTYPE.MC_____FECHVENC__B = FACTURA_NM.FECHA_VENCIMIENTO; --FECHA VENCIMIENTO
					IF (FACTURA_NM.FECHA_VENCIMIENTO < FACTURA_NM.FECHA_FACTURA)THEN /** SE VALIDA SI LA FECHA DE VENCIMEINTO ES MENOR A LA DE CREACION*/
						MCTYPE.MC_____FECHEMIS__B = FACTURA_NM.FECHA_VENCIMIENTO; --FECHA CREACION
					ELSE
						MCTYPE.MC_____FECHEMIS__B = FACTURA_NM.FECHA_FACTURA; --FECHA CREACION
					END IF;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;


			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.PERIODO THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(FACTURA_NM.PERIODO,1,4), SUBSTRING(FACTURA_NM.PERIODO,5,2)::INT)::DATE END;

			MCTYPE.MC_____FECHA_____B := CASE WHEN (FACTURA_NM.FECHA_FACTURA::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.PERIODO)  THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := 0;--SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____REFERENCI_B := '-'; --INFOITEMS_.NUM_OS; ---CAMBIAR A MULTISERVICIO...
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( FACTURA_NM.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( FACTURA_NM.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_FIN', 'FAP', INFOITEMS_.CUENTA,'', 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_FIN', 'FAP', INFOITEMS_.CUENTA,'', 2); --INFOITEMS_.CENTRO_COSTOS_INGRESO;
			MCTYPE.MC_____IDENTIFIC_TERCER_B := case when length(INFOITEMS_.proveedor)>9 and INFOITEMS_.TERCER_CODIGO____TIT____B='NIT' then SUBSTRING(REPLACE(INFOITEMS_.proveedor,'-',''),1,9) else INFOITEMS_.proveedor end;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.VALOR_DEB::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.VALOR_CRE::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := SUBSTRING((INFOITEMS_.DESCRIPCION),1,249); --SUBSTRING(INFOITEMS_.DESCRIPCION,1,249);
			MCTYPE.MC_____FECHORCRE_B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOITEMS_.TERCER_CODIGO____TIT____B;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTRING(INFOITEMS_.TERCER_NOMBCORT__B,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTRING(INFOITEMS_.TERCER_NOMBEXTE__B,1,64);
			MCTYPE.TERCER_APELLIDOS_B := INFOITEMS_.TERCER_APELLIDOS_B;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOITEMS_.TERCER_CODIGO____TT_____B;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOITEMS_.TERCER_DIRECCION_B)>64 THEN SUBSTR(INFOITEMS_.TERCER_DIRECCION_B,1,64) ELSE INFOITEMS_.TERCER_DIRECCION_B END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOITEMS_.TERCER_CODIGO____CIUDAD_B;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOITEMS_.TERCER_TELEFONO1_B)>15 THEN SUBSTR(INFOITEMS_.TERCER_TELEFONO1_B,1,15) ELSE INFOITEMS_.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_FIN','FAP', INFOITEMS_.CUENTA,'', 3);
			MCTYPE.MC_____BASE______B:=0;

			IF(MCTYPE.MC_____FECHEMIS__B > MCTYPE.MC_____FECHA_____B) THEN
				MCTYPE.MC_____FECHEMIS__B :=  MCTYPE.MC_____FECHA_____B;
			END IF;


			IF(INFOITEMS_.CUENTA = ANY (CUENTAS_IVA))THEN
				IF(INFOITEMS_.VALOR_CREDT>0) THEN
					MCTYPE.MC_____BASE______B:= INFOITEMS_.VALOR_CREDT/0.16;
				ELSE
					MCTYPE.MC_____BASE______B:= INFOITEMS_.VALOR_DEB/0.16;
				END IF;
			END IF;

			MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.DOCUMENTO;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_FIN', 'FAP', INFOITEMS_.CUENTA,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--NUMERO DE CUOTAS
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;


			RAISE NOTICE 'FAP ====>>>> %',INFOITEMS_.CUENTA;
			SW:=CON.SP_INSERT_TABLE_MC_DOC_CXP_CONT_FINTRA(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;

		END LOOP;

		RAISE NOTICE '<<<<==== TERMINO ====>>>> %',FACTURA_NM.DOCUMENTO;

		SELECT INTO _VALOR_AJUSTE   SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
		 FROM CON.MC_DOC_CXP_CONT_FIN WHERE MC_____NUMERO____B= MCTYPE.MC_____NUMERO____B AND  MC_____CODIGO____CD_____B='CPSL';
                RAISE NOTICE '_VALOR_AJUSTE: %',_VALOR_AJUSTE;
		IF ((_VALOR_AJUSTE BETWEEN -200000 AND 200000 AND _VALOR_AJUSTE!=0.00))THEN
		    PERFORM CON.AJUSTE_PESO_APOTEOSYS(_VALOR_AJUSTE, '42958101'::VARCHAR, '53959502'::VARCHAR, 'A1111S99951'::VARCHAR, MCTYPE);
		END IF;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		--IF CON.SP_VALIDACIONES(MCTYPE,'FAC_CC') = 'N' THEN
		--	SW = 'N';
		--	CONTINUE;
		--END IF;

		IF(SW = 'S')THEN
			INSERT INTO TEM.TRASLADO_CXP_CONTRATISTAS_FINTRA_SELECTRIK (PERIODO , DOCUMENTO, HANDLE_CODE, CONCEPTO, PROCESADO, CREATION_DATE , CREATION_USER, LAST_UPDATE , USER_UPDATE, PROVEEDOR, TIPO_DOCUMENTO)
			VALUES (FACTURA_NM.PERIODO, FACTURA_NM.DOCUMENTO , FACTURA_NM.HANDLE_CODE , MCTYPE.MC_____CODIGO____CD_____B , 'S', now(), 'BTERRAZA', now(), 'BTERRAZA', FACTURA_NM.NIT, FACTURA_NM.TIPO_DOCUMENTO);

		END IF;

		SECUENCIA_INT:=1;

	END LOOP;

RETURN 'OK';

END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_sl_doc_cxp_contratistas_selectrik_apoteosys()
  OWNER TO postgres;
