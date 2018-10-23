-- Function: con.interfaz_educativo_fintra()

-- DROP FUNCTION con.interfaz_educativo_fintra();

CREATE OR REPLACE FUNCTION con.interfaz_educativo_fintra()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODOS LO NEGOCIOS EDUCATIVOS CON AVALES INCLUIDOS.
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-08-03
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

NEGOCIO_ RECORD;
INFOITEMS_ RECORD;
--INFOCLIENTE RECORD;
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;

BEGIN
	/**SACAMOS EL LISTADO DE NEGOCIOS*/
	FOR NEGOCIO_ IN
		SELECT  NEG.COD_NEG,
			NEG.COD_CLI,
			NEG.FECHA_NEGOCIO,
			CONV.AGENCIA,
			UNEG.DESCRIPCION AS UNIDAD_NEG,
			REPLACE(SUBSTRING(NEG.F_DESEM,1,7),'-','') AS PERIODO_DESEM,
			ESTADO_NEG
		FROM NEGOCIOS NEG
		INNER JOIN CONVENIOS CONV ON (CONV.ID_CONVENIO = NEG.ID_CONVENIO)
		INNER JOIN REL_UNIDADNEGOCIO_CONVENIOS RUC ON (CONV.ID_CONVENIO = RUC.ID_CONVENIO)
		INNER JOIN UNIDAD_NEGOCIO UNEG ON (UNEG.ID = RUC.ID_UNID_NEGOCIO)
		WHERE NEG.ESTADO_NEG IN ('T') AND UNEG.ID = '31'
		AND PROCESADO_MC = 'N'
		AND NEG.FINANCIA_AVAL = FALSE
		AND NEG.NEGOCIO_REL = ''
		AND NEG.COD_NEG NOT IN (SELECT NEGOCIO_REESTRUCTURACION FROM REL_NEGOCIOS_REESTRUCTURACION)
		--AND REPLACE(SUBSTRING(NEG.F_DESEM,1,7),'-','')=REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
		--AND REPLACE(SUBSTRING(NEG.F_DESEM,1,7),'-','') = '201808'
		AND REPLACE(SUBSTRING(NEG.PERIODO,1,7),'-','') = '201808'
		--AND NEG.COD_NEG='FE00029'

	LOOP
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');
		raise notice 'paso: %',NEGOCIO_.cod_neg;

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
		MCTYPE.MC_____CODIGO____TD_____B := 'OPER' ;
		MCTYPE.MC_____CODIGO____CD_____B := substring(NEGOCIO_.cod_neg,1,2);
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ; --SECUENCIA GENERAL
		SECUENCIA_INT:=1;


		/**BUSCAMOS LA COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN
			(select
				codigo_cuenta_contable  AS CUENTA,
				fac.documento,
				fac.tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE FAC.NIT END AS NIT,
				--fac.nit,
				ROUND(sum(valor_unitario))::NUMERIC(17,2)  as valor_deb,
				0::numeric as valor_credt,
				'CARTERA' AS descripcion,
				f_desem::date as creation_date,
				fac.fecha_vencimiento,
				replace(substring(f_desem,1,7),'-','') as periodo,
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				else 'RSCP'
				END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				D.NOMBRE,
				D.DIRECCION,
				D.TELEFONO
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			left join NIT D ON(D.CEDULA=fac.nit)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=FAC.NIT)
			where negasoc = NEGOCIO_.cod_neg
			and fac.reg_status = ''
			and facdet.reg_status = ''
			and valor_unitario > 0
			--and fac.descripcion not in ('CXC AVAL')
			group by facdet.codigo_cuenta_contable, num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.documento,HT.NIT_APOTEOSYS
			,tipo_iden, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
			order by num_doc_fen::integer
			)
			union all
			(SELECT 	CUENTA,
			COD AS DOCUMENTO,
			ING.TIPODOC,
			CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE NEG.COD_CLI END AS NIT,
			0::NUMERIC AS VALOR_DEB,
			VALOR AS VALOR_CREDT,
			case when ING.TIPODOC= 'IF' THEN 'INTERESES' ELSE 'CUOTA-ADMINISTRACION' END AS descripcion,
			F_DESEM::DATE AS CREATION_DATE,
			FECHA_DOC AS FECHA_VENCIMIENTO,
			REPLACE(SUBSTRING(F_DESEM,1,7),'-','') AS PERIODO,
			(CASE
			WHEN TIPO_IDEN ='CED' THEN 'CC'
			WHEN TIPO_IDEN ='RIF' THEN 'CE'
			WHEN TIPO_IDEN ='NIT' THEN 'NIT' ELSE
			'CC' END) AS TIPO_DOC,
			(CASE
			WHEN TIPO_IDEN IN  ('RIF','NIT') THEN 'RCOM'  -->REGIMEN COMUN
			WHEN TIPO_IDEN IN  ('CED')  THEN 'RSCP'
			ELSE 'RSCP'
			END) AS CODIGO,
			(CASE
			WHEN C.CODIGO_DANE2!='' THEN C.CODIGO_DANE2
			ELSE '08001' END) AS CODIGOCIU,
			(N.NOMBRE1||' '||N.NOMBRE2) AS NOMBRE_CORTO,
			(N.APELLIDO1||' '||N.APELLIDO2) AS APELLIDOS,
			N.NOMBRE,
			N.DIRECCION,
			N.TELEFONO
			FROM ING_FENALCO ING
			INNER JOIN CON.CMC_DOC CMC ON  CMC.CMC=ING.CMC AND CMC.TIPODOC=ING.TIPODOC
			INNER JOIN NEGOCIOS NEG ON NEG.COD_NEG=ING.CODNEG
			LEFT JOIN NIT N ON(N.CEDULA=NEG.COD_CLI)
			LEFT JOIN CIUDAD C ON(C.CODCIU=N.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=NEG.COD_CLI)
			WHERE CODNEG =  NEGOCIO_.cod_neg
			ORDER BY ING.TIPODOC, CUOTA
			)
			union all
			(SELECT
				codigo_cuenta AS CUENTA,
				cxp_doc.documento,
				cxp_doc.tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE substring(cxp_doc.proveedor,1,9) END AS NIT,
				--proveedor,
				0::numeric as valor_deb,
				vlr_neto as valor_credt,
				cxp_doc.descripcion,
				f_desem::date as creation_date,
				f_desem::DATE AS fecha_vencimiento,
				replace(substring(f_desem,1,7),'-','') as periodo,
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				else 'RSCP'
				END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				D.NOMBRE,
				D.DIRECCION,
				D.TELEFONO
			from fin.cxp_doc
			inner join fin.cxp_items_doc cxi on cxi.documento=cxp_doc.documento
			inner join negocios neg on ( neg.cod_neg = cxp_doc.documento_relacionado)
			left join NIT D ON(D.CEDULA=cxp_doc.PROVEEDOR)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=cxp_doc.proveedor)
			WHERE documento_relacionado in (NEGOCIO_.cod_neg)
			and vlr_neto > 0
			and cxp_doc.reg_status = ''
			and cxp_doc.proveedor not in ('8904800244','8901009858')
			and handle_code not in ('BA','AV')
			and substring (cxp_doc.documento,1,2) in ('PM')
			)union all
			(SELECT
				codigo_cuenta AS CUENTA,
				cxp_doc.documento,
				cxp_doc.tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE cxp_doc.proveedor END AS NIT,
				--proveedor,
				0::numeric as valor_deb,
				vlr_neto as valor_credt,
				cxp_doc.descripcion,
				f_desem::date as creation_date,
				f_desem::DATE AS fecha_vencimiento,
				replace(substring(f_desem,1,7),'-','') as periodo,
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				else 'RSCP'
				END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				D.NOMBRE,
				D.DIRECCION,
				D.TELEFONO
			from fin.cxp_doc
			inner join fin.cxp_items_doc cxi on cxi.documento=cxp_doc.documento
			inner join negocios neg on ( neg.cod_neg = cxp_doc.documento_relacionado)
			left join NIT D ON(D.CEDULA=cxp_doc.PROVEEDOR)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=cxp_doc.proveedor)
			WHERE documento_relacionado in (NEGOCIO_.cod_neg)
			and vlr_neto > 0
			and cxp_doc.reg_status = ''
			and handle_code in ('AV')
			and substring (cxp_doc.documento,1,2) in ('PM')
			)
		LOOP


			IF(INFOITEMS_.tipo_documento in ('FAC','FAP','NEG','IF','CM') AND CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO_FINT',INFOITEMS_.tipo_documento, INFOITEMS_.CUENTA, NEGOCIO_.agencia, 6)='S')THEN
				MCTYPE.MC_____FECHVENC__B = INFOITEMS_.fecha_vencimiento; --fecha vencimiento
				if (INFOITEMS_.fecha_vencimiento < INFOITEMS_.creation_date)then /** se valida si la fecha de vencimeinto es menor a la de creacion*/
					MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.fecha_vencimiento; --fecha creacion
				else
					MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.creation_date; --fecha creacion
				end if;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(INFOITEMS_.creation_date,1,7),'-','') = INFOITEMS_.periodo THEN INFOITEMS_.creation_date::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(INFOITEMS_.periodo,1,4), SUBSTRING(INFOITEMS_.periodo,5,2)::INT)::DATE END;
			MCTYPE.MC_____FECHA_____B := FECHADOC_;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := NEGOCIO_.cod_neg;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( INFOITEMS_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( INFOITEMS_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO_FINT', INFOITEMS_.tipo_documento, INFOITEMS_.CUENTA, NEGOCIO_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO_FINT', INFOITEMS_.tipo_documento, INFOITEMS_.CUENTA, NEGOCIO_.agencia, 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := INFOITEMS_.NIT;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := INFOITEMS_.descripcion || ' '||NEGOCIO_.UNIDAD_NEG;
			MCTYPE.MC_____FECHORCRE_B := INFOITEMS_.creation_date::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := INFOITEMS_.creation_date::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOITEMS_.tipo_doc;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTR(INFOITEMS_.nombre_corto,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTR (INFOITEMS_.nombre,1,64);
			MCTYPE.TERCER_APELLIDOS_B := SUBSTR(INFOITEMS_.apellidos,1,32);
			MCTYPE.TERCER_CODIGO____TT_____B := INFOITEMS_.codigo;
			MCTYPE.TERCER_DIRECCION_B := SUBSTR(INFOITEMS_.direccion,1,64);
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOITEMS_.codigociu;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOITEMS_.telefono)>15 THEN SUBSTR(INFOITEMS_.telefono,1,15) ELSE INFOITEMS_.telefono END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO_FINT',INFOITEMS_.tipo_documento, INFOITEMS_.CUENTA, NEGOCIO_.agencia, 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO_FINT', INFOITEMS_.tipo_documento, INFOITEMS_.CUENTA, NEGOCIO_.agencia, 4)='S')THEN

				MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.documento;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO_FINT', INFOITEMS_.tipo_documento, INFOITEMS_.CUENTA, NEGOCIO_.agencia, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;

			--raise notice 'valor_deb: % valor_credt: %',INFOITEMS_.valor_deb,INFOITEMS_.valor_credt;
		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'EDUCATIVO') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then
			update negocios set procesado_mc = 'S' where cod_neg = NEGOCIO_.cod_neg;
		end if;

	END LOOP;

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_educativo_fintra()
  OWNER TO postgres;
