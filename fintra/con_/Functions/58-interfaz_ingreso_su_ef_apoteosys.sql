-- Function: con.interfaz_ingreso_su_ef_apoteosys()

-- DROP FUNCTION con.interfaz_ingreso_su_ef_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_ingreso_su_ef_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
	r_ingreso record;
	r_asiento record;
	INFOCLIENTE record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;

begin

	FOR r_ingreso IN

		SELECT
			ingd.tipo_documento,
			ingd.num_ingreso,
			ingd.periodo,
			ingd.procesado_ica,
			ing.fecha_ingreso as fechadoc
		FROM
			con.ingreso ing
		inner join
			con.ingreso_detalle ingd on(ingd.tipo_documento=ing.tipo_documento and ingd.num_ingreso=ing.num_ingreso)
		where
			ing.reg_status='' and
			ing.tipo_documento='ING' and
			branch_code in('SUPEREFECTIVO','EFECTY') and
			bank_account_no in('SUPEREFECTIVO','EFECTY') and
			ing.periodo='201701' and
			coalesce(procesado_ica,'N')='N'
		group by
			ingd.tipo_documento,
			ingd.num_ingreso,
			ingd.periodo,
			ingd.procesado_ica,
			ing.fecha_ingreso
		order by
			ingd.periodo,
			ingd.num_ingreso
		--limit 1

		--select con.interfaz_ingreso_su_ef_apoteosys();
		--select * from con.mc_fenalco____ where MC_____CODIGO____CD_____B='INSE' AND procesado='N'

	loop

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_BINGRESO_APOTEOSYS');

		for r_asiento in

			select
				ingd.tipo_documento,
				ingd.num_ingreso,
				ingd.nitcli,
				ingd.cuenta,
				ingd.fecha_factura,
				ingd.descripcion,
				ingd.periodo,
				--ingd.factura,
				case
				when substring(ingd.factura,1,1)='F' AND substring(ingd.factura,8,2)!='00' then b.documento
				else ingd.factura end as doc_sop,
				fac.negasoc,
				c.agencia,
				CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', 'CC', sp_uneg_negocio_name(fac.negasoc),c.agencia, 2) as cu,
				ingd.valor_ingreso as valor_debito,
				0 as valor_credito
			from
				con.ingreso_detalle ingd
			inner join con.factura fac on(fac.documento=ingd.factura)
			inner join negocios neg on(neg.cod_neg=fac.negasoc)
			INNER JOIN convenios c on(c.id_convenio=neg.id_convenio)
			left JOIN (SELECT reg_status, CODNEG,
					       SUBSTRING(COD,1,2) AS PREFIJO,
					       COD AS DOCUMENTO,
					       LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00') AS CUOTA,
					       FECHA_DOC::DATE AS FECHA_VEN,
					       VALOR,
					       TIPODOC
					FROM ING_FENALCO --WHERE reg_status=''
				) B on (fac.negasoc=B.CODNEG AND B.TIPODOC='IF'
					AND SUBSTRING(ingd.factura,8,2) =B.CUOTA)
			where
				ingd.tipo_documento=r_ingreso.tipo_documento and
				ingd.num_ingreso=r_ingreso.num_ingreso
			UNION ALL
			select
				t.tipo_documento,
				t.num_ingreso,
				t.nitcli,
				t.cuenta,
				t.fecha_ingreso,
				t.descripcion_ingreso,
				t.periodo,
				t.documento,
				'' as negasoc,
				'' as agencia,
				t.cu,
				t.valor_debito,
				sum(t.valor_credito) as valor_debito
			from
				(select
					ingd.tipo_documento,
					ingd.num_ingreso,
					ingd.nitcli,
					(select codigo_cuenta from banco where branch_code=ing.branch_code and bank_account_no=ing.bank_account_no) as cuenta,
					ing.fecha_ingreso,
					ing.descripcion_ingreso,
					ingd.periodo,
					--ingd.factura,
					ingd.num_ingreso as documento ,
					fac.negasoc,
					c.agencia,
					CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', 'CC', sp_uneg_negocio_name(fac.negasoc),c.agencia, 2) as cu,
					0 as valor_debito,
					ingd.valor_ingreso as valor_credito
				from
					con.ingreso_detalle ingd
				inner join con.ingreso ing on (ing.tipo_documento=ingd.tipo_documento and ing.num_ingreso=ingd.num_ingreso)
				inner join con.factura fac on(fac.documento=ingd.factura)
				inner join negocios neg on(neg.cod_neg=fac.negasoc)
				INNER JOIN convenios c on(c.id_convenio=neg.id_convenio)
				where
					ingd.tipo_documento=r_ingreso.tipo_documento and
					ingd.num_ingreso=r_ingreso.num_ingreso) as t
			group by
				t.tipo_documento,
				t.num_ingreso,
				t.nitcli,
				t.cuenta,
				t.fecha_ingreso,
				t.descripcion_ingreso,
				t.periodo,
				t.documento,
				t.cu,
				t.valor_debito

		loop
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
				nombre as TERCER_NOMBEXTE__B,
				telefono as TERCER_TELEFONO1_B,
				direccion as TERCER_DIRECCION_B
			from  NIT D --ON(D.CEDULA=prov.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			where cedula = r_asiento.nitcli;

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r_ingreso.FECHADOC::DATE,1,7),'-','')=r_ingreso.PERIODO THEN r_ingreso.FECHADOC::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(r_ingreso.PERIODO,1,4),SUBSTRING(r_ingreso.PERIODO,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA, r_asiento.agencia, 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'INGN' ;
			MCTYPE.MC_____CODIGO____CD_____B := 'INSE';-->?
			MCTYPE.MC_____SECUINTE__DCD____B := 0  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := r_ingreso.NUM_INGRESO;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(R_ASIENTO.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,r_asiento.agencia, 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := R_ASIENTO.CU  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(r_asiento.nitcli)>10 THEN SUBSTR(r_asiento.nitcli,1,10) ELSE r_asiento.nitcli END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION;
			MCTYPE.MC_____FECHORCRE_B := R_INGRESO.FECHADOC::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := R_INGRESO.FECHADOC::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := r_ingreso.num_ingreso;
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := INFOCLIENTE.TERCER_NOMBCORT__B  ;
			MCTYPE.TERCER_NOMBEXTE__B := INFOCLIENTE.TERCER_NOMBEXTE__B  ;
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.TERCER_APELLIDOS_B  ;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_DIRECCION_B)>64 THEN SUBSTR(INFOCLIENTE.TERCER_DIRECCION_B,1,64) ELSE INFOCLIENTE.TERCER_DIRECCION_B END  ;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_TELEFONO1_B)>15 THEN SUBSTR(INFOCLIENTE.TERCER_TELEFONO1_B,1,15) ELSE INFOCLIENTE.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____BASE______B := 0;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,r_asiento.agencia, 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,r_asiento.agencia, 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,r_asiento.agencia, 4)='S')then
				MCTYPE.MC_____NUMDOCSOP_B := R_ASIENTO.doc_sop;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,r_asiento.agencia, 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			raise notice 'MCTYPE: %', MCTYPE;
			SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
			CONSEC:=CONSEC+1;

		end loop;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'INGRESO_SE') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then
			--UPDATE con.ingreso_detalle set procesado_ica='S' where tipo_documento=r_ingreso.tipo_documento and num_ingreso=r_ingreso.num_ingreso;
		end if;

	end loop;

	RETURN 'OK';

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_ingreso_su_ef_apoteosys()
  OWNER TO postgres;
