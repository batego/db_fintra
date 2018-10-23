-- Function: con.interfaz_multiservicio_endoso_apoteosys()

-- DROP FUNCTION con.interfaz_multiservicio_endoso_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_multiservicio_endoso_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
	r_cdiario record;
	r_asiento record;
	infocliente record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;

BEGIN

	FOR r_cdiario IN

		select
			a.tipodoc,
			a.numdoc,
			--a.PERIODO AS periodo,
			replace(substring(fechadoc,1,7),'-','') AS periodo,
			--replace(substring(A.CREATION_DATE,1,7),'-','') AS periodo,
			a.fechadoc,
			a.creation_date,
			a.total_debito,
			a.ref_2,
			a.grupo_transaccion,
			b.cmc,
			case when valor_debito>0 then 'CDEM'
				when valor_debito=0 then 'CDDM' else '' end as concepto
		from
			con.comprobante a
		inner join con.comprodet c on(a.tipodoc=c.tipodoc and a.numdoc=c.numdoc and a.grupo_transaccion=c.grupo_transaccion)
		inner join con.factura b on(b.tipo_documento='FAC' and b.documento=replace(a.numdoc,'D','P'))
		where
			a.reg_status='' and
			a.tipodoc='CDIAR' and
			a.numdoc ilike 'DM%' AND
			a.detalle ilike 'CONT FAC%' and
			--(a.periodo>='201701' and a.periodo<='201806') and
			(replace(substring(A.CREATION_DATE,1,7),'-','') >='201701' and replace(substring(A.CREATION_DATE,1,7),'-','')<='201808') and
			c.cuenta IN('16252115','16252105') and
			--replace(substring(fechadoc,1,7),'-','')='201709' and
			b.cmc not in('AS','FU') --and --REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')  and
			--and (coalesce(ref_2,'N')='N' or ref_2='')
			--and a.grupo_transaccion in(10733592)
			AND a.numdoc IN('DM13769_5')
		ORDER BY
			A.periodo,
			numdoc

			/**
			SELECT con.interfaz_multiservicio_endoso_apoteosys();
			select
			MC_____CODIGO____CD_____B,MC_____CODIGO____PF_____B ,MC_____NUMERO____PERIOD_B, count(0)
			from con.mc_cd_endoso____  where procesado='N' and MC_____CODIGO____TD_____B='DIAR' --and MC_____CODIGO____CD_____B = 'CDEM'
			group by MC_____CODIGO____CD_____B,MC_____CODIGO____PF_____B ,MC_____NUMERO____PERIOD_B
			order by MC_____CODIGO____PF_____B ,MC_____NUMERO____PERIOD_B;
			UPDATE con.mc_cd_endoso____ SET procesado='X' where MC_____CODIGO____TD_____B='DIAR' and procesado='N' and --MC_____IDENTIFIC_TERCER_B='49660384-'
			MC_____CODIGO____CD_____B = 'CDEM' AND mc_____referenci_b='DM13791_1'
			MC_____NUMERO____B=702311
			select * from con.mc_cd_endoso____  where MC_____CODIGO____TD_____B='DIAR' and MC_____CODIGO____CD_____B = 'CDEM' AND mc_____referenci_b='DM13311_10'
			--and MC_____CODIGO____PF_____B=2018 and MC_____NUMERO____PERIOD_B=3
			order by mc_____numero____b, mc_____secuinte__b;
			*/

	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_EGRESO_APOTEOSYS');

		For r_asiento in
			select
				tipodoc,
				numdoc,
				tercero,
				cuenta,
				doc_sop,
				valor_debito,
				valor_credito,
				detalle AS descripcion
			from
			(
			(select
				tipodoc,
				numdoc,
				tercero,
				--case when sum(valor_debito)>0 THEN '16252115' ELSE cuenta END AS cuenta,
				cuenta,
				'N'||substring(numdoc,2,length(numdoc)) AS doc_sop,
				sum(valor_debito) as valor_debito,
				sum(valor_credito) as valor_credito,
				'ENDOSO CARTERA' as detalle
			from
				con.comprodet
			where
				tipodoc=r_cdiario.tipodoc and
				numdoc=r_cdiario.numdoc AND
				grupo_transaccion=r_cdiario.grupo_transaccion
			group by
				tipodoc,
				numdoc,
				tercero,
				cuenta)
			UNION all
			(select
				tipodoc,
				numdoc,
				tercero,
				(select codigo_cuenta_contable from con.factura_detalle  where documento=('N'||substring(numdoc,2,length(numdoc)))
				and descripcion ilike 'Intereses%' group by codigo_cuenta_contable) as cuenta,
				'N'||substring(numdoc,2,length(numdoc)) AS doc_sop,
				valor_credito as valor_debito,
				0 as valor_credito,
				detalle
			from
				con.comprodet
			where
				tipodoc=r_cdiario.tipodoc and
				numdoc=r_cdiario.numdoc and
				grupo_transaccion=r_cdiario.grupo_transaccion and
				detalle ='Intereses')
			union all
			(select
				tipodoc,
				numdoc,
				tercero,
				(select cuenta_cabecera_cdiar from administrativo.proceso_endoso where concepto='INTERESES_MULTI') as cuenta,
				'N'||substring(numdoc,2,length(numdoc)) AS doc_sop,
				0 as valor_debito,valor_credito,
				detalle
			from
				con.comprodet
			where
				tipodoc=r_cdiario.tipodoc and
				numdoc=r_cdiario.numdoc and
				grupo_transaccion=r_cdiario.grupo_transaccion and
				detalle ='Intereses')
				) AS t
			where t.VALOR_DEBITO!=0 OR t.VALOR_CREDITO!=0

		LOOP

			select INTO INFOCLIENTE
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as TERCER_CODIGO____TIT____B,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				else
				'RSCP'
				END) as TERCER_CODIGO____TT_____B,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as TERCER_CODIGO____CIUDAD_B,
				(D.NOMBRE1||' '||D.NOMBRE2) AS TERCER_NOMBCORT__B,
				(D.APELLIDO1||' '||D.APELLIDO2) AS TERCER_APELLIDOS_B,
				d.nombre as TERCER_NOMBEXTE__B,
				d.telefono as TERCER_TELEFONO1_B,
				d.direccion as tercer_direccion_b,
				*
			from  NIT D --ON(D.CEDULA=prov.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			where cedula = r_asiento.tercero;

			if(INFOCLIENTE is null) then
				select INTO INFOCLIENTE
					'NIT'::text as TERCER_CODIGO____TIT____B,
					'RCOM'::text  as TERCER_CODIGO____TT_____B,
					'08001'::varchar as TERCER_CODIGO____CIUDAD_B,
					''::text AS TERCER_NOMBCORT__B,
					''::text AS TERCER_APELLIDOS_B,
					d.nomcli as TERCER_NOMBEXTE__B,
					d.telefono as TERCER_TELEFONO1_B,
					d.direccion as tercer_direccion_b
				from
					cliente D
				where
					codcli in (select codcli from con.factura where documento=replace(r_asiento.numdoc,'D','N'));
			end if;

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r_cdiario.FECHADOC::DATE,1,7),'-','')=r_cdiario.PERIODO THEN r_cdiario.FECHADOC::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(r_cdiario.PERIODO,1,4),SUBSTRING(r_cdiario.PERIODO,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', R_ASIENTO.CUENTA,'', 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'DIAR' ;
			MCTYPE.MC_____CODIGO____CD_____B := r_cdiario.concepto  ;
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := R_CDIARIO.NUMDOC;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(r_cdiario.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(r_cdiario.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', R_ASIENTO.CUENTA,'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', R_ASIENTO.CUENTA,'', 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(R_ASIENTO.tercero)>9 AND INFOCLIENTE.TERCER_CODIGO____TIT____B='NIT' THEN SUBSTR(R_ASIENTO.tercero,1,9) ELSE R_ASIENTO.tercero END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION  ;
			MCTYPE.MC_____FECHORCRE_B := FECHADOC_::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := FECHADOC_::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := r_cdiario.numdoc;
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := INFOCLIENTE.TERCER_NOMBCORT__B  ;
			MCTYPE.TERCER_NOMBEXTE__B := INFOCLIENTE.TERCER_NOMBEXTE__B  ;
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.TERCER_APELLIDOS_B  ;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := INFOCLIENTE.TERCER_DIRECCION_B  ;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_TELEFONO1_B)>15 THEN SUBSTR(INFOCLIENTE.TERCER_TELEFONO1_B,1,15) ELSE INFOCLIENTE.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____BASE______B := CASE WHEN R_ASIENTO.cuenta in('23680107','23653507') THEN r_cdiario.total_debito ELSE 0 END;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', R_ASIENTO.CUENTA,'', 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			--MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', R_ASIENTO.CUENTA,'', 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', R_ASIENTO.CUENTA,'', 4)='S')then
				MCTYPE.MC_____NUMDOCSOP_B := R_ASIENTO.doc_sop;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', R_ASIENTO.CUENTA,'', 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC_CD_ENDOSO____(MCTYPE);
			CONSEC:=CONSEC+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'CD_ENDOSO') ='N' THEN
			SW='N';

			--BORRAMOS EL COMPROBANTE DE EXT
			DELETE FROM CON.MC_CD_ENDOSO____
			WHERE MC_____NUMERO____B = SECUENCIA_GEN AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'DIAR' AND  MC_____CODIGO____CD_____B = 'CDEM'  ;

			CONTINUE;
		END IF;

		-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
		IF(SW='S')THEN

			UPDATE
				con.comprobante
			set
				ref_2='S'
			where
				tipodoc=r_cdiario.tipodoc and
				numdoc=r_cdiario.numdoc;

			SW:='N';
		END IF;

		CONSEC:=1;


	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_multiservicio_endoso_apoteosys()
  OWNER TO postgres;
