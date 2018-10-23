-- Function: con.interfaz_libranza_apoteosys()

-- DROP FUNCTION con.interfaz_libranza_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_libranza_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODOS LO NEGOCIOS DE LIBRANZA CREA EL ASIENTO CONTABLE
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2017-07-17
  *LAST_UPDATE:= 2017-07-18
  *DESCRIPCION DE CAMBIOS Y FECHA
  *1.fecha:2017-07-18 el asiento de libranza fue modificado a causa de la cxp de cliente
  ************************************************/

NEGOCIO_ RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
CUENTAS_DEF VARCHAR[] := '{13050941,28150901,27050940,23050941,28150909}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;

BEGIN
	/**SACAMOS EL LISTADO DE NEGOCIOS*/
	FOR NEGOCIO_ IN
		select
			neg.cod_neg,
			neg.cod_cli,
			neg.fecha_negocio,
			conv.agencia,
			neg.periodo,
			procesado_lib--,*
		from negocios neg
		inner join convenios conv on (conv.id_convenio = neg.id_convenio)
		INNER JOIN rel_unidadnegocio_convenios ruc ON (conv.id_convenio = ruc.id_convenio)
		INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
		where neg.estado_neg in('T','L') and uneg.id = '22'
		AND (procesado_lib = 'N' or procesado_lib is null)  -->campo nuevo crear
		AND cod_neg not in (select negocio_reestructuracion from rel_negocios_reestructuracion )
		AND cod_neg not in (select cod_neg from tem.negocios_facturacion_old)
		AND neg.periodo =REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')

