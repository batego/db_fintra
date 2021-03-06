-- Function: con.interfaz_sl_facturacion_fintra_apoteosys()

-- DROP FUNCTION con.interfaz_sl_facturacion_fintra_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_sl_facturacion_fintra_apoteosys()
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
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
CUENTAS_IVA VARCHAR[] := '{24080107,24080103,24080112,24080105,24080104,24080106}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;
_respuesta text := 'Error';

BEGIN


	INSERT INTO CON.SL_TRASLADO_FACTURAS_APOTEOSYS(
	SELECT 
		*
	FROM 	dblink('dbname=selectrik port=5432 host=localhost user=postgres password=bdversion17'::text, 
				'
				select
					A.id,
					A.id_solicitud,
					A.centro_costo_ingreso,
					A.centro_costo_gasto,
					A.documento,
					A.traslado_selectrik,
					A.traslado_fintra,
					B.DESCRIPCION,
					A.PERIODO,
					b.num_os
				from opav.sl_traslado_facturas_apoteosys AS A
				INNER JOIN OPAV.OFERTAS AS B ON (A.ID_SOLICITUD = B.ID_SOLICITUD)
				where traslado_fintra ='''' 
				AND a.DOCUMENTO not  IN (SELECT NM FROM  tem.sl_nm_16) 
				and traslado_selectrik = 2 
				AND A.PERIoDO = REPLACE(SUBSTRING(NOW(),1,7),''-'','''')
				--and a.PERIODO = ''201807''
				--AND A.DOCUMENTO = ''NM14038_1''
				AND TIPO_PROYECTO !=''TPR00006''
				;'
				::text) as a(		
						id numeric,
						id_solicitud character varying,
						centro_costo_ingreso character varying,
						centro_costo_gasto character varying,
						documento character varying,
						traslado_selectrik character varying,
						traslado_fintra character varying,
						descripcion character varying,
						periodo character varying,
						num_os character varying)
						);

	--SELECT CON.INTERFAZ_SL_FACTURACION_FINTRA_APOTEOSYS()

	/**SACAMOS EL LISTADO DE NM*/
	FOR FACTURA_NM IN


		SELECT
			fac.documento ,
			fac.fecha_factura ,
			fac.fecha_vencimiento ,
			fac.periodo,
			fac.nit  ,
			fac.referencia_1 as id_solicitud,
			A.centro_costo_ingreso AS CENTRO_COSTOS_INGRESO,
			A.centro_costo_gasto,
			fac.descripcion,
			A.num_os
		FROM CON.FACTURA as fac
		INNER JOIN	CON.SL_TRASLADO_FACTURAS_APOTEOSYS AS A	ON (FAC.REFERENCIA_1 = A.ID_SOLICITUD and fac.documento = A.documento )
		WHERE FAC.REG_STATUS = ''


	LOOP
		----SECUENCIA GENERAL
		SELECT INTO SECUENCIA_GEN   NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');


		select INTO INFOCLIENTE
		'NIT' AS tipo_doc,
			'GCON' as codigo,
			(CASE
			WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
			ELSE '08001' END) as codigociu,
			nomcli AS nombre_corto,
			nomcli AS  nombre,
			'' AS apellidos,
			direccion,
			telefono

		from CLIENTE cl
		LEFT JOIN CIUDAD E ON(E.CODCIU=cl.ciudad)
		where cl.nit =  FACTURA_NM.NIT;

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'CXCN';
		MCTYPE.MC_____CODIGO____CD_____B := 'NMFN';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL



		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN

			SELECT
					TIPO_DOCUMENTO
					,CODIGO_CUENTA_CONTABLE AS CUENTA
					,(CASE WHEN (VALOR_ITEM>0) THEN
					VALOR_ITEM ELSE 0 END) AS VALOR_CREDT
					,(CASE WHEN (VALOR_ITEM<0) THEN
					VALOR_ITEM*(-1) ELSE 0 END) AS VALOR_DEB,
					DESCRIPCION::CHARACTER VARYING(250)
			FROM 	CON.FACTURA_DETALLE AS A
			WHERE  	A.DOCUMENTO 	= 	FACTURA_NM.DOCUMENTO
			AND 	A.REG_STATUS 	= ''
			AND 	A.CODIGO_CUENTA_CONTABLE !='13050702'
			union all(
			SELECT 	FAC.TIPO_DOCUMENTO ,
				CMC.CUENTA ,
				0 AS VALOR_CREDT,
				SUM(VALOR_ITEM) AS VALOR_DEB,
				FAC.DESCRIPCION
				FROM CON.FACTURA AS FAC
				INNER JOIN CON.FACTURA_DETALLE 	AS FACD ON ( FACD.DSTRCT = FAC.DSTRCT AND FACD.TIPO_DOCUMENTO = FACD.TIPO_DOCUMENTO AND FACD.DOCUMENTO = FAC.DOCUMENTO )
				INNER JOIN CON.CMC_DOC AS CMC	ON (FAC.TIPO_DOCUMENTO = CMC.TIPODOC AND FAC.CMC = CMC.CMC )
				WHERE
						FAC.DOCUMENTO	= 	FACTURA_NM.DOCUMENTO
					AND	FAC.REG_STATUS  = 	''
					AND 	FACD.CODIGO_CUENTA_CONTABLE !='13050702'
				GROUP BY
					FAC.TIPO_DOCUMENTO ,
					CMC.CUENTA ,
					FAC.DESCRIPCION
					)




		LOOP


			iF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN','NM', INFOITEMS_.cuenta,'', 6)='S')THEN
				MCTYPE.MC_____FECHVENC__B = FACTURA_NM.FECHA_VENCIMIENTO; --fecha vencimiento
					if (FACTURA_NM.fecha_vencimiento < FACTURA_NM.FECHA_FACTURA)then /** se valida si la fecha de vencimeinto es menor a la de creacion*/
						MCTYPE.MC_____FECHEMIS__B = FACTURA_NM.FECHA_VENCIMIENTO; --fecha creacion
					else
						MCTYPE.MC_____FECHEMIS__B = FACTURA_NM.FECHA_FACTURA; --fecha creacion
					end if;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.periodo THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE NOW()::DATE/*con.sp_fecha_corte_mes(SUBSTRING(FACTURA_NM.periodo,1,4), SUBSTRING(FACTURA_NM.periodo,5,2)::INT)::DATE*/ END;
			MCTYPE.MC_____FECHA_____B := CASE WHEN (FACTURA_NM.FECHA_FACTURA::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.PERIODO)  THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := FACTURA_NM.num_os;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( FACTURA_NM.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( FACTURA_NM.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN', 'NM', INFOITEMS_.cuenta,'', 1);
			MCTYPE.MC_____CODIGO____CU_____B := 'A1111F32201';--FACTURA_NM.CENTRO_COSTOS_INGRESO;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  substring(REPLACE(FACTURA_NM.nit,'-',''),1,9);
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := substring(INFOITEMS_.descripcion,1,249);
			MCTYPE.MC_____FECHORCRE_B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.tipo_doc;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTRING(INFOCLIENTE.nombre_corto,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTRING(INFOCLIENTE.nombre,1,64);
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.apellidos;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.codigo;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.direccion)>64 THEN SUBSTR(INFOCLIENTE.direccion,1,64) ELSE INFOCLIENTE.direccion END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.codigociu;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.telefono)>15 THEN SUBSTR(INFOCLIENTE.telefono,1,15) ELSE INFOCLIENTE.telefono END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN','NM', INFOITEMS_.cuenta,'', 3);
			MCTYPE.MC_____BASE______B:=0;

			IF(MCTYPE.MC_____FECHEMIS__B > MCTYPE.MC_____FECHA_____B) THEN
				MCTYPE.MC_____FECHEMIS__B :=  MCTYPE.MC_____FECHA_____B;
			END IF;

			IF(INFOITEMS_.VALOR_CREDT= 0)THEN
				IF(INFOITEMS_.VALOR_CREDT)THEN
					CONTINUE;
				END IF;
			END IF;

			IF(INFOITEMS_.cuenta = ANY (CUENTAS_IVA))THEN
				IF(INFOITEMS_.VALOR_CREDT>0) THEN
					MCTYPE.MC_____BASE______B:= INFOITEMS_.VALOR_CREDT/0.19;
				ELSE
					MCTYPE.MC_____BASE______B:= INFOITEMS_.VALOR_DEB/0.19;
				END IF;
			END IF;


			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN','NM', INFOITEMS_.cuenta,'', 4)='S')THEN

				MCTYPE.MC_____NUMDOCSOP_B := FACTURA_NM.DOCUMENTO;


			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_FIN', 'NM', INFOITEMS_.cuenta,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--numero de cuotas
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

 			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			raise notice 'NM ====>>>> %',FACTURA_NM.DOCUMENTO;
			SW:=con.sp_insert_table_mc_sl_fac_sel(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;

		END LOOP;

		raise notice '<<<<==== Termino ====>>>> %',FACTURA_NM.DOCUMENTO;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'FAC_NM') !='N' THEN
		raise notice 'Validacion ====>>>> %',CON.SP_VALIDACIONES(MCTYPE,'FAC_NM');
			UPDATE CON.SL_TRASLADO_FACTURAS_APOTEOSYS SET TRASLADO_FINTRA= 1 WHERE DOCUMENTO =FACTURA_NM.DOCUMENTO;
		END IF;

		SECUENCIA_INT:=1;

	END LOOP;

	SELECT into _respuesta respuesta
	FROM dblink('dbname=selectrik port=5432 host=localhost user=postgres password=bdversion17'::text, '
			select OPAV.SL_TRASLADO_FACTURAS_APOTEOSYS_UPDATE(1);
	'::text) as a(respuesta text);
	IF(_RESPUESTA = 'OK') THEN
		DELETE FROM  CON.SL_TRASLADO_FACTURAS_APOTEOSYS;
	END IF;
	delete from con.mc_sl_fac_sel  where MC_____DEBMONLOC_B= 0 and  MC_____CREMONLOC_B = 0;
	--TRUNCATE  CON.SL_TRASLADO_FACTURAS_APOTEOSYS;
RETURN _respuesta ;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_sl_facturacion_fintra_apoteosys()
  OWNER TO postgres;
