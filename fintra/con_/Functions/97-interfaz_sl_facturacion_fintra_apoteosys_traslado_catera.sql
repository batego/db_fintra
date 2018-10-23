-- Function: con.interfaz_sl_facturacion_fintra_apoteosys_traslado_catera(character varying)

-- DROP FUNCTION con.interfaz_sl_facturacion_fintra_apoteosys_traslado_catera(character varying);

CREATE OR REPLACE FUNCTION con.interfaz_sl_facturacion_fintra_apoteosys_traslado_catera(nm_ character varying)
  RETURNS text AS
$BODY$


DECLARE

 /************************************************
  *DESCRIPCION:
  *AUTOR		:=		@WSIADO
  *FECHA CREACION	:=		2017-10-17
  *LAST_UPDATE		:=	 	2017-10-17
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

_FAC_NM RECORD;
_S0 RECORD;
FACTURA_NM RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
--CUENTAS_DEF VARCHAR[] := '{13050941,28150901,27050940,23050941,28150909}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;

BEGIN


	--SE INSERTA EN UN RECORD CON LA NM CON DATOS NECESARIO PARA BUSCAR LA S0 QUE CORRESPONDE A ESTA.
	select into _FAC_NM
		referencia_1 ,
		descripcion ,
		valor_factura,
		numero_nc
	from CON.FACTURA where documento = nm_;

	raise notice 'NM ======>>>> %',_FAC_NM;



	SELECT INTO SECUENCIA_GEN   NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');

	MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
	MCTYPE.MC_____CODIGO____TD_____B := 'CXCN';
	MCTYPE.MC_____CODIGO____CD_____B := 'PMFN';
	MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL




	/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN

			select
				fac.fecha_factura ,
				fac.fecha_vencimiento ,
				fac.periodo,
				fac.nit  ,
				fac.referencia_1 as id_solicitud,
				ofe.centro_costo_ingreso AS centro_costos_ingreso,
				ofe.centro_costo_gasto AS centro_costos_gastos,
				fac.descripcion,
				cpd.tipodoc AS TIPO_DOCUMENTO,
				cpd.CUENTA,
				cpd.valor_debito  as valor_deb,
				cpd.valor_credito as valor_credt,
				nm_ as documento
			from 			CON.FACTURA 		AS FAC
			INNER JOIN  		(


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
								B.DESCRIPCION
							from opav.sl_traslado_facturas_apoteosys AS A
							INNER JOIN OPAV.OFERTAS AS B ON (A.ID_SOLICITUD = B.ID_SOLICITUD)
							where traslado_fintra ='''';'
							::text) as a(
									id numeric,
									id_solicitud character varying,
									centro_costo_ingreso character varying,
									centro_costo_gasto character varying,
									documento character varying,
									traslado_selectrik character varying,
									traslado_fintra character varying,
									descripcion character varying)

			)
									AS OFE	ON (FAC.REFERENCIA_1 = OFE.ID_SOLICITUD AND OFE.DOCUMENTO=NM_)
			INNER JOIN		CON.COMPROBANTE 	AS CP	ON (FAC.DOCUMENTO    = CP.NUMDOC)
			INNER JOIN 		CON.COMPRODET  		AS CPD  ON (CP.NUMDOC = CPD.NUMDOC)
			where
			substring(FAC.documento,1,2) 	= 	'S0'
			AND FAC.referencia_1 		=	_FAC_NM.referencia_1
			AND FAC.descripcion 		= 	_FAC_NM.descripcion
			AND FAC.valor_factura		=	_FAC_NM.valor_factura
			AND CPD.CUENTA = '13050708'
			UNION ALL(

			select
					fac.fecha_factura ,
					fac.fecha_vencimiento ,
					fac.periodo,
					fac.nit  ,
					fac.referencia_1 as id_solicitud,
					ofe.centro_costo_ingreso AS centro_costos_ingreso,
					ofe.centro_costo_gasto AS centro_costos_gastos,
					fac.descripcion,
					INGD.tipo_doc AS TIPO_DOCUMENTO,
					INGD.CUENTA,
					0 as valor_deb,
					INGD.valor_ingreso as valor_credt,
					nm_ as documento
				from 			CON.FACTURA 		AS FAC
				INNER JOIN  		(


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
								B.DESCRIPCION
							from opav.sl_traslado_facturas_apoteosys AS A
							INNER JOIN OPAV.OFERTAS AS B ON (A.ID_SOLICITUD = B.ID_SOLICITUD)
							where traslado_fintra ='''';'
							::text) as a(
									id numeric,
									id_solicitud character varying,
									centro_costo_ingreso character varying,
									centro_costo_gasto character varying,
									documento character varying,
									traslado_selectrik character varying,
									traslado_fintra character varying,
									descripcion character varying)

			)
										AS OFE	ON (FAC.REFERENCIA_1 = OFE.ID_SOLICITUD AND OFE.DOCUMENTO=NM_)
				INNER JOIN 		CON.INGRESO 		AS ING	ON (FAC.NUMERO_NC = ING.NUM_INGRESO)
				INNER JOIN		CON.INGRESO_DETALLE	AS INGD ON (ING.NUM_INGRESO = INGD.NUM_INGRESO)
				WHERE
					FAC.DOCUMENTO = nm_
					AND INGD.CUENTA = '13050701')


		LOOP
			raise notice 'INFOITEMS_======>>>> %',INFOITEMS_;

			iF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_SEL','NM', INFOITEMS_.cuenta,'', 6)='S')THEN
				MCTYPE.MC_____FECHVENC__B = INFOITEMS_.FECHA_VENCIMIENTO; --fecha vencimiento
					if (INFOITEMS_.fecha_vencimiento < INFOITEMS_.FECHA_FACTURA)then /** se valida si la fecha de vencimeinto es menor a la de creacion*/
						MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.FECHA_VENCIMIENTO; --fecha creacion
					else
						MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.FECHA_FACTURA; --fecha creacion
					end if;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(INFOITEMS_.FECHA_FACTURA,1,7),'-','') = INFOITEMS_.periodo THEN INFOITEMS_.FECHA_FACTURA::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(INFOITEMS_.periodo,1,4), SUBSTRING(INFOITEMS_.periodo,5,2)::INT)::DATE END;
			MCTYPE.MC_____FECHA_____B := CASE WHEN (INFOITEMS_.FECHA_FACTURA::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(INFOITEMS_.FECHA_FACTURA,1,7),'-','') = INFOITEMS_.PERIODO)  THEN INFOITEMS_.FECHA_FACTURA::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := INFOITEMS_.DOCUMENTO;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( INFOITEMS_.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( INFOITEMS_.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_SEL', 'NM', INFOITEMS_.cuenta,'', 1);
			MCTYPE.MC_____CODIGO____CU_____B := INFOITEMS_.CENTRO_COSTOS_INGRESO;
			MCTYPE.MC_____IDENTIFIC_TERCER_B := INFOITEMS_.nit;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := '';--INFOITEMS_.descripcion;
			MCTYPE.MC_____FECHORCRE_B := INFOITEMS_.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := INFOITEMS_.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';

			-- MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.tipo_doc;
-- 			MCTYPE.TERCER_NOMBCORT__B := INFOCLIENTE.nombre_corto;
-- 			MCTYPE.TERCER_NOMBEXTE__B := INFOCLIENTE.nombre;
-- 			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.apellidos;
-- 			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.codigo;
-- 			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.direccion)>64 THEN SUBSTR(INFOCLIENTE.direccion,1,64) ELSE INFOCLIENTE.direccion END;
-- 			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.codigociu;
-- 			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.telefono)>15 THEN SUBSTR(INFOCLIENTE.telefono,1,15) ELSE INFOCLIENTE.telefono END;
-- 			MCTYPE.TERCER_TIPOGIRO__B := 1;
-- 			MCTYPE.TERCER_CODIGO____EF_____B := '';
-- 			MCTYPE.TERCER_SUCURSAL__B := '';
-- 			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_SEL','NM', INFOITEMS_.cuenta,'', 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_SEL','NM', INFOITEMS_.cuenta,'', 4)='S')THEN

				MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.DOCUMENTO;


			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('FACT_SEL', 'NM', INFOITEMS_.cuenta,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--numero de cuotas
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

 			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			raise notice 'NM ====>>>> %',INFOITEMS_.DOCUMENTO;
			SW:=con.sp_insert_table_mc_sl_fac_sel(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;


		END LOOP;


		raise notice '<<<<==== Termino ====>>>> %',nm_;
		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES_SEL(MCTYPE,'FAC_NM') ='N' THEN
			SW = 'S';
		END IF;



		SECUENCIA_INT:=1;

RETURN SW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_sl_facturacion_fintra_apoteosys_traslado_catera(character varying)
  OWNER TO postgres;
