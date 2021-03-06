-- Function: con.interfaz_sl_facturacion_fintra_apoteosys_traslado_catera()

-- DROP FUNCTION con.interfaz_sl_facturacion_fintra_apoteosys_traslado_catera();

CREATE OR REPLACE FUNCTION con.interfaz_sl_facturacion_fintra_apoteosys_traslado_catera()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODAS LAS NM GENERADAS POR UN PERIODO PARA TRASLADO A APOTEOSYS
  *AUTOR		:=		@WSIADO
  *FECHA CREACION	:=		2017-10-15
  *LAST_UPDATE		:=	 	2017-10-15
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

FACTURA_NM RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD NUMERIC;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT INTEGER:= 1;
CUENTAS_IVA VARCHAR[] := '{24080107,24080103,24080112,24080105,24080104,24080106}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
VALIDACIONES TEXT;
_RESPUESTA TEXT := 'ERROR';

BEGIN


	INSERT INTO CON.SL_TRASLADO_FACTURAS_APOTEOSYS (
	SELECT 
		*
	FROM 	dblink('dbname=selectrik port=5432 host=localhost user=postgres password=bdversion17'::text, 
				'
				SELECT
					A.ID,
					A.ID_SOLICITUD,
					A.CENTRO_COSTO_INGRESO,
					A.CENTRO_COSTO_GASTO,
					A.DOCUMENTO,
					A.TRASLADO_SELECTRIK,
					A.TRASLADO_FINTRA,
					B.DESCRIPCION,
					A.PERIODO,
					B.NUM_OS
				FROM OPAV.SL_TRASLADO_FACTURAS_APOTEOSYS AS A
				INNER JOIN OPAV.OFERTAS AS B ON (A.ID_SOLICITUD = B.ID_SOLICITUD)
				WHERE 
				TRASLADO_SELECTRIK = 2 
				AND TRASLADO_FINTRA = ''''
				AND A.PERIODO = REPLACE(SUBSTRING(NOW(),1,7),''-'','''')
				--AND A.PERIODO =''201807''
				AND TIPO_PROYECTO !=''TPR00006''
				;'
				::TEXT) AS A(		
						ID NUMERIC,
						ID_SOLICITUD CHARACTER VARYING,
						CENTRO_COSTO_INGRESO CHARACTER VARYING,
						CENTRO_COSTO_GASTO CHARACTER VARYING,
						DOCUMENTO CHARACTER VARYING,
						TRASLADO_SELECTRIK CHARACTER VARYING,
						TRASLADO_FINTRA CHARACTER VARYING,
						DESCRIPCION CHARACTER VARYING,
						PERIODO CHARACTER VARYING,
						NUM_OS CHARACTER VARYING)
						);

	--SELECT CON.INTERFAZ_SL_FACTURACION_FINTRA_APOTEOSYS_TRASLADO_CATERA();

	/**SACAMOS EL LISTADO DE NM*/
	FOR FACTURA_NM IN


		SELECT
			FAC.DOCUMENTO ,--
			FAC.FECHA_FACTURA ,
			FAC.FECHA_VENCIMIENTO ,
			FAC.PERIODO,
			FAC.NIT  ,
			FAC.REFERENCIA_1 AS ID_SOLICITUD,--
			A.CENTRO_COSTO_INGRESO AS CENTRO_COSTOS_INGRESO,--
			A.CENTRO_COSTO_GASTO,--
			FAC.DESCRIPCION,
			A.NUM_OS
		FROM CON.FACTURA AS FAC
		INNER JOIN	CON.SL_TRASLADO_FACTURAS_APOTEOSYS AS A	ON (FAC.REFERENCIA_1 = A.ID_SOLICITUD AND FAC.DOCUMENTO = A.DOCUMENTO )
		WHERE FAC.REG_STATUS = ''


	LOOP
		----SECUENCIA GENERAL
		SELECT INTO SECUENCIA_GEN   NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');


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
		WHERE CL.NIT =  FACTURA_NM.NIT;

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'CXCN';
		MCTYPE.MC_____CODIGO____CD_____B := 'PMFN';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN

		SELECT
			FAC.FECHA_FACTURA ,
			FAC.FECHA_VENCIMIENTO ,
			FAC.PERIODO,
			FAC.NIT  ,
			FAC.REFERENCIA_1 AS ID_SOLICITUD,
			SLT.CENTRO_COSTO_INGRESO AS CENTRO_COSTOS_INGRESO,
			SLT.CENTRO_COSTO_GASTO AS CENTRO_COSTOS_GASTOS,
			'DOCUMENTO TRASLADO NMTR FACTURA: '||INGD.NUM_INGRESO||' SV: '||FAC.REF2 AS DESCRIPCION,
			INGD.TIPO_DOC AS TIPO_DOCUMENTO,
			'DPM-'||CMC.CUENTA AS CUENTA,
			SUM(FACD.VALOR_ITEM) AS VALOR_DEB,
			0  AS VALOR_CREDT,
			FAC.DOCUMENTO AS DOCUMENTO
		FROM CON.FACTURA AS FAC
		INNER JOIN CON.FACTURA_DETALLE 	AS FACD ON ( FAC.DSTRCT = FACD.DSTRCT AND FAC.TIPO_DOCUMENTO = FACD.TIPO_DOCUMENTO  AND FAC.DOCUMENTO = FACD.DOCUMENTO )
		INNER JOIN CON.SL_TRASLADO_FACTURAS_APOTEOSYS	AS SLT	ON (FAC.REFERENCIA_1 = SLT.ID_SOLICITUD  AND FAC.DOCUMENTO = SLT.DOCUMENTO)
		INNER JOIN CON.INGRESO_DETALLE  AS INGD  ON (FAC.DOCUMENTO = INGD.NUM_INGRESO  AND FAC.DOCUMENTO=INGD.DOCUMENTO AND FAC.TIPO_DOCUMENTO=INGD.TIPO_DOC)
		INNER JOIN CON.CMC_DOC AS CMC	ON (INGD.TIPO_DOC= CMC.TIPODOC AND FAC.CMC = CMC.CMC )
		WHERE
		INGD.NUM_INGRESO =FACTURA_NM.DOCUMENTO
		AND FAC.REFERENCIA_1 =FACTURA_NM.ID_SOLICITUD
		AND FAC.REF1 =FACTURA_NM.NUM_OS
		AND FAC.DOCUMENTO=FACTURA_NM.DOCUMENTO
		AND FACD.CODIGO_CUENTA_CONTABLE !='13050702' --VALIDAR LO DE LA CUENTA
		AND FAC.REG_STATUS =''
		AND FAC.TIPO_DOCUMENTO='FAC'
		GROUP BY
			FAC.FECHA_FACTURA ,
			FAC.FECHA_VENCIMIENTO ,
			FAC.PERIODO,
			FAC.NIT  ,
			FAC.REFERENCIA_1 ,
			SLT.CENTRO_COSTO_INGRESO ,
			SLT.CENTRO_COSTO_GASTO ,
			INGD.NUM_INGRESO,
			FAC.REF2 ,
			INGD.TIPO_DOC ,
			CMC.CUENTA ,
			--INGD.VALOR_INGRESO AS VALOR_DEB,
			FAC.DOCUMENTO

		UNION ALL


		SELECT
			FAC.FECHA_FACTURA ,
			FAC.FECHA_VENCIMIENTO ,
			FAC.PERIODO,
			FAC.NIT  ,
			FAC.REFERENCIA_1 AS ID_SOLICITUD,
			SLT.CENTRO_COSTO_INGRESO AS CENTRO_COSTOS_INGRESO,
			SLT.CENTRO_COSTO_GASTO AS CENTRO_COSTOS_GASTOS,
			'DOCUMENTO TRASLADO NMTR FACTURA: '||INGD.NUM_INGRESO||' SV: '||FAC.REF2 AS DESCRIPCION,
			INGD.TIPO_DOC AS TIPO_DOCUMENTO,
			CMC.CUENTA,
			0 AS VALOR_DEB,
			SUM(FACD.VALOR_ITEM) AS VALOR_CREDT,
			--INGD.VALOR_INGRESO  AS VALOR_CREDT,
			FAC.DOCUMENTO AS DOCUMENTO
		FROM CON.FACTURA AS FAC
		INNER JOIN CON.FACTURA_DETALLE 	AS FACD ON ( FAC.DSTRCT = FACD.DSTRCT AND FAC.TIPO_DOCUMENTO = FACD.TIPO_DOCUMENTO  AND FAC.DOCUMENTO = FACD.DOCUMENTO )
		INNER JOIN CON.SL_TRASLADO_FACTURAS_APOTEOSYS	AS SLT	ON (FAC.REFERENCIA_1 = SLT.ID_SOLICITUD  AND FAC.DOCUMENTO = SLT.DOCUMENTO)
		INNER JOIN CON.INGRESO_DETALLE  AS INGD  ON (FAC.DOCUMENTO = INGD.NUM_INGRESO  AND FAC.DOCUMENTO=INGD.DOCUMENTO AND FAC.TIPO_DOCUMENTO=INGD.TIPO_DOC)
		INNER JOIN CON.CMC_DOC AS CMC	ON (INGD.TIPO_DOC= CMC.TIPODOC AND FAC.CMC = CMC.CMC )
		WHERE
		INGD.NUM_INGRESO =FACTURA_NM.DOCUMENTO
		AND FAC.REFERENCIA_1 =FACTURA_NM.ID_SOLICITUD
		AND FAC.REF1 =FACTURA_NM.NUM_OS
		AND FAC.DOCUMENTO=FACTURA_NM.DOCUMENTO
		AND FACD.CODIGO_CUENTA_CONTABLE !='13050702' --VALIDAR LO DE LA CUENTA
		AND FAC.REG_STATUS =''
		AND FAC.TIPO_DOCUMENTO='FAC'
		GROUP BY
			FAC.FECHA_FACTURA ,
			FAC.FECHA_VENCIMIENTO ,
			FAC.PERIODO,
			FAC.NIT  ,
			FAC.REFERENCIA_1 ,
			SLT.CENTRO_COSTO_INGRESO ,
			SLT.CENTRO_COSTO_GASTO ,
			INGD.NUM_INGRESO,
			FAC.REF2 ,
			INGD.TIPO_DOC ,
			CMC.CUENTA,
			--INGD.VALOR_INGRESO  AS VALOR_CREDT,
			FAC.DOCUMENTO


		LOOP

			--RAISE NOTICE 'INFOITEMS_ ====>>>> %',INFOITEMS_;
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN','NM', INFOITEMS_.CUENTA,'', 6)='S')THEN
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
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.PERIODO THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE NOW()::DATE /*CON.SP_FECHA_CORTE_MES(SUBSTRING(FACTURA_NM.PERIODO,1,4), SUBSTRING(FACTURA_NM.PERIODO,5,2)::INT)::DATE*/ END;
			MCTYPE.MC_____FECHA_____B := CASE WHEN (FACTURA_NM.FECHA_FACTURA::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.PERIODO)  THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____REFERENCI_B := FACTURA_NM.NUM_OS;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( FACTURA_NM.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( FACTURA_NM.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN', 'NM', INFOITEMS_.CUENTA,'', 1);
			MCTYPE.MC_____CODIGO____CU_____B := 'A1111F32201';
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  SUBSTRING(REPLACE(FACTURA_NM.NIT,'-',''),1,9);
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.VALOR_DEB::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.VALOR_CREDT::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := SUBSTRING(INFOITEMS_.DESCRIPCION,1,249);
			MCTYPE.MC_____FECHORCRE_B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN','NM', INFOITEMS_.CUENTA,'', 3);
			MCTYPE.MC_____BASE______B:=0;

			IF(MCTYPE.MC_____FECHEMIS__B > MCTYPE.MC_____FECHA_____B) THEN
				MCTYPE.MC_____FECHEMIS__B :=  MCTYPE.MC_____FECHA_____B;
			END IF;

			IF(INFOITEMS_.VALOR_CREDT= 0)THEN
				IF(INFOITEMS_.VALOR_CREDT)THEN
					CONTINUE;
				END IF;
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN','NM', INFOITEMS_.CUENTA,'', 4)='S')THEN

				MCTYPE.MC_____NUMDOCSOP_B := FACTURA_NM.DOCUMENTO;


			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN', 'NM', INFOITEMS_.CUENTA,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--NUMERO DE CUOTAS
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			IF (MCTYPE.MC_____FECHEMIS__B>MCTYPE.MC_____FECHA_____B)THEN
				MCTYPE.MC_____FECHEMIS__B:=MCTYPE.MC_____FECHA_____B;
			END IF;

 			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			RAISE NOTICE 'NM ====>>>> %',FACTURA_NM.DOCUMENTO;
			SW:=CON.SP_INSERT_TABLE_MC_SL_FAC_SEL(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;

		END LOOP;

		-- RAISE NOTICE '<<<<==== TERMINO ====>>>> %',FACTURA_NM.DOCUMENTO;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		RAISE NOTICE 'CON.SP_VALIDACIONES(MCTYPE,''FAC_NM''): %',CON.SP_VALIDACIONES(MCTYPE,'FAC_NM');
		IF CON.SP_VALIDACIONES(MCTYPE,'FAC_NM') !='N' THEN
			UPDATE CON.SL_TRASLADO_FACTURAS_APOTEOSYS SET TRASLADO_FINTRA= 2 WHERE DOCUMENTO =FACTURA_NM.DOCUMENTO;

		END IF;

		SECUENCIA_INT:=1;


	END LOOP;



		SELECT INTO _RESPUESTA RESPUESTA
		FROM 	dblink('dbname=selectrik port=5432 host=localhost user=postgres password=bdversion17'::text, '
				SELECT OPAV.SL_TRASLADO_FACTURAS_APOTEOSYS_UPDATE(2);
		'::TEXT) AS A(RESPUESTA TEXT);
	--RAISE NOTICE '_RESPUESTA: %',_RESPUESTA;

	IF(_RESPUESTA = 'OK') THEN
		DELETE FROM  CON.SL_TRASLADO_FACTURAS_APOTEOSYS;
	END IF;
	DELETE FROM CON.MC_SL_FAC_SEL WHERE MC_____DEBMONLOC_B=0 AND MC_____CREMONLOC_B=0;

RETURN _RESPUESTA ;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_sl_facturacion_fintra_apoteosys_traslado_catera()
  OWNER TO postgres;
