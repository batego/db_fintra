-- Function: con.interfaz_micro_eg_efecty_apoteosys()

-- DROP FUNCTION con.interfaz_micro_eg_efecty_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_micro_eg_efecty_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODAS LAS NOTAS CREDITOS
  * DE EFECTY Y CREA EL ASIENTO CONTABLE.
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2018-04-18
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
			eg.dstrct,
			eg.branch_code,
			eg.bank_account_no,
			eg.document_no,
			eg.printer_date as fecha_documento,
			eg.periodo
		from
			egreso eg
		INNER JOIN
			egresodet egd on(egd.branch_code=eg.branch_code and egd.bank_account_no=eg.bank_account_no and egd.document_no=eg.document_no)
		where
			eg.reg_status='' and
			eg.payment_name ='EFECTIVO LIMITADA' and
			eg.periodo>='201701'--replace(substring(current_date,1,7),'-','')
			and egd.procesado='N'
		group by
			eg.dstrct,
			eg.branch_code,
			eg.bank_account_no,
			eg.document_no,
			eg.printer_date,
			eg.periodo
		order by
			eg.periodo

		--select con.interfaz_micro_eg_efecty_apoteosys()
		/**
		select * from con.mc_micro____ where MC_____CODIGO____TD_____B = 'CXPN' and MC_____CODIGO____CD_____B = 'NCSU' and
		procesado='R' and mc_____numero____b in(614772,614776);
		update con.mc_micro____ set procesado='W' where MC_____CODIGO____TD_____B = 'CXPN' and MC_____CODIGO____CD_____B = 'NCSU' and
		procesado='R' and mc_____numero____b not in(614772,614776);
		delete from con.mc_micro____ where MC_____CODIGO____TD_____B = 'CXPN' and MC_____CODIGO____CD_____B = 'NCEF' and procesado='N';
		*/

	loop

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_CXP_APOTEOSYS');

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'CXPN';
		MCTYPE.MC_____CODIGO____CD_____B := 'NCSU';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		FOR INFOITEMS_ IN

			select
				eg.dstrct,
				eg.branch_code,
				eg.bank_account_no,
				'NC' AS tipo_documento,
				(select b.codigo_cuenta from banco b where b.branch_code=eg.branch_code and b.bank_account_no=eg.bank_account_no) as cuenta,
				eg.document_no as doc_soporte,
				0 as valor_deb,
				sum(egd.vlr) as valor_credt,
				eg.nit,
				con.agencia,
				printer_date as fecha_documento,
				printer_date as fecha_vencimiento,
				payment_name as descripcion
			FROM
				egreso eg
			INNER JOIN
				egresodet egd on(egd.branch_code=eg.branch_code and egd.bank_account_no=eg.bank_account_no and egd.document_no=eg.document_no)
			inner join
				fin.cxp_doc cxp on(cxp.tipo_documento=egd.tipo_documento and cxp.documento=egd.documento)
			inner join
				negocios neg on(neg.cod_neg=cxp.documento_relacionado)
			inner join
				convenios con on(con.id_convenio=neg.id_convenio)
			where
				eg.branch_code=NOTAS_.branch_code and
				eg.bank_account_no=NOTAS_.bank_account_no and
				eg.document_no=NOTAS_.document_no
			group by
				eg.dstrct,
				eg.branch_code,
				eg.bank_account_no,
				eg.document_no,
				eg.vlr,
				eg.nit,
				con.agencia,
				printer_date,
				payment_name
			union all
			select
				egd.dstrct,
				egd.branch_code,
				egd.bank_account_no,
				'NC' as tipo_documento,
				(select CUENTA from con.cmc_doc where tipodoc=cxp.tipo_documento and cmc=cxp.handle_code) as cuenta,
				egd.documento as doc_soporte,
				vlr as valor_deb,
				0 as valor_credt,
				proveedor as nit,
				con.agencia,
				cxp.fecha_documento,
				cxp.fecha_vencimiento,
				egd.description as descripcion
			from
				egresodet egd
			inner join
				fin.cxp_doc cxp on(cxp.tipo_documento=egd.tipo_documento and cxp.documento=egd.documento)
			inner join
				negocios neg on(neg.cod_neg=cxp.documento_relacionado)
			inner join
				convenios con on(con.id_convenio=neg.id_convenio)
			where
				branch_code=NOTAS_.branch_code and
				bank_account_no=NOTAS_.bank_account_no and
				document_no=NOTAS_.document_no

		loop

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

			iF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_EFEC',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,INFOITEMS_.agencia, 6)='S')THEN
				MCTYPE.MC_____FECHVENC__B = INFOITEMS_.fecha_vencimiento; --fecha vencimiento
					if (INFOITEMS_.fecha_vencimiento < INFOITEMS_.fecha_documento)then /** se valida si la fecha de vencimeinto es menor a la de creacion*/
						MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.fecha_vencimiento; --fecha creacion
					else
						MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.fecha_documento; --fecha creacion
					end if;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;

			------------------------------------------------------------------------------------------------------------------------------------------------------------
			MCTYPE.MC_____FECHA_____B := CASE WHEN (INFOITEMS_.fecha_documento::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(INFOITEMS_.fecha_documento,1,7),'-','') = notas_.periodo)  THEN INFOITEMS_.fecha_documento::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := notas_.document_no;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( notas_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( notas_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_EFEC', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,INFOITEMS_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_EFEC', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,INFOITEMS_.agencia, 2);
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_EFEC',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,INFOITEMS_.agencia, 3);

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_EFEC', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,INFOITEMS_.agencia, 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.doc_soporte;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_EFEC', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,INFOITEMS_.agencia, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--numero de cuotas
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

 			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			raise notice 'SW %',SW||' '||notas_.document_no;
			raise notice 'INFOITEMS_ %',INFOITEMS_;
			raise notice 'MCTYPE %',MCTYPE;
			SW:=CON.SP_INSERT_TABLE_MC_MICRO____(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;
			------------------------------------------------------------------------------------------------------------------------------------------------------------

		end loop;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'MICROCREDITO') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then

			update
				egresodet
			set
				procesado='S'
			where
				branch_code=notas_.branch_code and
				bank_account_no=notas_.bank_account_no and
				document_no=notas_.document_no;

		end if;

	end loop;

	RETURN 'OK';

end;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_micro_eg_efecty_apoteosys()
  OWNER TO postgres;
