-- Function: con.interfaz_pagos_x_unidad_apoteosys_ia(character varying, character varying)

-- DROP FUNCTION con.interfaz_pagos_x_unidad_apoteosys_ia(character varying, character varying);

CREATE OR REPLACE FUNCTION con.interfaz_pagos_x_unidad_apoteosys_ia(_periodo character varying, _unidadnego character varying)
  RETURNS text AS
$BODY$

DECLARE
	r_ingreso record;
	r_asiento record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;
	VALOR_ACUM_ numeric:=0.00;
	CUENTA_BANCO TEXT:='';
	cuota_ text:='';
	_CLASEDOC TEXT := 'IA'||SUBSTRING(_unidadNego,1,2);
	_PROCESOHOM TEXT := 'RECAUDO_'||SUBSTRING(_unidadNego,1,5);
	_NEGOCIO TEXT = '';

BEGIN


	FOR r_ingreso IN
--1). SE EJECUTA ESTE SELECT DEPENDIENDO LA UNIDAD DE NEGOCIO Y EL PERIODO (_periodo, _unidadNego)
--2). SE EJECUTA LA FUNCION COMPLETA

			SELECT
				erx.tipo_documento,
				erx.num_ingreso,
				agencia

			FROM
				con.eg_recaudo_xunidad('201710', 'LIBRANZA') erx
				--con.eg_recaudo_xunidad(_periodo, _unidadNego) erx
			INNER JOIN
				negocios neg on(neg.cod_neg=erx.negocio)
			INNER JOIN
				convenios con on(con.id_convenio=neg.id_convenio)
			WHERE
				erx.num_ingreso ILIKE 'IA%' AND
				erx.negocio NOT ILIKE 'TF%'
				--AND NUM_INGRESO='IA525520'
			GROUP BY
				erx.tipo_documento,
				erx.num_ingreso,
				agencia


	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_BINGRESO_APOTEOSYS');
		CONSEC:=1;

		FOR r_asiento IN


			SELECT ing.num_ingreso,
			       ing.periodo,
			       --ingb.nitcli as nit_cliente,
			       CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE ingb.nitcli END AS nit_cliente,
			       get_nombc(ingb.nitcli) AS nombre_cliente,
			       ing.fecha_consignacion,
			       ing.fecha_ingreso,
			       ing.branch_code,
			       ing.bank_account_no,
			       ing.descripcion_ingreso,
			       sum(idet.valor_ingreso) as valor_debito,
				0.00 as valor_credito,
			       ing.descripcion_ingreso as documento_soporte,
			       --idet.cuenta,
			       COALESCE((SELECT codigo_cuenta FROM banco  WHERE branch_code =ing.branch_code AND bank_account_no=ing.bank_account_no),'00000000') as cuenta,
			       ing.descripcion_ingreso,
			       (CASE
				 WHEN D.TIPO_IDEN='CED' THEN 'CC'
				 WHEN D.TIPO_IDEN='RIF' THEN 'CE'
				 WHEN D.TIPO_IDEN='' THEN 'CC'
				 WHEN D.TIPO_IDEN='NIT' THEN 'NIT'
				 ELSE
				 'CC' END) AS TERCER_CODIGO____TIT____B,
				 C.DIGITO_VERIFICACION AS TERCER_DIGICHEQ__B,
				 (D.NOMBRE1||' '||D.NOMBRE2) AS TERCER_NOMBCORT__B,
				 (D.APELLIDO1||' '||D.APELLIDO2) AS TERCER_APELLIDOS_B,
				 D.NOMBRE AS TERCER_NOMBEXTE__B,
				 (CASE
				 WHEN C.GRAN_CONTRIBUYENTE='N' AND C.AGENTE_RETENEDOR='N' THEN 'RCOM'
				 WHEN C.GRAN_CONTRIBUYENTE='N' AND C.AGENTE_RETENEDOR='S' THEN 'RCAU'
				 WHEN C.GRAN_CONTRIBUYENTE='S' AND C.AGENTE_RETENEDOR='N' THEN 'GCON'
				 WHEN C.GRAN_CONTRIBUYENTE='S' AND C.AGENTE_RETENEDOR='S' THEN 'GCAU'
				 ELSE 'PNAL' END) AS TERCER_CODIGO____TT_____B,
				 D.DIRECCION AS TERCER_DIRECCION_B,
				 (CASE
				 WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				 ELSE '08001' END) AS TERCER_CODIGO____CIUDAD_B,
				 D.TELEFONO AS TERCER_TELEFONO1_B
			FROM con.ingreso ing
			INNER JOIN con.ingreso_detalle idet on (ing.num_ingreso=idet.num_ingreso AND ing.tipo_documento=idet.tipo_documento AND ing.nitcli=idet.nitcli )
			INNER JOIN con.ingreso ingb on (ingb.num_ingreso=replace(replace(replace(replace(replace(replace(
										ing.descripcion_ingreso
										,chr(10),''),chr(11),''),chr(13),''),chr(27),''),chr(32),''),chr(39),''))
			LEFT JOIN con.factura fac on (fac.documento=idet.documento AND 	fac.tipo_documento=idet.tipo_doc AND fac.negasoc !='')
			LEFT JOIN PROVEEDOR C ON(C.NIT=ingb.nitcli)
			LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=ingb.nitcli)
			WHERE idet.reg_status = '' and ing.reg_status = '' and ing.num_ingreso=r_ingreso.num_ingreso
			group by
			ing.num_ingreso,
			ing.periodo,
			HT.NIT_APOTEOSYS,
			ingb.nitcli,
			ing.fecha_consignacion,
			ing.fecha_ingreso,
			ing.branch_code,
			ing.bank_account_no,
			ing.descripcion_ingreso,
			D.TIPO_IDEN,
			c.digito_verificacion,
			d.nombre1,
			D.NOMBRE2,
			D.APELLIDO1,
			D.APELLIDO2,
			D.NOMBRE,
			c.gran_contribuyente,
			C.AGENTE_RETENEDOR,
			D.DIRECCION,
			E.CODIGO_DANE2,
			D.TELEFONO
			UNION ALL
			SELECT ing.num_ingreso,
			       ing.periodo,
			       --ing.nitcli as nit_cliente,
			       CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE ing.nitcli END AS nit_cliente,
			       get_nombc(ing.nitcli) AS nombre_cliente,
			       ing.fecha_consignacion,
			       ing.fecha_ingreso,
			       ing.branch_code,
			       ing.bank_account_no,
			       ing.descripcion_ingreso,
			       0.00 as valor_credito,
			       idet.valor_ingreso as valor_credito,
			       idet.documento as documento_soporte,
			       --idet.cuenta,
			       case when idet.cuenta='28150531' then 'I010130014205' else idet.cuenta end as cuenta,
			       idet.descripcion,
			       (CASE
				 WHEN D.TIPO_IDEN='CED' THEN 'CC'
				 WHEN D.TIPO_IDEN='RIF' THEN 'CE'
				 WHEN D.TIPO_IDEN='' THEN 'CC'
				 WHEN D.TIPO_IDEN='NIT' THEN 'NIT'
				 ELSE
				 'CC' END) AS TERCER_CODIGO____TIT____B,
				 C.DIGITO_VERIFICACION AS TERCER_DIGICHEQ__B,
				 (D.NOMBRE1||' '||D.NOMBRE2) AS TERCER_NOMBCORT__B,
				 (D.APELLIDO1||' '||D.APELLIDO2) AS TERCER_APELLIDOS_B,
				 D.NOMBRE AS TERCER_NOMBEXTE__B,
				 (CASE
				 WHEN C.GRAN_CONTRIBUYENTE='N' AND C.AGENTE_RETENEDOR='N' THEN 'RCOM'
				 WHEN C.GRAN_CONTRIBUYENTE='N' AND C.AGENTE_RETENEDOR='S' THEN 'RCAU'
				 WHEN C.GRAN_CONTRIBUYENTE='S' AND C.AGENTE_RETENEDOR='N' THEN 'GCON'
				 WHEN C.GRAN_CONTRIBUYENTE='S' AND C.AGENTE_RETENEDOR='S' THEN 'GCAU'
				 ELSE 'PNAL' END) AS TERCER_CODIGO____TT_____B,
				 D.DIRECCION AS TERCER_DIRECCION_B,
				 (CASE
				 WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				 ELSE '08001' END) AS TERCER_CODIGO____CIUDAD_B,
				 D.TELEFONO AS TERCER_TELEFONO1_B
			FROM con.ingreso ing
			INNER JOIN con.ingreso_detalle idet on (ing.num_ingreso=idet.num_ingreso AND ing.tipo_documento=idet.tipo_documento AND ing.nitcli=idet.nitcli )
			LEFT JOIN con.factura fac on (fac.documento=idet.documento AND 	fac.tipo_documento=idet.tipo_doc AND fac.negasoc !='')
			LEFT JOIN PROVEEDOR C ON(C.NIT=ing.nitcli)
			LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=ing.nitcli)
			WHERE idet.reg_status = '' and ing.reg_status = '' and ing.num_ingreso=r_ingreso.num_ingreso

		LOOP
			SELECT INTO _NEGOCIO CON.INTERFAZ_NEGOCIOXDOCUMENTO(r_asiento.documento_soporte);

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(R_ASIENTO.FECHA_INGRESO::DATE,1,7),'-','')=R_ASIENTO.PERIODO THEN R_ASIENTO.FECHA_INGRESO::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(R_ASIENTO.PERIODO,1,4),SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 6)='S')then
				--MCTYPE.MC_____FECHEMIS__B = R_INGRESO.CREATION_DATE::DATE;
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'INGN' ;
			MCTYPE.MC_____CODIGO____CD_____B := _CLASEDOC;
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := CASE WHEN _NEGOCIO IS NOT NULL THEN _NEGOCIO||';'||r_ingreso.NUM_INGRESO ELSE r_ingreso.NUM_INGRESO END;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(R_ASIENTO.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(R_ASIENTO.nit_cliente)>10 THEN SUBSTR(R_ASIENTO.nit_cliente,1,10) ELSE R_ASIENTO.nit_cliente END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION_INGRESO ||'- Ingreso: '||r_ingreso.num_ingreso ;
			MCTYPE.MC_____FECHORCRE_B := R_ASIENTO.FECHA_INGRESO::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := R_ASIENTO.FECHA_INGRESO::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := R_ASIENTO.num_ingreso;
			MCTYPE.TERCER_CODIGO____TIT____B := R_ASIENTO.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := R_ASIENTO.TERCER_NOMBCORT__B  ;
			MCTYPE.TERCER_NOMBEXTE__B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_NOMBEXTE__B)>64 THEN SUBSTR(R_ASIENTO.TERCER_NOMBEXTE__B,1,64) ELSE R_ASIENTO.TERCER_NOMBEXTE__B END;
			MCTYPE.TERCER_APELLIDOS_B := R_ASIENTO.TERCER_APELLIDOS_B  ;
			MCTYPE.TERCER_CODIGO____TT_____B := R_ASIENTO.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_DIRECCION_B)>64 THEN SUBSTR(R_ASIENTO.TERCER_DIRECCION_B,1,64) ELSE R_ASIENTO.TERCER_DIRECCION_B END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := R_ASIENTO.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_TELEFONO1_B)>15 THEN SUBSTR(R_ASIENTO.TERCER_TELEFONO1_B,1,15) ELSE R_ASIENTO.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 4)='S')then
				MCTYPE.MC_____NUMDOCSOP_B := R_ASIENTO.DOCUMENTO_SOPORTE;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC_RECAUDO____(MCTYPE);
			CONSEC:=CONSEC+1;

		END LOOP;

		---------------------------------------------------------------------------

		--------------Revision de la transaccion-----------------
		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'RECAUDO') ='N' THEN
			SW='N';

			--BORRAMOS EL COMPROBANTE DE EXT
			DELETE FROM CON.mc_recaudo____
			WHERE MC_____NUMERO____B = SECUENCIA_GEN AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'INGN' AND  MC_____CODIGO____CD_____B = _CLASEDOC;

			CONTINUE;
		END IF;

		-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
		IF(SW='S')THEN

			UPDATE
				con.ingreso_detalle
			SET
				PROCESADO_ICA='S'
			WHERE
				TIPO_DOCUMENTO=r_ingreso.tipo_documento and
				num_ingreso=r_ingreso.num_ingreso;

			SW:='N';
		END IF;

		---------------------------------------------------------------

	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_pagos_x_unidad_apoteosys_ia(character varying, character varying)
  OWNER TO postgres;
