-- Function: con.interfaz_multiservicio_causacion_apoteosys()

-- DROP FUNCTION con.interfaz_multiservicio_causacion_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_multiservicio_causacion_apoteosys()
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
	VALOR integer:=0;
	CUENTA_ TEXT:='';
	CONCEPTO_ TEXT:='';
	VAL_PERIODO_ boolean:=TRUE;

BEGIN

	FOR r_cdiario IN

		select
			tipodoc,
			numdoc,
			periodo as periodo1,
			replace(substring(fechadoc,1,7),'-','') AS periodo,
			fechadoc,
			creation_date,
			detalle,
			total_items,
			total_debito,
			total_credito
		from
			con.comprobante
		where
			reg_status='' and
			tipodoc='CDIAR' and
			numdoc ilike 'CIM%' and
			--periodo ='201702' and
			replace(substring(fechadoc,1,7),'-','')='201807' and
			total_items!=0
			AND (coalesce(ref_2,'N')='N' or ref_2='')
			--and numdoc='CIM10000002'
		order by
			--periodo, numdoc
			fechadoc, numdoc

			/**
			SELECT con.interfaz_multiservicio_causacion_apoteosys();
			select
			MC_____CODIGO____CD_____B,MC_____CODIGO____PF_____B ,MC_____NUMERO____PERIOD_B, count(0)
			from con.mc_cd_endoso____  where procesado='N' and MC_____CODIGO____TD_____B='DIAR' and MC_____CODIGO____CD_____B in('CIFN','CIFM')
			group by MC_____CODIGO____CD_____B,MC_____CODIGO____PF_____B ,MC_____NUMERO____PERIOD_B
			order by MC_____CODIGO____PF_____B ,MC_____NUMERO____PERIOD_B;
			select * from con.mc_cd_endoso____  where procesado='N' and MC_____CODIGO____TD_____B='DIAR' and MC_____CODIGO____CD_____B in('CIFN','CIFM')
			and MC_____CODIGO____PF_____B=2017 and MC_____NUMERO____PERIOD_B=8
			order by mc_____numero____b, mc_____secuinte__b;
			DELETE from con.mc_cd_endoso____ where MC_____CODIGO____TD_____B='DIAR' and MC_____CODIGO____CD_____B in('CIFN','CIFM')
			and MC_____CODIGO____PF_____B=2018 and MC_____NUMERO____PERIOD_B=3 ;
			UPDATE con.mc_cd_endoso____ set
			MC_____FECHA_____B='2018-06-30'::DATE,
			MC_____FECHEMIS__B='2018-06-30'::DATE,
			MC_____FECHVENC__B='2018-06-30'::DATE,
			procesado='N'
			where MC_____CODIGO____TD_____B='DIAR' and MC_____CODIGO____CD_____B in('CIFN','CIFM')
			AND MC_____NUMERO____B IN(701020) and MC_____NUMEVENC__B=1;
			select * from
			update con.mc_cd_endoso____ set
			--MC_____IDENTIFIC_TERCER_B='49660384',
			PROCESADO='N'
			where MC_____CODIGO____TD_____B='DIAR' and MC_____CODIGO____CD_____B in('CIFN','CIFM')
			--and MC_____IDENTIFIC_TERCER_B='49660384-'
			AND MC_____NUMERO____B in('704069')
			--and mc_____numdocsop_b='NM13197_6';
			--and MC_____REFERENCI_B='CIM10000003'
			--AND num_proceso=25179
			AND PROCESADO='N'
			and MC_____CODIGO____PF_____B='2018'
			and MC_____NUMERO____PERIOD_B=2
			order by MC_____CODIGO____PF_____B ,MC_____NUMERO____PERIOD_B, MC_____NUMERO____B, MC_____SECUINTE__B;
			*/

	LOOP

		SELECT INTO SECUENCIA_GEN
		NEXTVAL('CON.INTERFAZ_SECUENCIA_EGRESO_APOTEOSYS');

		For r_asiento in
			select
				tipodoc,
				numdoc,
				c.tercero,
				case when h.nit_fintra is not null then nit_apoteosys else c.tercero end as nit,
				cuenta,
				'N'||substring(c.referencia_1,2,length(c.referencia_1)) AS doc_sop,
				c.referencia_1,
				round(valor_debito,0) as valor_debito,
				round(valor_credito,0) as valor_credito,
				detalle,
				c.creation_date,
				f.cmc
			from
				con.comprodet c
			left join
				con.factura f on(f.tipo_documento='FAC' and f.documento=c.referencia_1)
			left join con.homologa_terceros h on(h.nit_fintra=c.tercero)
			where
				tipodoc=r_cdiario.tipodoc
				and numdoc=r_cdiario.numdoc
				and f.cmc not in('AS')
			order by c.transaccion

		LOOP

				/*select INTO INFOCLIENTE
				tipo_iden,
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
				where cedula = '8910011228'--r_asiento.tercero;*/

			--if(INFOCLIENTE is null) then
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
					codcli in (select codcli from con.factura where documento=replace(r_asiento.referencia_1,'P','N'));
			--end if;

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r_cdiario.FECHADOC::DATE,1,7),'-','')=r_cdiario.PERIODO THEN r_cdiario.FECHADOC::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(r_cdiario.PERIODO,1,4),SUBSTRING(r_cdiario.PERIODO,5,2)::INT)::DATE END ;
			valor:=0;

			select into valor
			count(0) from con.comprobante a
			inner join con.factura b on (b.tipo_documento='FAC' and b.documento=a.numdoc)
			where tipodoc='CDIAR' and numdoc=replace(r_asiento.referencia_1,'P','D') and b.cmc not in('AS','FU');

			select into val_periodo_
				(replace(substring(d.fechadoc,1,7),'-','')<=(replace(substring(b.fechadoc,1,7),'-','')))
			from
				con.comprodet a
			inner join
				con.comprobante d on(d.tipodoc='CDIAR' and d.numdoc=a.numdoc)
			inner join
				con.comprobante b on (b.tipodoc='CDIAR' and b.numdoc=replace(a.referencia_1,'P','D'))
			inner join
				con.factura c on(c.tipo_documento='FAC' and c.documento=a.referencia_1)
			where
				a.tipodoc='CDIAR' and a.numdoc =r_asiento.numdoc and a.referencia_1=r_asiento.referencia_1 and c.cmc not in('AS','FU')
			group by (replace(substring(d.fechadoc,1,7),'-','')<=(replace(substring(b.fechadoc,1,7),'-','')));

			CUENTA_:='';
			CUENTA_:=case when /*valor::INT=1 and*/ r_asiento.cuenta in('27050803', '27050813') and val_periodo_=false then '16252121'
					when /*valor::INT=1 and*/ r_asiento.cuenta in('I010120064169','I010200064169','I010330124169') and val_periodo_=false then '16252149'
					else r_asiento.cuenta end;

			CONCEPTO_:='';
			CONCEPTO_:=case when val_periodo_=false then 'CIFM'
						else 'CIFN' end;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', CUENTA_,'', 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'DIAR' ;
			MCTYPE.MC_____CODIGO____CD_____B := CONCEPTO_  ;
			MCTYPE.MC_____SECUINTE__DCD____B := 0  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := R_CDIARIO.NUMDOC;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(r_cdiario.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(r_cdiario.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', CUENTA_,'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', CUENTA_,'', 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(R_ASIENTO.nit::text)>9 and infocliente.TERCER_CODIGO____TIT____B='NIT' THEN SUBSTR(R_ASIENTO.nit::text,1,9) ELSE R_ASIENTO.nit END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DETALLE  ;
			MCTYPE.MC_____FECHORCRE_B := FECHADOC_::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := FECHADOC_::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := r_cdiario.numdoc;
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := INFOCLIENTE.TERCER_NOMBCORT__B  ;
			MCTYPE.TERCER_NOMBEXTE__B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_NOMBEXTE__B)>64 THEN SUBSTR(INFOCLIENTE.TERCER_NOMBEXTE__B,1,64) ELSE INFOCLIENTE.TERCER_NOMBEXTE__B END;
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.TERCER_APELLIDOS_B  ;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_DIRECCION_B)>64 THEN SUBSTR(INFOCLIENTE.TERCER_DIRECCION_B,1,64) ELSE INFOCLIENTE.TERCER_DIRECCION_B END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_TELEFONO1_B)>15 THEN SUBSTR(INFOCLIENTE.TERCER_TELEFONO1_B,1,15) ELSE INFOCLIENTE.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____BASE______B := CASE WHEN r_asiento.cuenta in('23680107','23653507') THEN r_cdiario.total_debito ELSE 0 END;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', CUENTA_,'', 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			--MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', CUENTA_,'', 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', CUENTA_,'', 4)='S')then
				MCTYPE.MC_____NUMDOCSOP_B := R_ASIENTO.doc_sop;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO_MULTI', 'CDI', CUENTA_,'', 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			raise notice 'MCTYPE: %', mctype;
			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC_CD_ENDOSO____(MCTYPE);
			CONSEC:=CONSEC+1;

		END LOOP;

		PERFORM con.interfaz_multiservicio_causacion_valida_concepto_apoteosys(SECUENCIA_GEN);

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
ALTER FUNCTION con.interfaz_multiservicio_causacion_apoteosys()
  OWNER TO postgres;
