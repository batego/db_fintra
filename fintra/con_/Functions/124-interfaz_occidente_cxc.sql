-- Function: con.interfaz_occidente_cxc()

-- DROP FUNCTION con.interfaz_occidente_cxc();

CREATE OR REPLACE FUNCTION con.interfaz_occidente_cxc()
  RETURNS text AS
$BODY$

DECLARE
	r_factura record;
	r_registros record;
	infocliente record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;	
--SELECT con.interfaz_occidente_cxc()
--select * from con.mc_fenalco____  where procesado='N' and mc_____codigo____cd_____b='CCOC'
--delete from con.mc_fenalco____  where procesado='N' and mc_____codigo____cd_____b='CCOC'
BEGIN

	FOR r_factura IN

		select 
			a.tipo_documento, 
			a.documento, 
			a.periodo, 
			a.valor_factura,
			a.nit,
			a.cmc,
			c.cuenta,
			b.codigo_cuenta_contable,
			(substring(a.descripcion, strpos(a.descripcion,'.')-4, 4)||'-'||substring(a.descripcion, strpos(a.descripcion,'.')-7, 2)||'-'||substring(a.descripcion, strpos(a.descripcion,'.')-10, 2))::date as fecha
		from 
			con.factura a
		inner join
			con.factura_detalle b on(b.tipo_documento=a.tipo_documento and b.documento=a.documento)
		inner join
			con.cmc_doc c on(c.tipodoc=a.tipo_documento and c.cmc=a.cmc)
		where 
			a.tipo_documento='FAC' and 
			a.documento ilike 'R0%' and 
			a.cmc='RB' and 
			a.periodo>='201701' and 
			coalesce(a.procesado,'N')='N'
		order by 
			a.documento

