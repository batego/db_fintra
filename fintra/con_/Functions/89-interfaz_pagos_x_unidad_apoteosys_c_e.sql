-- Function: con.interfaz_pagos_x_unidad_apoteosys_c_e(character varying)

-- DROP FUNCTION con.interfaz_pagos_x_unidad_apoteosys_c_e(character varying);

CREATE OR REPLACE FUNCTION con.interfaz_pagos_x_unidad_apoteosys_c_e(_unidadnego character varying)
  RETURNS text AS
$BODY$

DECLARE
	r_ingreso record;
	r_asiento record;
	recordNeg record;
	INFOCLIENTE record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;
	VALOR_ACUM_ numeric:=0.00;
	CUENTA_BANCO TEXT:='';
	cuota_ text:='';
	_CLASEDOC TEXT := 'IC'||SUBSTRING(_unidadNego,1,2);
	_PROCESOHOM TEXT := 'RECAUDO_'||SUBSTRING(_unidadNego,1,5);
	_periodo text := '201702';--replace(substring(CURRENT_date,1,7),'-','');
--SELECT con.interfaz_pagos_x_unidad_apoteosys_c_e('EDUCATIVO FA')
--select COUNT(*) from con.mc_recaudo____  where procesado='N'
--delete from con.mc_recaudo____  where procesado='N'
--UPDATE con.mc_recaudo____ set procesado='N' where num_proceso='26701'

