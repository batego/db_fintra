-- Function: con.interfaz_recaudos_almacenes_cadena()

-- DROP FUNCTION con.interfaz_recaudos_almacenes_cadena();

CREATE OR REPLACE FUNCTION con.interfaz_recaudos_almacenes_cadena()
  RETURNS text AS
$BODY$

DECLARE

	r0_detalle record;
	r0_infoitems_ record;
	INFOCLIENTE RECORD;
	SECUENCIA_GEN INTEGER;
	FECHADOC_ TEXT:='';
	MCTYPE CON.TYPE_INSERT_MC;
	SW TEXT:='N';
	CONSEC INTEGER:=1;

BEGIN

	-- 2. Buscamos las Factura R0 para armar la transaccion
	FOR r0_detalle IN
		select
			fac.tipo_documento,
			fac.documento,
			(substring(fac.descripcion,strpos(fac.descripcion,'/')+4,4)||'-'||substring(fac.descripcion,strpos(fac.descripcion,'/')+1,2)||'-'||substring(fac.descripcion,strpos(fac.descripcion,'/')-2,2))::date as fecha_consignacion,
			fac.nit,
			fac.descripcion,
			fac.periodo,
			fac.valor_factura,
			fac.cmc,
			cmc.cuenta,
			facd.codigo_cuenta_contable
		from
			con.factura fac
		inner join con.factura_detalle facd on(facd.tipo_documento=fac.tipo_documento and facd.documento=fac.documento)
		inner join con.cmc_doc cmc on(cmc.cmc=fac.cmc and cmc.tipodoc=fac.tipo_documento)
		where
			fac.documento ilike 'R0%' and
			fac.cmc='SE' and
			fac.periodo='201701' -- and
