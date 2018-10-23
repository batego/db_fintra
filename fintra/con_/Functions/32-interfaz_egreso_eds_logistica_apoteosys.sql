-- Function: con.interfaz_egreso_eds_logistica_apoteosys()

-- DROP FUNCTION con.interfaz_egreso_eds_logistica_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_egreso_eds_logistica_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
	r_egreso record;
	r_asiento record;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	FECHA_CXP_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;
	_ARRCUENTASAET VARCHAR[] :='{22050404}';--IDEAL UN TABLA OJO!!

BEGIN

	FOR r_egreso IN

		SELECT  --apt.id,
			apt.reg_status as estado
		       --,cxp.PERIODO
		       ,ed.periodo
		       ,tsp.factura_tercero
		       ,tsp.user_autorizacion
		       ,tsp.estado_pago_tercero
		       ,sum(apt.vlr) as valor
		       ,apt.porcentaje
		       ,sum(apt.vlr_descuento) as vlr_descuento
		       ,sum(apt.vlr_neto) as vlr_neto
		       ,sum(apt.vlr_combancaria) as vlr_combancaria
		       ,sum(apt.vlr_consignacion) as vlr_consignacion
		       ,sum(cxp.vlr_saldo) as valor_saldo
		       ,CASE WHEN tsp.user_autorizacion !='' AND tsp.factura_tercero=''  THEN 'AUTORIZADA'
			 WHEN tsp.factura_tercero !='' AND tsp.estado_pago_tercero='P' AND sum(cxp.vlr_saldo) >0 THEN 'FACTURADA'
			 WHEN tsp.factura_tercero !='' AND tsp.estado_pago_tercero='P' AND sum(cxp.vlr_saldo) =0 THEN 'FACTURADA Y PAGADA'
			 ELSE ''
		    END AS estado_factura
		    ,sum(tsp.vlr_gasolina) as vlr_gasolina
		    ,sum(tsp.vlr_efectivo) as vlr_efectivo
		    ,edet.document_no as egreso
		    ,edet.branch_code
		    ,edet.bank_account_no
		    ,edet.vlr
		    --ed.periodo as periodo_egre
		FROM fin.anticipos_pagos_terceros apt
		LEFT JOIN fin.anticipos_pagos_terceros_tsp tsp  ON (apt.id=tsp.id)
		INNER JOIN proveedor as b on (b.nit = apt.proveedor_anticipo)
		INNER JOIN nit as c on (c.cedula = apt.pla_owner)
		INNER JOIN (SELECT * FROM fin.cxp_doc cxp
			    WHERE cxp.handle_code='GA' AND cxp.dstrct ='FINV'
				 AND cxp.reg_status='' AND cxp.tipo_documento='FAP'
			    UNION
			    SELECT * FROM  tem.cxp_doc_aga
		       )cxp ON ( cxp.handle_code='GA' AND cxp.documento=tsp.factura_tercero AND cxp.dstrct ='FINV' AND cxp.reg_status='' AND cxp.tipo_documento='FAP')
		INNER JOIN egresodet edet on (edet.documento=tsp.factura_tercero AND edet.document_no=cxp.cheque and edet.reg_status='')
		INNER JOIN egreso ed on (ed.branch_code=edet.branch_code and ed.bank_account_no=edet.bank_account_no and edet.document_no=ed.document_no and edet.reg_status='')
		--INNER JOIN FIN.CXP_ITEMS_DOC CXPDET ON (CXPDET.DOCUMENTO=CXP.DOCUMENTO AND CXPDET.TIPO_DOCUMENTO=CXP.TIPO_DOCUMENTO AND CXPDET.REFERENCIA_1=TSP.ID  )
		WHERE
		    --REPLACE(SUBSTRING(apt.fecha_anticipo,1,7),'-','')::INTEGER BETWEEN '201701'::INTEGER AND REPLACE(substring(NOW(),1,7),'-','')::INTEGER
		    ed.periodo>='201701' AND
		    --coalesce(edet.procesado,'N')='N' AND
		    apt.reg_status=''
		    AND apt.dstrct = 'FINV'
		    AND apt.proveedor_anticipo = '802022016'
		    AND apt.concept_code in ('10')
		    AND apt.planilla != 'SAL ABPRES'
		    --AND edet.document_no IN('BC14619','BC14618')
		    and tsp.factura_tercero in('118487','118491')
		GROUP BY --apt.id,
			apt.reg_status
			--,apt.fecha_anticipo
			--,edet.creation_date
			,ed.PERIODO
		       ,tsp.factura_tercero
		       ,tsp.user_autorizacion
		       ,tsp.estado_pago_tercero
		       ,apt.porcentaje
		       ,edet.document_no
		       ,edet.branch_code
		       ,edet.bank_account_no
		       ,edet.vlr
		ORDER BY
			tsp.factura_tercero