BEGIN

	FOR r_ingreso IN

		SELECT
			erx.tipo_documento, erx.num_ingreso, agencia--, erx.negocio, neg.creation_date
		FROM
			--con.eg_recaudo_xunidad('201707', 'LIBRANZA') erx
			con.eg_recaudo_xunidad(_periodo, _unidadNego) erx
		INNER JOIN
			negocios neg on(neg.cod_neg=erx.negocio)
		INNER JOIN
			convenios con on(con.id_convenio=neg.id_convenio)
		WHERE
			erx.num_ingreso ilike'IC%' AND
			erx.negocio not ilike 'TF%' and
			erx.negocio not in (select negocio_reestructuracion from rel_negocios_reestructuracion)
			--and NUM_INGRESO IN('IC247815','IC247707')
		group by
			erx.tipo_documento,erx.num_ingreso, agencia

	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_BINGRESO_APOTEOSYS');

		FOR r_asiento IN

			SELECT
				ing.num_ingreso,
				ing.cuenta,
				ing.tipo_documento,
				ing.creation_date,
				ing.periodo,
				ing.fecha_consignacion,
				ing.descripcion,
				ing.nitcli,
				0 as valor_debito,
				valor_ingreso as valor_credito,
				ing.cuenta_banco,
				ing.cuota,
				ing.negocio,
				ing.documento
			FROM
				--con.eg_recaudo_xunidad_xingreso('201705', 'LIBRANZA', 'IC239084')  ing
				con.eg_recaudo_xunidad_xingreso(_periodo, _unidadNego, r_ingreso.num_ingreso)  ing
			WHERE
				NUM_INGRESO=r_ingreso.num_ingreso AND valor_ingreso!=0 --and ing.negocio not in(SELECT negocio_reestructuracion FROM rel_negocios_reestructuracion)
				--'IC230079'

		LOOP

			SELECT INTO INFOCLIENTE
				'NIT' AS TIPO_DOC,
				'GCON' AS CODIGO,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) AS CODIGOCIU,
				NOMCLI AS NOMBRE_CORTO,
				NOMCLI AS  NOMBRE,
				'' AS APELLIDOS,
				DIRECCION,
				TELEFONO
			FROM CLIENTE CL
			LEFT JOIN CIUDAD E ON(E.CODCIU=CL.CIUDAD)
			WHERE CL.NIT =  r_asiento.nitcli;

			SELECT INTO recordNeg un.descripcion, neg.cod_neg, neg.creation_date  FROM con.factura fac
			INNER JOIN negocios neg ON (neg.cod_neg=fac.negasoc)
			INNER JOIN rel_unidadnegocio_convenios rneg on (rneg.id_convenio=neg.id_convenio)
			INNER JOIN unidad_negocio un on (un.id=rneg.id_unid_negocio)
			WHERE documento=r_asiento.documento AND tipo_documento IN ('FAC','NDC') AND un.id in (1,2,3,4,6,7,8,9,10,21,22);

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(R_ASIENTO.CREATION_DATE::DATE,1,7),'-','')=R_ASIENTO.PERIODO THEN R_ASIENTO.CREATION_DATE::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(R_ASIENTO.PERIODO,1,4),SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				--MCTYPE.MC_____FECHEMIS__B = recordNeg.CREATION_DATE::DATE;
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
			MCTYPE.MC_____REFERENCI_B := R_ASIENTO.NEGOCIO;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(R_ASIENTO.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(R_ASIENTO.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN (SUBSTRING(R_ASIENTO.nitcli,1,1) IN(8,9) AND CHAR_LENGTH(R_ASIENTO.nitcli)>9) THEN SUBSTR(R_ASIENTO.nitcli,1,9) ELSE R_ASIENTO.nitcli END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION ||'- Ingreso: '||r_ingreso.num_ingreso ;
			MCTYPE.MC_____FECHORCRE_B := R_ASIENTO.CREATION_DATE::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := R_ASIENTO.CREATION_DATE::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := R_ASIENTO.num_ingreso;
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.TIPO_DOC;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTRING(INFOCLIENTE.NOMBRE_CORTO,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTRING(INFOCLIENTE.NOMBRE,1,64);
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.APELLIDOS;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.CODIGO;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.DIRECCION)>64 THEN SUBSTR(INFOCLIENTE.DIRECCION,1,64) ELSE INFOCLIENTE.DIRECCION END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.CODIGOCIU;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TELEFONO)>15 THEN SUBSTR(INFOCLIENTE.TELEFONO,1,15) ELSE INFOCLIENTE.TELEFONO END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 4)='S')then
				if(MCTYPE.MC_____CODIGO____CPC____B IN('23809605','28150501'))then
					MCTYPE.MC_____NUMDOCSOP_B := R_ASIENTO.NEGOCIO;
				else
					MCTYPE.MC_____NUMDOCSOP_B := R_ASIENTO.DOCUMENTO;
				end if;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,R_INGRESO.AGENCIA, 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			CUENTA_BANCO:=R_ASIENTO.cuenta_banco;

			RAISE NOTICE 'CUENTA_BANCO: %', CUENTA_BANCO;

			if(R_ASIENTO.CUOTA!='')then
				cuota_:=R_ASIENTO.CUOTA;
			end if;

			raise notice 'MCTYPE: %', MCTYPE;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC_RECAUDO____(MCTYPE);
			CONSEC:=CONSEC+1;
			VALOR_ACUM_:=VALOR_ACUM_+R_ASIENTO.VALOR_CREDITO::NUMERIC;
		END LOOP;

		----------------Se realiza el insert del banco-----------------------
		MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
		MCTYPE.MC_____SECUINTE__B := 0  ;
		MCTYPE.MC_____CREMONLOC_B := 0.00;
		MCTYPE.MC_____DEBMONLOC_B := VALOR_ACUM_::NUMERIC;
		MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', CUENTA_BANCO,R_INGRESO.AGENCIA, 1)  ;
		MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', CUENTA_BANCO,R_INGRESO.AGENCIA, 2)  ;
		MCTYPE.MC_____OBSERVACI_B:='Banco';
		MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', CUENTA_BANCO,R_INGRESO.AGENCIA, 3);

		if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', CUENTA_BANCO,R_INGRESO.AGENCIA, 4)='S')then
			MCTYPE.MC_____NUMDOCSOP_B := MCTYPE.MC_____REFERENCI_B;
		else
			MCTYPE.MC_____NUMDOCSOP_B := '';
		end if;

		if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', CUENTA_BANCO,R_INGRESO.AGENCIA, 5)::int=1)then
			MCTYPE.MC_____NUMEVENC__B := cuota_;
		else
			MCTYPE.MC_____NUMEVENC__B := null;
		end if;

		if(CON.OBTENER_HOMOLOGACION_APOTEOSYS(_PROCESOHOM, 'ING', CUENTA_BANCO,R_INGRESO.AGENCIA, 6)='S')then
			MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
			MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
		else
			MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
			MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

		end if;

		raise notice 'MCTYPE: %', MCTYPE;

		SW:=CON.SP_INSERT_TABLE_MC_RECAUDO____(MCTYPE);

		CONSEC:=1;
		VALOR_ACUM_:=0;
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

		CONSEC:=1;
		---------------------------------------------------------------

	END LOOP;

	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_pagos_x_unidad_apoteosys_c_e(character varying)
  OWNER TO postgres;
