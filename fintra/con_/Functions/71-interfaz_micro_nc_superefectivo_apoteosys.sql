-- Function: con.interfaz_micro_nc_superefectivo_apoteosys()

-- DROP FUNCTION con.interfaz_micro_nc_superefectivo_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_micro_nc_superefectivo_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODAS LAS NOTAS CREDITOS
  * DE SUPERFECTIVO Y CREA EL ASIENTO CONTABLE.
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2018-04-12
  *LAST_UPDATE:
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

NOTAS_ RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';

BEGIN

	/**SACAMOS EL LISTADO DE LAS NOTAS CREDITOS*/
	FOR NOTAS_ IN

		select
			proveedor,
			tipo_documento,
			cxp.documento,
			handle_code,
			vlr_neto,
			periodo,
			fecha_documento,
			fecha_vencimiento,
			 t.agencia,
 			t.documento_relacionado as negocio,
			descripcion ,
 			t.tipo_documento_rel,
 			cxp.documento_relacionado
		from
			fin.cxp_doc cxp
		inner join (
			select
				documento,
				documento_relacionado,
				con.agencia,
				tipo_documento_rel
			from
				fin.cxp_doc cxp
			inner join
				negocios neg on(neg.cod_neg=cxp.documento_relacionado)
			inner join
				convenios con on(con.id_convenio=neg.id_convenio)
			where
				tipo_documento='FAP' and
				substring(documento_relacionado,1,2)='MC'
			) t on(t.documento=cxp.documento_relacionado)
		where 	reg_status='' and
			tipo_documento='NC' and
			handle_code='SU' and
			periodo>='201801'--REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
			and cxp.documento not in (select factura_cxp from con.mc_cxp_procesadas_su where tipo_documento='NC')
		order by periodo

		--select con.interfaz_micro_nc_superefectivo_apoteosys()
		/**
		select * from con.mc_micro____ where MC_____CODIGO____TD_____B = 'CXPN' and MC_____CODIGO____CD_____B = 'NCSU' and procesado='R' order by MC_____NUMERO____B,MC_____SECUINTE__B
		select * from con.mc_micro____ where MC_____CODIGO____TD_____B = 'CXPN' and MC_____CODIGO____CD_____B = 'NCSU' and procesado='N' order by MC_____NUMERO____B,MC_____SECUINTE__B
		UPDATE con.mc_micro____ set procesado='S' where MC_____CODIGO____TD_____B = 'CXPN' and MC_____CODIGO____CD_____B = 'NCSU'
		and procesado='R' and MC_____NUMERO____B not in(613237,613649,614148)
		delete from con.mc_micro____ where MC_____CODIGO____TD_____B = 'CXPN' and MC_____CODIGO____CD_____B = 'NCSU' and MC_____NUMERO____PERIOD_B=4 procesado='S'
		delete from con.mc_cxp_procesadas_su
		select * from con.mc_cxp_procesadas_su
		*/

	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_CXP_APOTEOSYS');

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'CXPN';
		MCTYPE.MC_____CODIGO____CD_____B := 'NCSU';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		FOR INFOITEMS_ IN

			select
				tipo_documento,
				documento,
				cmc.cuenta,
				vlr_neto as valor_deb,
				0 as valor_credt,
				proveedor as nit,
				descripcion
			from
				fin.cxp_doc cxp
			inner join
				con.cmc_doc cmc on(cmc.tipodoc=cxp.tipo_documento and cmc.cmc=cxp.handle_code)
			where
				tipo_documento=NOTAS_.tipo_documento and
				documento=NOTAS_.documento
			union all
			select
				tipo_documento,
				documento,
				codigo_cuenta as cuenta,
				0 as valor_deb,
				vlr as valor_credt,
				proveedor as nit,
				descripcion
			from
				fin.cxp_items_doc
			where
				tipo_documento=NOTAS_.tipo_documento and
				documento=NOTAS_.documento

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

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(notas_.fecha_documento,1,7),'-','') = notas_.periodo THEN notas_.fecha_documento::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(notas_.periodo,1,4), SUBSTRING(notas_.periodo,5,2)::INT)::DATE END;

			iF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER',notas_.tipo_documento, INFOITEMS_.cuenta,notas_.agencia, 6)='S')THEN
				MCTYPE.MC_____FECHVENC__B = notas_.fecha_vencimiento; --fecha vencimiento
					if (notas_.fecha_vencimiento < notas_.fecha_documento)then /** se valida si la fecha de vencimeinto es menor a la de creacion*/
						MCTYPE.MC_____FECHEMIS__B = notas_.fecha_vencimiento; --fecha creacion
					else
						MCTYPE.MC_____FECHEMIS__B = notas_.fecha_documento; --fecha creacion
					end if;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;

			------------------------------------------------------------------------------------------------------------------------------------------------------------
			MCTYPE.MC_____FECHA_____B := CASE WHEN (notas_.fecha_documento::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(notas_.fecha_documento,1,7),'-','') = notas_.periodo)  THEN notas_.fecha_documento::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := notas_.negocio;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( notas_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( notas_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER', notas_.tipo_documento, INFOITEMS_.cuenta,notas_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER', notas_.tipo_documento, INFOITEMS_.cuenta,notas_.agencia, 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := CASE WHEN CHAR_LENGTH(INFOITEMS_.nit)>9 AND INFOCLIENTE.TIPO_DOC='NIT' THEN SUBSTR(INFOITEMS_.nit,1,9) ELSE INFOITEMS_.nit END;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := INFOITEMS_.descripcion;
			MCTYPE.MC_____FECHORCRE_B := FECHADOC_::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := FECHADOC_::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER',notas_.tipo_documento, INFOITEMS_.cuenta,notas_.agencia, 3);

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER', notas_.tipo_documento, INFOITEMS_.cuenta,notas_.agencia, 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := notas_.documento_relacionado;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER', notas_.tipo_documento, INFOITEMS_.cuenta,notas_.agencia, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--numero de cuotas
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

 			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			raise notice 'SW %',SW||' '||notas_.negocio;
			raise notice 'INFOITEMS_ %',INFOITEMS_;
			raise notice 'MCTYPE %',MCTYPE;
			SW:=CON.SP_INSERT_TABLE_MC_MICRO____(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;
			------------------------------------------------------------------------------------------------------------------------------------------------------------

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'MICROCREDITO') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		raise notice 'Tipo Documento: %', NOTAS_.tipo_documento;
		raise notice 'Documento: %', NOTAS_.documento;
		raise notice 'Periodo: %', NOTAS_.periodo;

		if(SW = 'S')then
			insert into con.mc_cxp_procesadas_su(tipo_documento,factura_cxp,periodo,procesado_cxp) values(NOTAS_.tipo_documento,NOTAS_.documento,NOTAS_.periodo,'S');
		end if;

	END LOOP;

	RETURN 'OK';

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_micro_nc_superefectivo_apoteosys()
  OWNER TO postgres;
