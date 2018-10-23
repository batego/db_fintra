-- Function: con.interfaz_diferidos_apoteosys(integer)

-- DROP FUNCTION con.interfaz_diferidos_apoteosys(integer);

CREATE OR REPLACE FUNCTION con.interfaz_diferidos_apoteosys(_idunidadnegocio integer)
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: CREA LOS ASIENTOS DEDE LOS DIFERIDOS
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-07-25
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  *
  ************************************************/

NEGOCIO_ RECORD;
INFOCLIENTE RECORD;
LONGITUD numeric;
IVA numeric := 0;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
CUENTA_ASIENTO VARCHAR;
ITEMS_ASIENTOS_ integer[] := '{2,3}';--> indica la cantidad de items que tiene el asiento
ITERACIONES integer;
I integer;
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;
FECHADOC_ VARCHAR:= '';
BEGIN
	/**SACAMOS EL LISTADO DE NEGOCIOS*/
	FOR NEGOCIO_ IN
		select
			a.codneg AS cod_neg,
			uneg.id as unidad_neg,
			ng.id_convenio,
			a.cod,
			a.dstrct,
			a.tipodoc as tipo_documento,
			a.nit as tercero,
			a.cod as numdoc,
			a.valor as valor,
			a.base,
			a.cmc as hc,
			a.fecha_doc,
			a.fecha_doc::date as creation_date,
			a.periodo,
			a.fecha_doc::date as fecha_vencimiento,
			cmc.sigla_comprobante,
			cmc.cuenta,
			cmc.dbcr,
			ctas.nombre_largo as descripcion,
			CASE    WHEN substr(a.cod,1,2)=cfc.prefijo AND a.tipodoc=cfc.tipodoc THEN coalesce(cfc.cuenta_diferido,'')
				WHEN substr(a.cod,1,2)=c.prefijo_diferidos AND a.tipodoc=(select tipo_documento from series where document_type=c.prefijo_diferidos) THEN coalesce(c.cuenta_diferidos,'')
				WHEN substr(a.cod,1,2)=c.prefijo_dif_fiducia AND a.tipodoc=(select tipo_documento from series where document_type=c.prefijo_dif_fiducia) THEN coalesce(c.cuenta_dif_fiducia,'')
				WHEN substr(a.cod,1,2)=c.prefijo_cuota_administracion_diferido AND a.tipodoc=(select tipo_documento from series where document_type=c.prefijo_cuota_administracion_diferido) THEN coalesce(c.cta_cuota_admin_diferido,'')
			   ELSE ''
			END  as cuenta_diferidos,
			ng.cod_neg AS documento_rel,
			'NEG' AS tipodocRel,
			coalesce(cfc.aplica_iva,'N') as aplica_iva,
			c.agencia
		from ing_fenalco a join negocios ng on (ng.cod_neg = a.codneg)
		left join con.tipo_docto tdoc on (tdoc.dstrct = a.dstrct and tdoc.codigo_interno = a.tipodoc)
		left join con.cmc_doc cmc on (cmc.dstrct = tdoc.dstrct and cmc.tipodoc = tdoc.codigo and cmc.cmc = a.cmc)
		left join con.cuentas ctas on (cmc.cuenta=ctas.cuenta)
		left join negocios n on (n.cod_neg = a.codneg)
		left join convenios c on (c.id_convenio = n.id_convenio)
		left join convenios_cargos_fijos cfc on (c.id_convenio=cfc.id_convenio and cfc.activo = true and cfc.tipodoc=a.tipodoc)
		INNER JOIN rel_unidadnegocio_convenios ruc ON (c.id_convenio = ruc.id_convenio)
		INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
		where
		a.dstrct = 'FINV'
		and a.reg_status = ''
		and uneg.id in (_idunidadnegocio)
		and replace(substring(a.fecha_doc::date,1,7),'-','')>='201701'
		and a.fecha_doc::date <= now()::date
		and procesado_dif = 'N'
		AND a.periodo = REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
		AND a.codneg NOT IN (SELECT NEGOCIO_REESTRUCTURACION FROM REL_NEGOCIOS_REESTRUCTURACION )
		order by a.fecha_doc
	LOOP
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');

		/**BUSCAMOS LA INFORMACION DEL CLIENTE*/
		if(NEGOCIO_.unidad_neg=1)then

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
			where nit = NEGOCIO_.tercero;

		end if;


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
		where cedula = NEGOCIO_.tercero;

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'OPER';
		MCTYPE.MC_____CODIGO____CD_____B := CASE WHEN (NEGOCIO_.unidad_neg IN (1,22)) THEN  NEGOCIO_.tipo_documento ELSE  NEGOCIO_.tipo_documento||SUBSTRING(NEGOCIO_.cod_neg,1,2) END;
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		--DEPENDIENDO DEL TIPO DE DOCUMENTO SE ESCOGE EL NUMERO DE ASIENTOS INDICADOS EN EL ARRAY ITEMS_ASIENTOS_
		if(NEGOCIO_.tipo_documento in ('MI','CM','LI','IF'))then
			ITERACIONES := ITEMS_ASIENTOS_[1];
		elsif (NEGOCIO_.tipo_documento in ('CA'))then
			ITERACIONES := ITEMS_ASIENTOS_[2];
		end if;

		SECUENCIA_INT:=1;
		--SE ITERA SEGUN LA CANTIDAD DE ITEM ASIGANADAS CON LA VALIDACION ANTERIOR
		FOR I IN 1..
			ITERACIONES
		LOOP
			--SE BUSCA LA CUENTA RESPECTIVA DEL ASIENTO SEGUN LOS PARAMETROS ENVIADOS
			CUENTA_ASIENTO := con.interfaz_cuenta_diferidos_apoteosys(NEGOCIO_.tipo_documento, i, NEGOCIO_.agencia, NEGOCIO_.unidad_neg::VARCHAR);
			raise notice 'cod: %, iteracion: %, agencia: %, unidad: %, cuenta: %',NEGOCIO_.tipo_documento, 1, NEGOCIO_.agencia,NEGOCIO_.unidad_neg,CUENTA_ASIENTO;
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('DIFERIDOS',NEGOCIO_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 6)='S')THEN
				MCTYPE.MC_____FECHEMIS__B = NEGOCIO_.creation_date; --fecha creacion
				MCTYPE.MC_____FECHVENC__B = NEGOCIO_.fecha_vencimiento; --fecha vencimiento
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(NEGOCIO_.creation_date,1,7),'-','') = NEGOCIO_.periodo THEN NEGOCIO_.creation_date::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(NEGOCIO_.periodo,1,4), SUBSTRING(NEGOCIO_.periodo,5,2)::INT)::DATE END;
			MCTYPE.MC_____FECHA_____B :=FECHADOC_;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := NEGOCIO_.cod_neg;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( NEGOCIO_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( NEGOCIO_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('DIFERIDOS', NEGOCIO_.tipo_documento, CUENTA_ASIENTO,NEGOCIO_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('DIFERIDOS', NEGOCIO_.tipo_documento, CUENTA_ASIENTO,NEGOCIO_.agencia, 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := NEGOCIO_.tercero;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;

			IF(i = 1)THEN
				MCTYPE.MC_____DEBMONLOC_B := NEGOCIO_.valor::NUMERIC;
				MCTYPE.MC_____CREMONLOC_B := 0::NUMERIC;
			ELSE
				if(NEGOCIO_.aplica_iva = 'S')then
					if(i = 2)then
						MCTYPE.MC_____BASE______B := NEGOCIO_.valor::NUMERIC;
						IVA:=  NEGOCIO_.valor::NUMERIC*0.19;
						MCTYPE.MC_____CREMONLOC_B := NEGOCIO_.valor::NUMERIC*0.19;
					else
						MCTYPE.MC_____CREMONLOC_B := NEGOCIO_.valor::NUMERIC-IVA;
						MCTYPE.MC_____BASE______B := 0;
					end if;

				else
					MCTYPE.MC_____CREMONLOC_B := NEGOCIO_.valor::NUMERIC;
				end if;
				MCTYPE.MC_____DEBMONLOC_B := 0;
			END IF;

			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := NEGOCIO_.descripcion||' '||NEGOCIO_.fecha_vencimiento||' '||NEGOCIO_.cod;
			MCTYPE.MC_____FECHORCRE_B := NEGOCIO_.creation_date::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := NEGOCIO_.creation_date::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.tipo_doc;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTR(INFOCLIENTE.nombre_corto,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTR (INFOCLIENTE.nombre,1,64);
			MCTYPE.TERCER_APELLIDOS_B := SUBSTR(INFOCLIENTE.apellidos,1,32);
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.codigo;
			MCTYPE.TERCER_DIRECCION_B := SUBSTR(INFOCLIENTE.direccion,1,64);
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.codigociu;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.telefono)>15 THEN SUBSTR(INFOCLIENTE.telefono,1,15) ELSE INFOCLIENTE.telefono END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('DIFERIDOS',NEGOCIO_.tipo_documento, CUENTA_ASIENTO,NEGOCIO_.agencia, 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('DIFERIDOS', NEGOCIO_.tipo_documento, CUENTA_ASIENTO,NEGOCIO_.agencia, 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := NEGOCIO_.cod;--if
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('DIFERIDOS', NEGOCIO_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			raise notice 'MCTYPE %',MCTYPE;
	 		SW:=CON.SP_INSERT_TABLE_MC_DIFERIDOS____(MCTYPE);
	 		SECUENCIA_INT :=SECUENCIA_INT+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'DIFERIDOS') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then
			update ing_fenalco set procesado_dif = 'S' where codneg = NEGOCIO_.cod_neg and cod = NEGOCIO_.cod ;
		end if;

	END LOOP;
RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_diferidos_apoteosys(integer)
  OWNER TO postgres;