-- 			coalesce(fac.procesado,'N')='N'
			--AND fac.documento='R0032292'

		/**
		select con.interfaz_recaudos_almacenes_cadena();
		select * from con.mc_fenalco____ where procesado='N'
		delete from con.mc_fenalco____ where procesado='R' and MC_____CODIGO____CD_____B = 'CRIS'
		select CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', 'FAC', '11050527','', 1)  ;
		*/

	loop

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');
		-- 2.2. Este query arma la transaccion que se mandara hacia apoteosys
		raise notice 'r0_detalle: %',r0_detalle;

		for r0_infoitems_ in
			select
				tipo_documento,
				num_ingreso,
				nitcli,
				r0_detalle.cuenta as cuenta,
				con.interfaz_obtener_centro_costo_x_ingreso(num_ingreso,1) as cu,
				con.interfaz_obtener_centro_costo_x_ingreso(num_ingreso,2) as negocio,
				vlr_ingreso as valor_debito,
				0 as valor_credito,
				'' as factura,
				fecha_ingreso,
				periodo,
				descripcion_ingreso||'->'||num_ingreso as descripcion
			from
				con.ingreso
			where
				(tipo_documento,num_ingreso) in(select tipo_documento, num_ingreso from con.ingreso where fecha_consignacion=r0_detalle.fecha_consignacion and branch_code='SUPEREFECTIVO' and reg_status='') and
				reg_status='' and vlr_ingreso!=0
			union all
			select
				tipo_documento,
				num_ingreso,
				nitcli,
				r0_detalle.codigo_cuenta_contable as cuenta,
				con.interfaz_obtener_centro_costo_x_ingreso(num_ingreso,1) as cu,
				con.interfaz_obtener_centro_costo_x_ingreso(num_ingreso,2) as negocio,
				0 as valor_debito,
				valor_ingreso as valor_credito,
				factura,
				fecha_factura,
				periodo,
				descripcion||'->'||num_ingreso as descripcion
			from
				con.ingreso_detalle
			where
				(tipo_documento,num_ingreso) in(select tipo_documento, num_ingreso from con.ingreso where fecha_consignacion=r0_detalle.fecha_consignacion and branch_code='SUPEREFECTIVO' and reg_status='') and
				reg_status='' and valor_ingreso!=0
			order by
				num_ingreso

		loop

			----------------------------
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
				codcli in (select codcli from con.ingreso where num_ingreso=r0_infoitems_.num_ingreso);
			----------------------------

			raise notice 'r0_infoitems_: %',r0_infoitems_;

			-- Insertamos en la tabla de Apoteosys
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(r0_detalle.fecha_consignacion::DATE,1,7),'-','')=r0_detalle.periodo THEN r0_detalle.fecha_consignacion::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(r0_detalle.periodo,1,4),SUBSTRING(r0_detalle.periodo,5,2)::INT)::DATE END ;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', r0_detalle.tipo_documento, r0_infoitems_.CUENTA,'', 6)='S')then
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::DATE;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::DATE;
			else
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			end if;

			MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
			MCTYPE.MC_____CODIGO____TD_____B := 'CXCN' ;
			MCTYPE.MC_____CODIGO____CD_____B := 'CRIS'  ;
			MCTYPE.MC_____SECUINTE__DCD____B := CONSEC  ;
			MCTYPE.MC_____FECHA_____B := FECHADOC_::DATE  ;
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ;
			MCTYPE.MC_____SECUINTE__B := CONSEC  ;
			MCTYPE.MC_____REFERENCI_B := r0_detalle.DOCUMENTO  ;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING(r0_detalle.PERIODO,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING(r0_detalle.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF' ;
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', r0_detalle.tipo_documento, r0_infoitems_.CUENTA,'', 1)  ;
			MCTYPE.MC_____CODIGO____CU_____B := r0_infoitems_.cu;
			MCTYPE.MC_____IDENTIFIC_TERCER_B :=  CASE WHEN CHAR_LENGTH(r0_infoitems_.nitcli)>10 THEN SUBSTR(r0_infoitems_.nitcli,1,10) ELSE r0_infoitems_.nitcli END;
			MCTYPE.MC_____DEBMONORI_B := 0  ;
			MCTYPE.MC_____CREMONORI_B := 0 ;
			MCTYPE.MC_____DEBMONLOC_B := r0_infoitems_.VALOR_DEBITO::NUMERIC  ;
			MCTYPE.MC_____CREMONLOC_B := r0_infoitems_.VALOR_CREDITO::NUMERIC  ;
			MCTYPE.MC_____INDTIPMOV_B := 4  ;
			MCTYPE.MC_____INDMOVREV_B := 'N'  ;
			MCTYPE.MC_____OBSERVACI_B := r0_infoitems_.DESCRIPCION ;
			MCTYPE.MC_____FECHORCRE_B := r0_detalle.fecha_consignacion::TIMESTAMP  ;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN'  ;
			MCTYPE.MC_____FEHOULMO__B := r0_detalle.fecha_consignacion::TIMESTAMP  ;
			MCTYPE.MC_____AUTULTMOD_B := ''  ;
			MCTYPE.MC_____VALIMPCON_B := 0  ;
			MCTYPE.MC_____NUMERO_OPER_B := r0_detalle.DOCUMENTO;

			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.TERCER_CODIGO____TIT____B  ;
			MCTYPE.TERCER_NOMBCORT__B := INFOCLIENTE.TERCER_NOMBCORT__B  ;
			MCTYPE.TERCER_NOMBEXTE__B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_NOMBEXTE__B)>64 then substr(INFOCLIENTE.TERCER_NOMBEXTE__B,1,64) ELSE INFOCLIENTE.TERCER_NOMBEXTE__B END;
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.TERCER_APELLIDOS_B  ;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.TERCER_CODIGO____TT_____B  ;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_DIRECCION_B)>64 then substr(INFOCLIENTE.TERCER_DIRECCION_B,1,64) ELSE INFOCLIENTE.TERCER_DIRECCION_B END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.TERCER_CODIGO____CIUDAD_B  ;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TERCER_TELEFONO1_B)>15 THEN SUBSTR(INFOCLIENTE.TERCER_TELEFONO1_B,1,15) ELSE INFOCLIENTE.TERCER_TELEFONO1_B END;
			MCTYPE.TERCER_TIPOGIRO__B := 1 ;
			MCTYPE.TERCER_CODIGO____EF_____B := ''  ;
			MCTYPE.TERCER_SUCURSAL__B := ''  ;
			MCTYPE.TERCER_NUMECUEN__B := ''  ;
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', r0_detalle.tipo_documento, r0_infoitems_.CUENTA,'', 3);
			--MCTYPE.MC_____NUMDOCSOP_B := REC_OS.NUMERO_OPERACION;
			MCTYPE.MC_____NUMEVENC__B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', r0_detalle.tipo_documento, r0_infoitems_.CUENTA,'', 5)::INT;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', r0_detalle.tipo_documento, r0_infoitems_.CUENTA,'', 4)='S')then
				MCTYPE.MC_____NUMDOCSOP_B := r0_infoitems_.negocio;
			else
				MCTYPE.MC_____NUMDOCSOP_B := '';
			end if;

			if(CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', r0_detalle.tipo_documento, r0_infoitems_.CUENTA,'', 5)::int=1)then
				MCTYPE.MC_____NUMEVENC__B := 1;
			else
				MCTYPE.MC_____NUMEVENC__B := null;
			end if;

			-- Insertamos en la tabla de Apoteosys
			--FUNCION QUE TRANSACCION POR TIPO DE DOCUMENTO EN TABLA TEMPORAL EN FINTRA.
			SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
			CONSEC:=CONSEC+1;

		end loop;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE, 'CONSUMO') ='N' THEN
			SW='N';

			--BORRAMOS EL COMPROBANTE DE EXT
			DELETE FROM CON.MC_FENALCO____
			WHERE MC_____NUMERO____B = SECUENCIA_EXT AND MC_____CODIGO____CONTAB_B = 'FINT'
			 AND MC_____CODIGO____TD_____B = 'CXCN' AND  MC_____CODIGO____CD_____B = 'CRIS'  ;

			CONTINUE;
		END IF;

		IF(SW='S')THEN
			-- MARCAMOS EN DETALLE DEL CRéDITO QUE YA SE ENVíO A APOTEOSYS
			UPDATE
				con.factura
			SET
				PROCESADO = 'S'
			WHERE
				DOCUMENTO = R0_DETALLE.DOCUMENTO;

			SW:='N';
		END IF;

		CONSEC:=1;

	end loop;

return 'OK';
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_recaudos_almacenes_cadena()
  OWNER TO postgres;