--select con.interfaz_libranza_apoteosys()

	LOOP
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');---> CAMBIAR DE SECUENCIA

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'OPER';
		MCTYPE.MC_____CODIGO____CD_____B := 'LB';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN
			(select
				'cartera' as descr,
				num_doc_fen,
				fac.documento,
				fac.tipo_documento,
				fac.nit,
				valor_factura as valor_deb,
				0::numeric as valor_credt,
				fac.descripcion,
				f_desem::date as creation_date,
				fac.fecha_vencimiento,
				REPLACE(SUBSTRING(f_desem,1,7),'-','') as periodo
				,CUENTAS_DEF[1] as cuenta
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			where negasoc = NEGOCIO_.cod_neg
			and fac.reg_status = ''
			and fac.periodo != ''
			group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,valor_factura,fac.documento
			order by num_doc_fen::integer
			)union all
			(select
				'seguro' as descr,
				num_doc_fen,
				fac.documento,
				fac.tipo_documento,
				'8600284155' AS nit,
				--fac.nit,
				0::numeric as valor_deb,
				sum (valor_unitario) as valor_credt,
				fac.descripcion,
				f_desem::date as creation_date,
				fac.fecha_vencimiento,
				REPLACE(SUBSTRING(f_desem,1,7),'-','') as periodo
				,CUENTAS_DEF[2] as cuenta
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			where negasoc = NEGOCIO_.cod_neg
			and facdet.descripcion in ('SEGURO')
			and fac.reg_status = ''
			and facdet.reg_status = ''and valor_unitario > 0
			group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,fac.documento
			order by num_doc_fen::integer
			)union all
			(select
				'intereses' as descr,
				num_doc_fen,
				b.documento,
				fac.tipo_documento,
				fac.nit,
				0::numeric as valor_deb,
				valor_unitario as valor_credt,
				facdet.descripcion,
				f_desem::date as creation_date,
				fac.fecha_vencimiento,
				REPLACE(SUBSTRING(f_desem,1,7),'-','') as periodo
				,CUENTAS_DEF[3] as cuenta
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (facdet.documento = fac.documento and facdet.descripcion = 'INTERES')
			left  JOIN (SELECT CODNEG,
					       SUBSTRING(COD,1,2) AS PREFIJO,
					       COD AS DOCUMENTO,
					       LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00') AS CUOTA,
					       FECHA_DOC::DATE AS FECHA_VEN,
					       VALOR
					FROM ING_FENALCO WHERE REG_STATUS='' AND tipodoc='LI' --AND CODNEG='LB00445'
					ORDER BY
					COD,LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00')::INTEGER
				) B on (FAC.NEGASOC=B.CODNEG AND FAC.FECHA_VENCIMIENTO=B.FECHA_VEN)
			where negasoc = NEGOCIO_.cod_neg
			and fac.reg_status = ''
			and fac.periodo != ''
			order by num_doc_fen::integer
			)union all
			(select
				'cxp cliente ' as descr,
				'1' as num_doc_fen,
				cxp.documento,
				cxp.tipo_documento,
				cxp.proveedor as nit,
				0::numeric as valor_deb,
				vlr_neto as valor_credt,
				cxp.descripcion,
				f_desem::date as creation_date,
				f_desem::date as  fecha_vencimiento,
				REPLACE(SUBSTRING(f_desem,1,7),'-','') as periodo
				,CUENTAS_DEF[4] as cuenta
			from fin.cxp_doc cxp
			inner join negocios neg on (cxp.documento_relacionado = neg.cod_neg)
			where neg.cod_neg = NEGOCIO_.cod_neg
			and documento ilike 'LP%'
			and referencia_3 = 'TRANSFERENCIA'
			and tipo_referencia_3 = 'DESEM'
			and cxp.reg_status = ''
			and cxp.periodo != ''
			group by cxp.creation_date,cxp.documento,cxp.tipo_documento,cxp.proveedor,cxp.descripcion,cxp.periodo,vlr_neto,f_desem
			)union all
			(select
				'cxp cheque ' as descr,
				'1' as num_doc_fen,
				cxp.documento,
				cxp.tipo_documento,
				cxp.proveedor as nit,
				0::numeric as valor_deb,
				vlr_neto as valor_credt,
				cxp.descripcion,
				f_desem::date as creation_date,
				f_desem::date as  fecha_vencimiento,
				REPLACE(SUBSTRING(f_desem,1,7),'-','') as periodo
				,CUENTAS_DEF[4] as cuenta
			from fin.cxp_doc cxp
			inner join negocios neg on (cxp.documento_relacionado = neg.cod_neg)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=cxp.proveedor)
			where neg.cod_neg = NEGOCIO_.cod_neg
			and documento ilike 'LP%'
			and referencia_3 = 'CHEQUE'
			and tipo_referencia_3 = 'DESEM'
			and cxp.reg_status = ''
			and cxp.periodo != ''
			group by cxp.creation_date,cxp.documento,cxp.tipo_documento,cxp.proveedor,cxp.descripcion,cxp.periodo,vlr_neto,f_desem
			)UNION ALL
			(select
				'fianza' as descr,
				'1' as num_doc_fen,
				cxp.documento as documento,
				cxp.tipo_documento,
				--cxp.proveedor as nit,
				'9002207536' as nit,
				0::numeric as valor_deb,
				vlr_neto as valor_credt,
				cxp.descripcion,
				f_desem::date as creation_date,
				f_desem::date as  fecha_vencimiento,
				REPLACE(SUBSTRING(f_desem,1,7),'-','') as periodo
				,CUENTAS_DEF[5] as cuenta
			from fin.cxp_doc cxp
			inner join negocios neg on (cxp.documento_relacionado = neg.cod_neg)
			where neg.cod_neg = NEGOCIO_.cod_neg
			and documento ilike 'FZ%'
			and cxp.reg_status = ''
			and cxp.periodo != ''
			group by cxp.creation_date,cxp.documento,cxp.tipo_documento,cxp.proveedor,cxp.descripcion,cxp.periodo,vlr_neto,f_desem
			)
		LOOP

			/**BUSCAMOS LA INFORMACION DEL CLIENTE*/
			select INTO INFOCLIENTE
				(CASE
				WHEN tipo_doc ='CED' THEN 'CC'
				WHEN tipo_doc ='RIF' THEN 'CE'
				WHEN tipo_doc ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN GRAN_CONTRIBUYENTE ='N' AND AGENTE_RETENEDOR ='N' THEN 'RCOM'
				WHEN GRAN_CONTRIBUYENTE ='N' AND AGENTE_RETENEDOR ='S' THEN 'RCAU'
				WHEN GRAN_CONTRIBUYENTE ='S' AND AGENTE_RETENEDOR ='N' THEN 'GCON'
				WHEN GRAN_CONTRIBUYENTE ='S' AND AGENTE_RETENEDOR ='S' THEN 'GCAU'
				ELSE 'PNAL' END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				*
			from proveedor prov
			LEFT JOIN NIT D ON(D.CEDULA=prov.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			where nit = INFOITEMS_.nit;

			iF(INFOITEMS_.tipo_documento in ('FAP','FAC') AND CON.OBTENER_HOMOLOGACION_APOTEOSYS('LIBRANZA',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 6)='S')THEN
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
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('LIBRANZA', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('LIBRANZA', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := CASE WHEN CHAR_LENGTH(INFOITEMS_.NIT)>9 AND INFOCLIENTE.TIPO_DOC='NIT' THEN SUBSTR(INFOITEMS_.NIT,1,9) ELSE INFOITEMS_.NIT END;
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
			MCTYPE.MC_____NUMERO_OPER_B := NEGOCIO_.cod_neg;
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.tipo_doc;
			MCTYPE.TERCER_NOMBCORT__B := INFOCLIENTE.nombre_corto;
			MCTYPE.TERCER_NOMBEXTE__B := INFOCLIENTE.nombre;
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.apellidos;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.codigo;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.direccion)>64 THEN SUBSTR(INFOCLIENTE.direccion,1,64) ELSE INFOCLIENTE.direccion END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.codigociu;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.telefono)>15 THEN SUBSTR(INFOCLIENTE.telefono,1,15) ELSE INFOCLIENTE.telefono END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('LIBRANZA',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('LIBRANZA', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 4)='S')THEN
-- 				IF(INFOITEMS_.DESCR IN('fianza','cxp cheque ','cxp cliente '))THEN
-- 					MCTYPE.MC_____NUMDOCSOP_B := NEGOCIO_.cod_neg;--negocio
-- 				ELSE
					MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.documento;
-- 				END IF;

			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('LIBRANZA', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--numero de cuotas
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

 			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			raise notice 'SW %',SW||' '||NEGOCIO_.cod_neg;
			SW:=CON.SP_INSERT_TABLE_MC_LIBRANZA____(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'LIBRANZA') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then
			update negocios set procesado_lib = 'P' where cod_neg = NEGOCIO_.cod_neg;---> procesado_lib en P, para despues cambiar a S cuando pase las notas
		end if;

		SECUENCIA_INT:=1;

	END LOOP;
RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_libranza_apoteosys()
  OWNER TO postgres;
