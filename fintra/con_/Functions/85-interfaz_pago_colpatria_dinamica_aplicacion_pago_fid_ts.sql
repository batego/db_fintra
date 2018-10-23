-- Function: con.interfaz_pago_colpatria_dinamica_aplicacion_pago_fid_ts()

-- DROP FUNCTION con.interfaz_pago_colpatria_dinamica_aplicacion_pago_fid_ts();

CREATE OR REPLACE FUNCTION con.interfaz_pago_colpatria_dinamica_aplicacion_pago_fid_ts()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODAS RE GENERADAS
  *AUTOR		:=		@JZAPATA @DVALENCIA
  *FECHA CREACION	:=		2018-07-11
  *LAST_UPDATE	:=	 	2018-07-11
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

FACTURA_RE RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD NUMERIC;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT INTEGER:= 1;
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
VALIDACIONES TEXT;
_RESPUESTA TEXT := 'ERROR';

BEGIN

	/**
	SELECT CON.INTERFAZ_PAGO_COLPATRIA_DINAMICA_APLICACION_PAGO_FID_TS()
	DELETE FROM con.mc_sl_fac_sel where procesado='R' and MC_____CODIGO____CD_____B in('CCFI') AND MC_____NUMERO____B=79457
	SELECT * FROM con.mc_sl_fac_sel where procesado='N'
	update con.mc_sl_fac_sel set procesado='N' where mc_____numero____b=79197
	*/

	/**SACAMOS EL LISTADO DE NM*/
	FOR FACTURA_RE IN

				select FAC.DOCUMENTO ,
					FAC.FECHA_FACTURA ,
					FAC.FECHA_VENCIMIENTO ,
					FAC.PERIODO,
					FAC.NIT,
					--FAC.CMC AS HC,
					FAC.DESCRIPCION,
					FAC.PERIODO
				FROM
					CON.FACTURA as fac
				WHERE
					SUBSTRING(fac.DOCUMENTO,1,2) = 'RE'
					--AND COALESCE(PROCESADO,'N')= 'N'
					--and fac.DOCUMENTO = 'RE00794'
					AND FAC.CMC='RT'
					AND FAC.PERIODO >= '201701'
					AND FAC.REG_STATUS = ''
				order by
					FAC.DOCUMENTO


	LOOP
		----SECUENCIA GENERAL
		SELECT INTO SECUENCIA_GEN   NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'CXCN';
		MCTYPE.MC_____CODIGO____CD_____B := 'CFTS';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL


		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN


			---CONSULTA DETALLE FACTURA RE
			SELECT
				F.TIPO_DOCUMENTO,
				cmc.CUENTA,
				'FINTRA' AS DESCRIPCION,
				(CASE WHEN (VALOR_factura>0) THEN
				VALOR_factura ELSE 0 END) AS VALOR_DEB,
				(CASE WHEN (VALOR_factura<0) THEN
				VALOR_factura*(-1) ELSE 0 END) AS VALOR_CREDT,
				--CMC AS HC,
				F.DOCUMENTO AS DOCUMENTO_SOPORTE,
				F.DOCUMENTO AS REF,
				F.DESCRIPCION AS OBSERVACION,
				F.NIT AS TERCERO
			FROM 	CON.FACTURA AS F
			INNER JOIN
				CON.CMC_DOC AS CMC	ON (F.TIPO_DOCUMENTO = CMC.TIPODOC AND F.CMC = CMC.CMC )
			WHERE  	F.DOCUMENTO 	in (FACTURA_RE.DOCUMENTO)
			AND F.REG_STATUS = 	''
			AND	F.REG_STATUS  = 	''
			union all
			SELECT
				Facd.TIPO_DOCUMENTO,
				id.cuenta,
				'MULTISERVICIO' AS DESCRIPCION,
				(CASE WHEN (VALOR_ITEM<0) THEN
				VALOR_ITEM*(-1) ELSE 0 END) AS VALOR_DEB,
				(CASE WHEN (VALOR_ITEM>0) THEN
				VALOR_ITEM ELSE 0 END) AS VALOR_CREDT,
				--CMC AS HC,
				REPLACE(FACD.NUMERO_REMESA,'P','N') AS DOCUMENTO_SOPORTE,
				F.DOCUMENTO AS REF,
				F.DOCUMENTO||'->'||FACD.DESCRIPCION  AS OBSERVACION,
				case when id.cuenta='16252148' then replace(substring(FACD.DESCRIPCION,1,strpos(FACD.DESCRIPCION,'_recaudo')-1),'-','') else replace(FNM.NIT,'-','') end AS TERCERO
			FROM
				con.factura AS F
			INNER JOIN
				CON.FACTURA_DETALLE 	AS FACD ON ( FACD.DSTRCT = F.DSTRCT AND FACD.TIPO_DOCUMENTO = F.TIPO_DOCUMENTO AND FACD.DOCUMENTO = F.DOCUMENTO )
			left JOIN
				CON.FACTURA FNM ON (FNM.DOCUMENTO=FACD.NUMERO_REMESA and FNM.REG_STATUS = 	'')
			left join
				con.ingreso_detalle id on(id.tipo_documento='ICA' and id.num_ingreso=substring(facd.documento_relacionado,6,8) and id.factura=FACD.NUMERO_REMESA)
			where
				f.documento=FACTURA_RE.DOCUMENTO
				AND F.REG_STATUS = 	''
				AND	F.REG_STATUS  = 	''
				AND     FACD.REG_STATUS =	''

		LOOP

				SELECT INTO INFOCLIENTE
					'NIT' AS TIPO_DOC,
					'GCON' AS CODIGO,
					(CASE
					WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
					ELSE '08001' END) AS CODIGOCIU,
					NOMCLI AS NOMBRE_CORTO,
					NOMCLI AS  NOMBRE,
					'' AS APELLIDOS,
					DIRECCION,
					TELEFONO

				FROM CLIENTE CL
				LEFT JOIN CIUDAD E ON(E.CODCIU=CL.CIUDAD)
				WHERE CL.NIT =  INFOITEMS_.TERCERO;


			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGOS_MULTI','FAC', INFOITEMS_.CUENTA,'', 6)='S')THEN
				MCTYPE.MC_____FECHVENC__B = FACTURA_RE.FECHA_VENCIMIENTO; --FECHA VENCIMIENTO
					IF (FACTURA_RE.FECHA_VENCIMIENTO < FACTURA_RE.FECHA_FACTURA)THEN /** SE VALIDA SI LA FECHA DE VENCIMEINTO ES MENOR A LA DE CREACION*/
						MCTYPE.MC_____FECHEMIS__B = FACTURA_RE.FECHA_VENCIMIENTO; --FECHA CREACION
					ELSE
						MCTYPE.MC_____FECHEMIS__B = FACTURA_RE.FECHA_FACTURA; --FECHA CREACION
					END IF;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(FACTURA_RE.FECHA_FACTURA,1,7),'-','') = FACTURA_RE.PERIODO THEN FACTURA_RE.FECHA_FACTURA::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(FACTURA_RE.PERIODO,1,4), SUBSTRING(FACTURA_RE.PERIODO,5,2)::INT)::DATE END;
			MCTYPE.MC_____FECHA_____B := CASE WHEN (FACTURA_RE.FECHA_FACTURA::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(FACTURA_RE.FECHA_FACTURA,1,7),'-','') = FACTURA_RE.PERIODO)  THEN FACTURA_RE.FECHA_FACTURA::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____REFERENCI_B := FACTURA_RE.DOCUMENTO;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( FACTURA_RE.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( FACTURA_RE.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGOS_MULTI', 'FAC', INFOITEMS_.CUENTA,'', 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGOS_MULTI', 'FAC', INFOITEMS_.CUENTA,'', 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  SUBSTRING(REPLACE(INFOITEMS_.TERCERO,'-',''),1,9);
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.VALOR_DEB::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.VALOR_CREDT::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := SUBSTRING(INFOITEMS_.OBSERVACION,1,249);
			MCTYPE.MC_____FECHORCRE_B := FACTURA_RE.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := FACTURA_RE.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.TIPO_DOC;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTRING(INFOCLIENTE.NOMBRE_CORTO,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTRING(INFOCLIENTE.NOMBRE,1,64);
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.APELLIDOS;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.CODIGO;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.DIRECCION)>64 THEN SUBSTR(INFOCLIENTE.DIRECCION,1,64) ELSE INFOCLIENTE.DIRECCION END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.CODIGOCIU;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TELEFONO)>15 THEN SUBSTR(INFOCLIENTE.TELEFONO,1,15) ELSE INFOCLIENTE.TELEFONO END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGOS_MULTI','FAC', INFOITEMS_.CUENTA,'', 3);
			MCTYPE.MC_____BASE______B:=0;

			IF(MCTYPE.MC_____FECHEMIS__B > MCTYPE.MC_____FECHA_____B) THEN
				MCTYPE.MC_____FECHEMIS__B :=  MCTYPE.MC_____FECHA_____B;
			END IF;

			IF(INFOITEMS_.VALOR_CREDT= 0)THEN
				IF(INFOITEMS_.VALOR_CREDT)THEN
					CONTINUE;
				END IF;
			END IF;


			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGOS_MULTI','FAC', INFOITEMS_.CUENTA,'', 4)='S')THEN

				MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.DOCUMENTO_SOPORTE;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGOS_MULTI', 'FAC', INFOITEMS_.CUENTA,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--NUMERO DE CUOTAS
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

 			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			RAISE NOTICE 'RE ====>>>> %',FACTURA_RE.DOCUMENTO;
			RAISE NOTICE 'MCTYPE ====>>>> %',MCTYPE;
			SW:=CON.SP_INSERT_TABLE_MC_SL_FAC_SEL(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;

		END LOOP;

		RAISE NOTICE '<<<<==== TERMINO ====>>>> %',FACTURA_RE.DOCUMENTO;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'FAC_NM') !='N' THEN
		RAISE NOTICE 'VALIDACION ====>>>> %',CON.SP_VALIDACIONES(MCTYPE,'FAC_NM');
			UPDATE CON.FACTURA SET PROCESADO= 'S' WHERE DOCUMENTO =FACTURA_RE.DOCUMENTO;
		END IF;

		SECUENCIA_INT:=1;

	END LOOP;


RETURN 'OK' ;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_pago_colpatria_dinamica_aplicacion_pago_fid_ts()
  OWNER TO postgres;
