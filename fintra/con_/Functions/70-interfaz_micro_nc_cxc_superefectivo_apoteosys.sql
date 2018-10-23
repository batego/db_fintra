-- Function: con.interfaz_micro_nc_cxc_superefectivo_apoteosys()

-- DROP FUNCTION con.interfaz_micro_nc_cxc_superefectivo_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_micro_nc_cxc_superefectivo_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODAS LAS NOTAS CREDITOS
  * DE SUPERFECTIVO Y CREA EL ASIENTO CONTABLE.
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
			ing.tipo_documento,
			ing.num_ingreso,
			ing.periodo,
			fecha_ingreso,
			fecha_ingreso as fecha_vencimiento,
			ing.periodo
		from
			con.ingreso ing
		inner join
			con.ingreso_detalle ingd on(ingd.tipo_documento=ing.tipo_documento and ingd.num_ingreso=ing.num_ingreso)
		where
			ing.tipo_documento='ICA' and
			cmc in('SE','SU') and
			ing.periodo BETWEEN '201801' AND replace(substring(CURRENT_date,1,7),'-','') and
			ing.nitcli='890104964' and
			coalesce(ingd.procesado_ica,'N')='N'
		group by
			ing.tipo_documento,
			ing.num_ingreso,
			ing.fecha_ingreso,
			ing.periodo
		order by
			ing.periodo

		--select con.interfaz_micro_nc_cxc_superefectivo_apoteosys()
		/**
		select * from con.mc_micro____ where MC_____CODIGO____TD_____B = 'CXPN' and MC_____CODIGO____CD_____B = 'NCSU' and procesado='N' ORDER BY MC_____NUMERO____B, MC_____SECUINTE__B
		delete from con.mc_micro____ where MC_____CODIGO____TD_____B = 'CXPN' and MC_____CODIGO____CD_____B = 'NCSU' and procesado='N'
		*/

	loop

		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_CXP_APOTEOSYS');

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'CXPN';
		MCTYPE.MC_____CODIGO____CD_____B := 'NCSU';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL
		SECUENCIA_INT :=1;

		FOR INFOITEMS_ IN

			select
				tipo_documento,
				num_ingreso,
				cuenta,
				periodo,
				nitcli as nit,
				vlr_ingreso as valor_deb,
				0.00 as valor_credt,
				descripcion_ingreso as descripcion,
				'' as factura
			from
				con.ingreso
			where
				tipo_documento=NOTAS_.tipo_documento and
				num_ingreso=NOTAS_.num_ingreso
			union all
			select
				tipo_documento,
				num_ingreso,
				cuenta,
				periodo,
				nitcli as nit,
				0.00 as valor_deb,
				valor_ingreso as valor_credt,
				descripcion,
				factura
			from
				con.ingreso_detalle
			where
				tipo_documento=NOTAS_.tipo_documento and
				num_ingreso=NOTAS_.num_ingreso

		loop

			/**BUSCAMOS LA INFORMACION DEL CLIENTE*/
			select INTO INFOCLIENTE
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				else
				'RSCP'
				END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				*
			from  NIT D --ON(D.CEDULA=prov.NIT)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			where cedula = INFOITEMS_.NIT;

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(notas_.fecha_ingreso,1,7),'-','') = notas_.periodo THEN notas_.fecha_ingreso::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(notas_.periodo,1,4), SUBSTRING(notas_.periodo,5,2)::INT)::DATE END;

			iF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER1',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,'', 6)='S')THEN
				MCTYPE.MC_____FECHVENC__B = INFOITEMS_.fecha_vencimiento; --fecha vencimiento
					if (INFOITEMS_.fecha_vencimiento < NOTAS_.fecha_ingreso)then /** se valida si la fecha de vencimeinto es menor a la de creacion*/
						MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.fecha_vencimiento; --fecha creacion
					else
						MCTYPE.MC_____FECHEMIS__B = NOTAS_.fecha_ingreso; --fecha creacion
					end if;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;

			------------------------------------------------------------------------------------------------------------------------------------------------------------
			MCTYPE.MC_____FECHA_____B := CASE WHEN (NOTAS_.fecha_ingreso::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(NOTAS_.fecha_ingreso,1,7),'-','') = notas_.periodo)  THEN NOTAS_.fecha_ingreso::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := notas_.num_ingreso;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( notas_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( notas_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER1', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,'', 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER1', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,'', 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := CASE WHEN CHAR_LENGTH(INFOITEMS_.nit)>9 AND INFOCLIENTE.TIPO_DOC='NIT' THEN SUBSTR(INFOITEMS_.nit,1,9) ELSE INFOITEMS_.nit END;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := CASE WHEN CHAR_LENGTH(INFOITEMS_.descripcion)>255 THEN SUBSTR(INFOITEMS_.descripcion,1,255) ELSE INFOITEMS_.descripcion END;
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER1',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,'', 3);

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER1', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,'', 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.factura;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('NC_SUPER1', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--numero de cuotas
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

 			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
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
				con.ingreso_detalle
			set
				procesado_ica='S'
			where
				tipo_documento=NOTAS_.tipo_documento and
				num_ingreso=NOTAS_.num_ingreso;

		end if;

	end loop;

	RETURN 'OK';

end;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_micro_nc_cxc_superefectivo_apoteosys()
  OWNER TO postgres;
