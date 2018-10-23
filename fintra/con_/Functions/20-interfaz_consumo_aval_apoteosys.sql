-- Function: con.interfaz_consumo_aval_apoteosys(character varying, character varying, character varying, character varying, date)

-- DROP FUNCTION con.interfaz_consumo_aval_apoteosys(character varying, character varying, character varying, character varying, date);

CREATE OR REPLACE FUNCTION con.interfaz_consumo_aval_apoteosys(negocio_padre character varying, secuencia_g character varying, tipo_doc_ap character varying, clase_documento character varying, fecha_padre date)
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODOS LO NEGOCIOS AVALES CONSUMO.
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-08-10
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

NEGOCIO_ RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
CUENTAS_ VARCHAR[] := '{13050902,27050901,28150602,13050521,I010010014210}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;

BEGIN
	/**SACAMOS EL LISTADO DE NEGOCIOS*/
	FOR NEGOCIO_ IN
		select  neg.financia_aval,
			neg.cod_neg,
			neg.negocio_rel as padre,
			neg.cod_cli,
			neg.fecha_negocio,
			sola.renovacion,
			conv.agencia
		from negocios neg
		inner join convenios conv on (conv.id_convenio = neg.id_convenio)
		INNER JOIN rel_unidadnegocio_convenios ruc ON (conv.id_convenio = ruc.id_convenio)
		INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
		inner join solicitud_aval sola on (sola.cod_neg = neg.cod_neg)
		where neg.estado_neg in ('T','A') and uneg.id = '14'
		and procesado_mc = 'N'
		and neg.financia_aval = false
		and neg.negocio_rel != ''
		AND neg.cod_neg not in (select negocio_reestructuracion from rel_negocios_reestructuracion)
		--and neg.periodo >= '201701'
		and neg.negocio_rel = negocio_padre
	LOOP
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');
		raise notice 'paso: %',NEGOCIO_.cod_neg;
		/**BUSCAMOS LA INFORMACION DEL CLIENTE*/
		select INTO INFOCLIENTE
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
			*
		from  NIT D --ON(D.CEDULA=prov.NIT)
		LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
		where cedula = NEGOCIO_.cod_cli;

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
		MCTYPE.MC_____CODIGO____TD_____B := 'OPER' ;
		MCTYPE.MC_____CODIGO____CD_____B := substring(NEGOCIO_.cod_neg,1,2)||'V';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ; --SECUENCIA GENERAL

		/**BUSCAMOS LA COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN
			SELECT * FROM (
			(select
				'cartera' as descr,
				num_doc_fen,
				fac.documento,
				fac.tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE fac.nit END AS nit,
				--fac.nit,
				sum (valor_unitario) as valor_deb,
				0::numeric as valor_credt,
				'CARTERA FENALCO' AS descripcion,
				fecha_padre::date as creation_date,
				fecha_padre::DATE AS fecha_vencimiento,
				replace(substring(fecha_padre,1,7),'-','') as periodo,
				case when (substring(NEGOCIO_.cod_neg,1,2) = 'FA')then CUENTAS_[1] when (substring(NEGOCIO_.cod_neg,1,2) = 'FB')then CUENTAS_[4] end AS cuenta,
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
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,D.NOMBRE,D.DIRECCION,D.TELEFONO
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			left join NIT D ON(D.CEDULA=fac.nit)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=fac.nit)
			where negasoc = NEGOCIO_.cod_neg
			and fac.reg_status = ''
			and facdet.reg_status = ''
			and valor_unitario <> 0
			group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.documento,HT.NIT_APOTEOSYS
			,tipo_iden, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
			order by num_doc_fen::integer
			)
			union all
			(select
				'interes' as descr,
				num_doc_fen,
				b.documento,
				'NEG' as tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE fac.nit END AS nit,
				--fac.nit,
				0::numeric as valor_deb,
				sum (valor_unitario) as valor_credt,
				fac.descripcion,
				fecha_padre::date as creation_date,
				fecha_padre::DATE AS fecha_vencimiento,
				replace(substring(fecha_padre,1,7),'-','') as periodo,
				CUENTAS_[2] AS cuenta,
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
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,D.NOMBRE,D.DIRECCION,D.TELEFONO
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			INNER  JOIN (SELECT CODNEG,
						       SUBSTRING(COD,1,2) AS PREFIJO,
						       COD AS DOCUMENTO,
						       LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00') AS CUOTA,
						       FECHA_DOC::DATE AS FECHA_VEN,
						       VALOR
						FROM ING_FENALCO WHERE TIPODOC='IF'
						ORDER BY
						COD,LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00')::INTEGER
					) B ON (FAC.NEGASOC=B.CODNEG AND LPAD(SUBSTRING(FAC.DOCUMENTO,8,2),2,'00') =B.CUOTA)
			left join NIT D ON(D.CEDULA=fac.nit)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=fac.nit)
			where negasoc = NEGOCIO_.cod_neg
			and facdet.descripcion in ('INTERESES')
			and fac.reg_status = ''
			and facdet.reg_status = ''and valor_unitario <> 0
			group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,b.documento,HT.NIT_APOTEOSYS
			,tipo_iden, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
			order by num_doc_fen::integer
			)
			union all
			(SELECT
				'fenalco' as descr,
				documento as doc,
				documento as documento,
				tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE proveedor END AS proveedor,
				--proveedor,
				0::numeric as valor_deb,
				vlr_neto as valor_credt,
				descripcion,
			 	fecha_padre::date as creation_date,
			 	fecha_padre::DATE AS fecha_vencimiento,
			 	replace(substring(fecha_padre,1,7),'-','') as periodo,
			 	CUENTAS_[3] AS cuenta,
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
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,D.NOMBRE,D.DIRECCION,D.TELEFONO
			from fin.cxp_doc
			inner join negocios neg on ( neg.cod_neg = cxp_doc.documento_relacionado)
			left join NIT D ON(D.CEDULA=proveedor)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=proveedor)
			WHERE documento_relacionado in (NEGOCIO_.cod_neg)
			and vlr_neto <> 0
			and cxp_doc.reg_status = ''
			and substring (documento,1,2) in ('PM','PB')
			)
			union all
			(select
				'remesa' as descr,
				num_doc_fen,
				fac.documento,
				'NEG' as tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE fac.nit END AS nit,
				--fac.nit,
				0::numeric as valor_deb,
				sum (valor_unitario) as valor_credt,
				fac.descripcion,
				fecha_padre::date as creation_date,
				fecha_padre::DATE AS fecha_vencimiento,
				replace(substring(fecha_padre,1,7),'-','') as periodo,
				CUENTAS_[5] AS cuenta,
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
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,D.NOMBRE,D.DIRECCION,D.TELEFONO
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			left join NIT D ON(D.CEDULA=fac.nit)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=fac.nit)
			where negasoc = NEGOCIO_.cod_neg
			and facdet.descripcion in ('REMESA')
			and fac.reg_status = ''
			and facdet.reg_status = ''and valor_unitario <> 0
			group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,fac.documento,HT.NIT_APOTEOSYS
			,tipo_iden, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
			order by num_doc_fen::integer
			)
			) AS A WHERE SUBSTR(A.DOCUMENTO,1,2)!='ND'
		LOOP
			IF(INFOITEMS_.tipo_documento in ('FAC','FAP','NEG') AND CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 6)='S')THEN
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
			MCTYPE.MC_____FECHA_____B := CASE WHEN (INFOITEMS_.creation_date::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(INFOITEMS_.creation_date,1,7),'-','') = INFOITEMS_.periodo)  THEN INFOITEMS_.creation_date::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := NEGOCIO_.cod_neg;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( INFOITEMS_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( INFOITEMS_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta, NEGOCIO_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta, NEGOCIO_.agencia, 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := INFOITEMS_.nit;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := INFOITEMS_.descripcion;
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta, NEGOCIO_.agencia, 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 4)='S')THEN
					MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.documento;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta, NEGOCIO_.agencia, 5)::INT=1)THEN
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
		IF CON.SP_VALIDACIONES(MCTYPE,'CONSUMO') ='N' THEN
			SW = 'N';
			--raise notice 'paso: %',SW;
			DELETE FROM CON.MC_FENALCO____ WHERE MC_____NUMERO____B = secuencia_G AND MC_____CODIGO____TD_____B = tipo_doc_ap  AND MC_____CODIGO____CD_____B = clase_documento;
			CONTINUE;
		END IF;
		--raise notice 'paso:2 %',SW;
		raise notice 'MCTYPE:2 %',MCTYPE;
		if(SW = 'S')then
			update negocios set procesado_mc = 'S' where cod_neg = NEGOCIO_.cod_neg;
		end if;

		SECUENCIA_INT:=1;

	END LOOP;
-- 	if(SW = 'N')then
-- 		DELETE FROM CON.MC_FENALCO____ WHERE MC_____NUMERO____B = secuencia_G AND MC_____CODIGO____TD_____B = tipo_doc_ap  AND MC_____CODIGO____CD_____B = clase_documento;
-- 	end if;
RETURN SW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_consumo_aval_apoteosys(character varying, character varying, character varying, character varying, date)
  OWNER TO postgres;
