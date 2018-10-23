-- Function: con.interfaz_endoso_apoteosys()

-- DROP FUNCTION con.interfaz_endoso_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_endoso_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: CREA LOS ASIENTOS DE LOS COMPROBANTES DE ENDOSO
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-09-22
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  *
  ************************************************/

DOCUMENTOS_ RECORD;
INFOCLIENTE RECORD;
INFOITEMS_ RECORD;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
--CUENTAS_ VARCHAR[] := '{16252102, 13050901}';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;
FECHADOC_ VARCHAR:= '';
UNIDAD_NEGOCIO_ VARCHAR;
BEGIN
	/**SACAMOS LOS DOCUMENTOS CONTABLES QUE EMPIECEN POR CEN EL CUAL INDICA QUE ES ENDOSO*/
	FOR DOCUMENTOS_ IN
		select
			com.numdoc,
			com.tercero,
			com.tipodoc,periodo
		from con.comprobante com
		inner join administrativo.control_endosofiducia coen on (com.numdoc = coen.num_comprobante)
		where
		--numdoc ='CEN00000060' and
		com.numdoc ILIKE 'CEN%'
		and com.tipodoc = 'CDIAR'
		and periodo::integer >= '201701'::integer
		and com.creation_date::date <= now()::date
		and coen.procesado_en = 'N'
		group by com.numdoc,com.tercero,com.tipodoc,periodo
		order by periodo
	LOOP
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS_PRUE');

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'DIAR';
		MCTYPE.MC_____CODIGO____CD_____B := 'CDEN';
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		SECUENCIA_INT:=0;
		/**SACAMOS LOS ITEMS DE LOS DOCUMENTOS CONTABLES DE ENDOSO*/
		FOR INFOITEMS_ IN
			select
				det.numdoc as documento,
				'CDI'::VARCHAR as tipo_documento,
				case when (neg.financia_aval =  false and neg.negocio_rel = '' and fac.descripcion = 'CXC AVAL')then
					aval.proveedor else
				neg.cod_cli end as nit,
				round(det.valor_debito) as valor_debito,
				round(det.valor_credito) as valor_credito,
				det.detalle as descripcion,
				det.creation_date::date,
				det.creation_date::date as fecha_vencimiento,
				det.documento_rel,
				det.periodo,
				det.referencia_1,
				conv.agencia,
				neg.id_convenio,
				det.cuenta,
				uneg.id as unidad_neg,
				fac.descripcion as descripcion_factura,
				neg.financia_aval,
				neg.negocio_rel
			from con.comprodet det
			inner join negocios neg on (neg.cod_neg = det.referencia_1)
			inner join convenios conv on (conv.id_convenio = neg.id_convenio)
			INNER JOIN rel_unidadnegocio_convenios ruc ON (conv.id_convenio = ruc.id_convenio)
			INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
			inner join con.factura fac on ( fac.documento = det.documento_rel)
			left join fin.cxp_doc aval on (aval.documento_relacionado = neg.cod_neg and aval.proveedor in ('8904800244','8901009858')
			and aval.handle_code in ('BA','AV')and substring (aval.documento,1,2) in ('PM','PB') and aval.vlr_neto > 0)
			where numdoc = DOCUMENTOS_.numdoc
			and replace(substring(neg.f_desem,1,7),'-','')>= '201701'
			and uneg.id in ('1','12','14','22')
			and numdoc ILIKE 'CEN%'
			group by det.numdoc,det.tipodoc,neg.cod_cli,det.valor_debito,det.valor_credito,det.detalle,
			det.creation_date::date,det.creation_date::date,det.documento_rel,det.periodo,det.referencia_1,conv.agencia,neg.id_convenio,cuenta,uneg.id,fac.descripcion,
			neg.financia_aval, neg.negocio_rel,aval.proveedor
		LOOP
			/**BUSCAMOS LO LA INFORMACION DE LOS CLIENTES EN EL DETALLE DEL DOCUMENTO CONTABLE*/
			if(INFOITEMS_.unidad_neg=1)then --SI ES MICROCREDITO
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
				where nit = INFOITEMS_.nit;
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
			from  NIT D
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			where cedula = INFOITEMS_.nit;

			/**SE BUSCA LA UNIDAD DE NEGOCIO EN LA QUE ESTE RELACIONADO EL DOCUMENTO DE ENDOSO PARA PODER COLOCAR EL CENTRO DE COSTO CORRESPONDIENTE*/
			SELECT INTO UNIDAD_NEGOCIO_
				CASE WHEN (uneg.descripcion) = 'CONSUMO  FA & FB'  THEN 'CONSUMO'
				WHEN (uneg.descripcion) = 'EDUCATIVO FA & FB' THEN 'EDUCATIVO'
				ELSE uneg.descripcion end as descripcion
			FROM convenios conv
			INNER JOIN rel_unidadnegocio_convenios ruc ON (conv.id_convenio = ruc.id_convenio)
			INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
			WHERE uneg.descripcion IN ('MICROCREDITO','EDUCATIVO FA & FB','CONSUMO  FA & FB','LIBRANZA')
			AND  conv.id_convenio = INFOITEMS_.id_convenio
			ORDER BY uneg.descripcion;
			--raise notice 'UNIDAD_NEGOCIO_%',UNIDAD_NEGOCIO_;
			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(INFOITEMS_.creation_date,1,7),'-','') = INFOITEMS_.periodo THEN INFOITEMS_.creation_date::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(INFOITEMS_.periodo,1,4), SUBSTRING(INFOITEMS_.periodo,5,2)::INT)::DATE END;
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta, '', 6)='S')THEN
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_::date;
				MCTYPE.MC_____FECHVENC__B = FECHADOC_::date;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;

			MCTYPE.MC_____FECHA_____B :=FECHADOC_;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := INFOITEMS_.referencia_1;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( INFOITEMS_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( INFOITEMS_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,'', 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO', 'CC', UNIDAD_NEGOCIO_,INFOITEMS_.agencia, 2)  ; ---CENTRO DE COSTO DEPEMDE DE LA LINEA DE NEGOCIO
			MCTYPE.MC_____IDENTIFIC_TERCER_B := INFOITEMS_.nit;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_debito::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credito::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := INFOITEMS_.descripcion||' '||INFOITEMS_.fecha_vencimiento||' '||INFOITEMS_.documento_rel||' '||INFOITEMS_.documento;
			MCTYPE.MC_____FECHORCRE_B := FECHADOC_::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := FECHADOC_::TIMESTAMP;
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO',INFOITEMS_.tipo_documento,  INFOITEMS_.cuenta,'', 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO', INFOITEMS_.tipo_documento,  INFOITEMS_.cuenta,'', 4)='S')THEN
				/** SE RELIZA LA SIGUIENTE VALIDACION YA QUE AL PASAR LA CARTERA QUE TIENE AVAL INCLUIDO SE PASO EL NEGOCIO */
				if(substr(INFOITEMS_.documento_rel,length(INFOITEMS_.documento_rel)-1,length(INFOITEMS_.documento_rel)) = '00' and INFOITEMS_.descripcion_factura = 'CXC AVAL')then
					MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.referencia_1;--negocio
				else
					MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.documento_rel;--fac
				end if;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('ENDOSO', INFOITEMS_.tipo_documento,  INFOITEMS_.cuenta, '', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			raise notice 'MCTYPE %',MCTYPE;
	 		SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
	 		--SECUENCIA_INT :=SECUENCIA_INT+1;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'ENDOSO') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then
			update administrativo.control_endosofiducia set procesado_en = 'S' where num_comprobante = INFOITEMS_.documento and negocio = INFOITEMS_.referencia_1 and documento = INFOITEMS_.documento_rel;
		end if;

	END LOOP;
RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_endoso_apoteosys()
  OWNER TO postgres;
