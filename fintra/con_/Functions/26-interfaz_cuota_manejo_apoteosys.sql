-- Function: con.interfaz_cuota_manejo_apoteosys()

-- DROP FUNCTION con.interfaz_cuota_manejo_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_cuota_manejo_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODOS LO NEGOCIOS de CONSUMO O EDUCATIVO PARA GENERAR LAS CUOTAS DE MANEJOS
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-08-15
  *LAST_UPDATE:
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

NEGOCIO_ RECORD;
INFOITEMS_ RECORD;
NUMCUOTAS RECORD;
INFOCLIENTE RECORD;
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
FECHADOC_ VARCHAR:= '';
LINEA_ VARCHAR:= '';
CUENTA_ASIENTO varchar;
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;

BEGIN
	/**SACAMOS EL LISTADO DE NEGOCIOS*/
	FOR NEGOCIO_ IN
		SELECT 	neg.estado_neg,
			uneg.id AS linea_neg,
			neg.cod_neg,
			neg.cod_cli,
			neg.fecha_negocio,
			conv.agencia,
			dna.item,
			dna.fecha,replace(substring(dna.fecha,1,7),'-','')
		FROM documentos_neg_aceptado dna
		INNER JOIN negocios neg on (dna.cod_neg = neg.cod_neg)
		INNER JOIN convenios conv on (conv.id_convenio = neg.id_convenio)
		INNER JOIN rel_unidadnegocio_convenios ruc ON (conv.id_convenio = ruc.id_convenio)
		INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
		where
		neg.cod_neg not in (select negocio_reestructuracion from rel_negocios_reestructuracion)
		and  neg.estado_neg in ('T','A')
		and uneg.id in('12')
		and dna.causar_cuota_admin = 'S'
		--and dna.procesado_cm = 'N'
		and neg.negocio_rel = ''
		AND dna.cuota_manejo_causada > 0
		and replace(substring(dna.fecha,1,7),'-','')::numeric between '201701'::numeric and '201912'::numeric
		--and dna.fecha < now()::date
		and neg.cod_neg in('FA30677',
'FA30699',
'FB04141',
'FB04142',
'FB04144',
'FB04145',
'FB04146',
'FB04148',
'FB04149',
'FB04150',
'FB04151',
'FB04154',
'FB04160',
'FB04162',
'FB04166',
'FB04167',
'FB04168',
'FB04171',
'FB04172',
'FB04175',
'FB04176',
'FB04178',
'FB04180',
'FB04185',
'FB04186',
'FB04187',
'FB04188',
'FB04189',
'FB04191',
'FB04192',
'FB04193',
'FB04194',
'FB04196',
'FB04197',
'FB04198',
'FB04201',
'FB04202',
'FB04204',
'FB04206',
'FB04208',
'FB04209',
'FB04210',
'FB04211',
'FB04212',
'FB04213',
'FB04216',
'FB04218',
'FB04219',
'FB04225',
'FB04229',
'FB04232',
'FB04234',
'FB04235')
		order by neg.cod_neg
	LOOP
		/**BUSCAMOS LA INFORMACION DEL CLIENTE*/
		select INTO INFOCLIENTE
			(CASE
			WHEN tipo_iden ='CED' THEN 'CC'
			WHEN tipo_iden ='RIF' THEN 'CE'
			WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
			'CC' END) as tipo_doc,
			(CASE
			WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'
			WHEN tipo_iden in  ('CED')  THEN 'RSCP' else 'RSCP'
			END) as codigo,
			(CASE
			WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
			ELSE '08001' END) as codigociu,
			(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
			(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
			*
		from  NIT D
		LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
		where cedula = NEGOCIO_.cod_cli;

		/***SE PREGUNTA QUE LINEA ES PARA PASAR EL FILTRO CORRESPONDIENTE */
		IF(NEGOCIO_.linea_neg = '12')THEN
			LINEA_:= 'EDUCATIVO';
		ELSIF (NEGOCIO_.linea_neg = '14')THEN
			LINEA_:='CONSUMO';
		END IF;

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'OPER';
		MCTYPE.MC_____CODIGO____CD_____B := 'CM'||substring(NEGOCIO_.cod_neg,1,2);

		/**CON EL NUMERO DE CUOTA EXTRAIDO SE BUSCA LA FACTURA Y SE GENERA EL ASIENTO*/
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');---PRUEBA
		--SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');--PRODUCTIVO
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		/**BUSCAMOS LA COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN
			(select
				num_doc_fen,
				'1'::integer as iteracion,
				fac.documento,
				fac.tipo_documento,
				fac.nit,
				fac.valor_factura as valor_deb,
				0::numeric as valor_credt,
				fac.descripcion,
				CASE WHEN (fecha_factura::date>fecha_vencimiento::date) THEN
				   fecha_vencimiento::date
				ELSE fac.fecha_factura::date END AS  creation_date,
				fac.fecha_vencimiento::date as fecha_vencimiento,
				fac.periodo
			FROM con.factura fac
			WHERE negasoc = NEGOCIO_.cod_neg
			AND fac.documento ilike 'CM%'
			and num_doc_fen = NEGOCIO_.item
			and fac.reg_status = ''
			and fac.periodo != ''
			and fac.periodo > 201612
			order by num_doc_fen::integer
			)
			uniON ALL
			(select
				num_doc_fen,
				'2'::integer as iteracion,
				fac.documento,
				fac.tipo_documento,
				fac.nit,
				0::numeric as valor_deb,
				fac.valor_factura as valor_credt,
				fac.descripcion,
				CASE WHEN (fecha_factura::date>fecha_vencimiento::date) THEN
				   fecha_vencimiento::date
				ELSE fac.fecha_factura::date END AS  creation_date,
				fac.fecha_vencimiento::date as fecha_vencimiento,
				fac.periodo
			from con.factura fac
			where negasoc = NEGOCIO_.cod_neg
			and fac.documento ilike 'CM%'
			and num_doc_fen = NEGOCIO_.item
			and fac.reg_status = ''
			and fac.periodo != ''
			and fac.periodo > 201612
			order by num_doc_fen::integer
			)
		LOOP
			CUENTA_ASIENTO := con.interfaz_cuenta_cuotadmin_apoteosys('CM'||substring(NEGOCIO_.cod_neg,1,2), INFOITEMS_.iteracion, NEGOCIO_.agencia,NEGOCIO_.linea_neg::varchar);
			RAISE notice 'cuenta %',LINEA_||' '||INFOITEMS_.tipo_documento||' '||CUENTA_ASIENTO||' '||NEGOCIO_.agencia||' '||2;
			IF(INFOITEMS_.tipo_documento='FAC' AND CON.OBTENER_HOMOLOGACION_APOTEOSYS(LINEA_,INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 6)='S')THEN
				MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.creation_date; --fecha creacion
				MCTYPE.MC_____FECHVENC__B = INFOITEMS_.fecha_vencimiento; --fecha vencimiento
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(INFOITEMS_.creation_date,1,7),'-','') = INFOITEMS_.periodo THEN INFOITEMS_.creation_date::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(INFOITEMS_.periodo,1,4), SUBSTRING(INFOITEMS_.periodo,5,2)::INT)::DATE END;
			MCTYPE.MC_____FECHA_____B := FECHADOC_;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := NEGOCIO_.cod_neg;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( INFOITEMS_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( INFOITEMS_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(LINEA_, INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(LINEA_, INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := INFOITEMS_.nit;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := INFOITEMS_.descripcion;
			MCTYPE.MC_____FECHORCRE_B := INFOITEMS_.creation_date::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := INFOITEMS_.creation_date::TIMESTAMP;
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS(LINEA_,INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS(LINEA_, INFOITEMS_.tipo_documento, CUENTA_ASIENTO,NEGOCIO_.agencia, 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.documento; -->factura
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS(LINEA_, INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			raise notice 'INFOITEMS_ %',INFOITEMS_;
			raise notice 'MCTYPE %',MCTYPE;
			SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;
		END LOOP;
 		SECUENCIA_INT:=1;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,LINEA_) ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then
			update documentos_neg_aceptado set procesado_cm = 'S' where cod_neg =  NEGOCIO_.cod_neg and item = NEGOCIO_.item;
		end if;

	END LOOP;
RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_cuota_manejo_apoteosys()
  OWNER TO postgres;