--select negasoc, * from con.factura where documento='CA80627'
--select * from documentos_neg_aceptado where cod_neg='MC07989'

	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');

		FOR r_registros IN

			(select 
				a.tipo_documento,
				a.num_ingreso,
				a.codcli,
				--a.nitcli,
				r_factura.nit as nitcli,
				a.branch_code,
				a.bank_account_no,
				r_factura.cuenta as cuenta,
				b.valor_ingreso as valor_debito,
				0 as valor_credito,
				--b.factura,
				r_factura.documento as doc_sop,
				c.numero_remesa,
				e.agencia,
				a.descripcion_ingreso as descripcion,
				con.interfaz_obtener_centro_costo_x_ingreso(a.num_ingreso,1) as cc
			from 
				con.ingreso a
			inner join
				con.ingreso_detalle b on(b.tipo_documento=a.tipo_documento and b.num_ingreso=a.num_ingreso)
			left join
				con.factura_detalle c on(c.documento=b.factura)
			left join 
				negocios d on(d.cod_neg=c.numero_remesa)
			left join
				convenios e on(e.id_convenio=d.id_convenio)
			where 
				a.tipo_documento='ING' and 
				a.num_ingreso ilike 'IC%' and 
				a.fecha_consignacion=r_factura.fecha and 
				a.branch_code='CORRESPONSALES ' and 
				a.bank_account_no='BCO OCCIDENTE' 
			group by 
				a.tipo_documento,
				a.num_ingreso,
				a.codcli,
				a.nitcli,
				a.branch_code,
				a.bank_account_no,
				b.valor_ingreso,
				b.factura,
				c.numero_remesa,
				e.agencia,
				a.descripcion_ingreso)
			union all
			(select 
				a.tipo_documento,
				a.num_ingreso,
				a.codcli,
				a.nitcli,
				a.branch_code,
				a.bank_account_no,
				r_factura.codigo_cuenta_contable as cuenta,
				0 as valor_debito,
				b.valor_ingreso as valor_credito,
				b.factura as doc_sop,
				c.numero_remesa,
				e.agencia,
				b.descripcion,
				con.interfaz_obtener_centro_costo_x_ingreso(a.num_ingreso,1) as cc
			from 
				con.ingreso a
			inner join
				con.ingreso_detalle b on(b.tipo_documento=a.tipo_documento and b.num_ingreso=a.num_ingreso)
			left join
				con.factura_detalle c on(c.documento=b.factura)
			left join 
				negocios d on(d.cod_neg=c.numero_remesa)
			left join
				convenios e on(e.id_convenio=d.id_convenio)
			where 
				a.tipo_documento='ING' and 
				a.num_ingreso ilike 'IC%' and 
				a.fecha_consignacion=r_factura.fecha and 
				a.branch_code='CORRESPONSALES ' and 
				a.bank_account_no='BCO OCCIDENTE' 
			group by 
				a.tipo_documento,
				a.num_ingreso,
				a.codcli,
				a.nitcli,
				a.branch_code,
				a.bank_account_no,
				b.valor_ingreso,
				b.factura,
				c.numero_remesa,
				e.agencia,
				b.descripcion)
				
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
				else 'RSCP'
				END) as TERCER_CODIGO____TT_____B,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as TERCER_CODIGO____CIUDAD_B,
				(D.NOMBRE1||' '||D.NOMBRE2) AS TERCER_NOMBCORT__B,
				(D.APELLIDO1||' '||D.APELLIDO2) AS TERCER_APELLIDOS_B,
				d.nombre as TERCER_NOMBEXTE__B,
				d.direccion as TERCER_DIRECCION_B,
				d.telefono as TERCER_TELEFONO1_B
			from  NIT D --ON(D.CEDULA=prov.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			where cedula = r_registros.nitcli;

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r_factura.fecha::DATE,1,7),'-','')=r_factura.PERIODO THEN r_factura.fecha::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(r_factura.PERIODO,1,4),SUBSTRING(r_factura.PERIODO,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXC_OCCIDENTE', r_registros.TIPO_DOCUMENTO, r_registros.CUENTA,'', 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = r_factura.fecha::DATE;
				--MCTYPE.MC_____FECHEMIS__B = recordNeg.CREATION_DATE::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'CXCO' ;
			MCTYPE.MC_____CODIGO____CD_____B := 'CCOC';
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := r_factura.DOCUMENTO;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(r_factura.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(r_factura.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXC_OCCIDENTE', r_registros.TIPO_DOCUMENTO, r_registros.CUENTA,'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := r_registros.cc;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(r_registros.nitcli)>10 THEN SUBSTR(r_registros.nitcli,1,10) ELSE r_registros.nitcli END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := r_registros.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := r_registros.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := r_registros.DESCRIPCION ||'- Ingreso: '||r_registros.num_ingreso ||'- Factura: '||r_factura.documento ;
			MCTYPE.MC_____FECHORCRE_B := r_factura.fecha::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := r_factura.fecha::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := r_factura.documento;
			MCTYPE.TERCER_CODIGO____TIT____B := infocliente.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := infocliente.TERCER_NOMBCORT__B  ;
			MCTYPE.TERCER_NOMBEXTE__B := CASE WHEN CHAR_LENGTH(infocliente.TERCER_NOMBEXTE__B)>64 THEN SUBSTR(infocliente.TERCER_NOMBEXTE__B,1,64) ELSE infocliente.TERCER_NOMBEXTE__B END;
			MCTYPE.TERCER_APELLIDOS_B := infocliente.TERCER_APELLIDOS_B  ;
			MCTYPE.TERCER_CODIGO____TT_____B := infocliente.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(infocliente.TERCER_DIRECCION_B)>64 THEN SUBSTR(infocliente.TERCER_DIRECCION_B,1,64) ELSE infocliente.TERCER_DIRECCION_B END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := infocliente.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(infocliente.TERCER_TELEFONO1_B)>15 THEN SUBSTR(infocliente.TERCER_TELEFONO1_B,1,15) ELSE infocliente.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXC_OCCIDENTE', r_registros.TIPO_DOCUMENTO, r_registros.CUENTA,'', 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXC_OCCIDENTE', r_registros.TIPO_DOCUMENTO, r_registros.CUENTA,'', 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXC_OCCIDENTE', r_registros.TIPO_DOCUMENTO, r_registros.CUENTA,'', 4)='S')then
				MCTYPE.MC_____NUMDOCSOP_B := r_registros.doc_sop;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXC_OCCIDENTE', r_registros.TIPO_DOCUMENTO, r_registros.CUENTA,'', 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			raise notice 'MCTYPE: %', MCTYPE;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.sp_insert_table_mc_fenalco____(MCTYPE);
			CONSEC:=CONSEC+1;
		END LOOP;

		CONSEC:=1;
		---------------------------------------------------------------------------

		--------------Revision de la transaccion-----------------
		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'INGRESO_SE') ='N' THEN
			SW='N';

			--BORRAMOS EL COMPROBANTE DE EXT
			DELETE FROM CON.mc_fenalco____
			WHERE MC_____NUMERO____B = SECUENCIA_GEN AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'CXCO' AND  MC_____CODIGO____CD_____B = 'CCOC';

			CONTINUE;
		END IF;

		-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
		IF(SW='S')THEN

			/*UPDATE
				con.factura
			SET
				PROCESADO='S'
			WHERE
				TIPO_DOCUMENTO=r_factura.tipo_documento and
				documento=r_factura.documento;*/

			SW:='N';
		END IF;

		CONSEC:=1;
		---------------------------------------------------------------

	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_occidente_cxc()
  OWNER TO postgres;