/***
select con.interfaz_egreso_eds_logistica_apoteosys();
SELECT MC_____NUMERO____PERIOD_B, COUNT(MC_____NUMERO____PERIOD_B) FROM con.mc____ where MC_____CODIGO____TD_____B='EGRN' and MC_____CODIGO____CD_____B = 'EGLG' and procesado in('N')
group by MC_____NUMERO____PERIOD_B;
delete FROM con.mc____ where MC_____CODIGO____TD_____B='EGRN' and MC_____CODIGO____CD_____B = 'EGLG' and num_proceso=9332  and mc_____numero____b=114482;
9348,9350
UPDATE con.mc____ set PROCESADO='S' where MC_____CODIGO____TD_____B='EGRN' and MC_____CODIGO____CD_____B = 'EGLG' and num_proceso=9395
and mc_____numero____b NOT in(116394,116395) and MC_____NUMEVENC__B=1
DELETE FROM con.mc____ where MC_____CODIGO____TD_____B='EGRN' and MC_____CODIGO____CD_____B = 'EGLG' and procesado='N';
select * from egresodet where document_no='BC13456'
**/

	LOOP

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_EGRESO_APOTEOSYS');

		SELECT
			INTO FECHA_CXP_
			FECHADOC
		FROM
			CON.COMPROBANTE
		WHERE
			DSTRCT='FINV' AND
			TIPODOC='FAP' AND
			NUMDOC=r_egreso.FACTURA_TERCERO;

		RAISE NOTICE 'FACTURA: %',r_egreso.FACTURA_TERCERO||'-'||r_egreso.EGRESO;

		FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(FECHA_CXP_::DATE,1,7),'-','')=R_egreso.PERIODO THEN FECHA_CXP_::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(R_egreso.PERIODO,1,4),SUBSTRING(R_egreso.PERIODO,5,2)::INT)::DATE END ;

		CONSEC:=1;

		For r_asiento in

			select --cxpd.REFERENCIA_1,cxpd.reg_status,
				cxp.documento,
				_ARRCUENTASAET[1] as cuenta,
				cxp.tipo_documento,
				cxp.creation_date,
				cxp.periodo,
				cxp.descripcion,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE CXP.proveedor END AS proveedor,
				--cxp.proveedor,
				0 as valor_credito,
				--sum(cxpd.vlr) as valor_debito,
				r_egreso.vlr as valor_debito,
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
			from
				fin.cxp_doc cxp
			inner join fin.cxp_items_doc cxpd on(cxpd.dstrct=cxp.dstrct and cxpd.proveedor=cxp.proveedor and cxpd.tipo_documento=cxp.tipo_documento and cxpd.documento=cxp.documento)
			LEFT JOIN PROVEEDOR C ON(C.NIT=cxp.proveedor)
			LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=CXP.PROVEEDOR)
			where cxp.handle_code='GA' and
				cxp.tipo_documento='FAP' and --cxpd.referencia_1 =1480195 and
				cxp.documento=r_egreso.factura_tercero
			group by
				cxp.documento,
				cxpd.codigo_cuenta,
				cxp.tipo_documento,
				cxp.creation_date,
				cxp.periodo,
				cxp.descripcion,
				HT.NIT_APOTEOSYS,
				cxp.proveedor,
				D.TIPO_IDEN,
				C.DIGITO_VERIFICACION,
				D.NOMBRE1,
				D.NOMBRE2,
				D.APELLIDO1,
				D.APELLIDO2,
				D.NOMBRE,
				C.GRAN_CONTRIBUYENTE,
				C.AGENTE_RETENEDOR,
				D.DIRECCION,
				E.CODIGO_DANE2,
				d.telefono
			union all
			SELECT
				eg.document_no as documento,
				con.cuenta,
				con.tipodoc as tipo_documento,
				eg.creation_date,
				eg.periodo,
				egd.description as descripcion,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE eg.nit END AS nit,
				--eg.nit,
				egd.vlr as valor_credito,
				0 as valor_debito,
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
			FROM
				egreso eg
			inner join egresodet egd on(egd.dstrct=eg.dstrct and egd.branch_code=eg.branch_code and egd.bank_account_no=eg.bank_account_no and egd.document_no=eg.document_no)
			inner join con.comprodet con on(con.dstrct=eg.dstrct and con.tipodoc='EGR' and con.numdoc=eg.document_no and con.documento_rel=eg.document_no and con.grupo_transaccion=egd.transaccion)
			LEFT JOIN PROVEEDOR C ON(C.NIT=eg.nit)
			LEFT JOIN NIT D ON(D.CEDULA=C.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=eg.nit)
			where
				eg.document_no=r_egreso.egreso
				and
				eg.branch_code=r_egreso.branch_code
				and
				eg.bank_account_no=r_egreso.bank_account_no
				and
				egd.documento=r_egreso.factura_tercero

		LOOP

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGO_EDS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'EGRN' ;
			MCTYPE.MC_____CODIGO____CD_____B := 'EGLG'  ;
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := r_egreso.factura_tercero;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(r_egreso.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(r_egreso.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGO_EDS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGO_EDS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 2)  ;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(R_ASIENTO.proveedor)>10 THEN SUBSTR(R_ASIENTO.proveedor,1,10) ELSE R_ASIENTO.proveedor END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := R_ASIENTO.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := R_ASIENTO.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := R_ASIENTO.DESCRIPCION||'-'||r_egreso.egreso ;
			MCTYPE.MC_____FECHORCRE_B := FECHADOC_::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := FECHADOC_::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := r_egreso.egreso;
			MCTYPE.TERCER_CODIGO____TIT____B := R_ASIENTO.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := R_ASIENTO.TERCER_NOMBCORT__B  ;
			MCTYPE.TERCER_NOMBEXTE__B := R_ASIENTO.TERCER_NOMBEXTE__B  ;
			MCTYPE.TERCER_APELLIDOS_B := R_ASIENTO.TERCER_APELLIDOS_B  ;
			MCTYPE.TERCER_CODIGO____TT_____B := R_ASIENTO.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := R_ASIENTO.TERCER_DIRECCION_B  ;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := R_ASIENTO.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(R_ASIENTO.TERCER_TELEFONO1_B)>15 THEN SUBSTR(R_ASIENTO.TERCER_TELEFONO1_B,1,15) ELSE R_ASIENTO.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGO_EDS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGO_EDS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGO_EDS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 4)='S')then
				IF(R_ASIENTO.CUENTA!='22050404') THEN
					MCTYPE.MC_____NUMDOCSOP_B := R_EGRESO.EGRESO;
				ELSE
					MCTYPE.MC_____NUMDOCSOP_B := R_EGRESO.FACTURA_TERCERO;
				END IF;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('PAGO_EDS', R_ASIENTO.TIPO_DOCUMENTO, R_ASIENTO.CUENTA,'', 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC(MCTYPE);
			CONSEC:=CONSEC+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'LOGISTICA') ='N' THEN
			SW='N';

			--BORRAMOS EL COMPROBANTE DE EXT
			DELETE FROM CON.MC____
			WHERE MC_____NUMERO____B = SECUENCIA_GEN AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'EGRN' AND  MC_____CODIGO____CD_____B = 'EGLG'  ;

			CONTINUE;
		END IF;

		-- ACTUALIZAMOS EL CAMPO DE APOTEOSYS DE LA CABECERA DEL CRéDITO PARA INDICAR QUE YA SE ENVíO
		IF(SW='S')THEN

			UPDATE
				EGRESODET
			SET
				PROCESADO='S'
			WHERE
				DOCUMENT_NO=R_EGRESO.EGRESO AND
				DOCUMENTO=R_EGRESO.FACTURA_TERCERO;

			SW:='N';
		END IF;

	END LOOP;


RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_egreso_eds_logistica_apoteosys()
  OWNER TO postgres;
