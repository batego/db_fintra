-- Function: con.interfaz_micro_intereses_ca_mes_apoteosys()

-- DROP FUNCTION con.interfaz_micro_intereses_ca_mes_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_micro_intereses_ca_mes_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODOS LO NEGOCIOS DE MICROCREDITO Y
  *CREA EL ASIENTO CONTABLE DE LOS INTERESES CA.
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-07-10
  *LAST_UPDATE 2017-07-12
  *DESCRIPCION DE CAMBIOS Y FECHA
  *PRODUCTIVO:= 2017-07-25
  ************************************************/

NEGOCIO_ RECORD;
INFOITEMS_ RECORD;
NUMCUOTAS RECORD;
INFOCLIENTE RECORD;
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
CUENTAS_ VARCHAR[] := '{13050802,I010130014144,24080109}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;

BEGIN
	/**SACAMOS EL LISTADO DE NEGOCIOS*/
	FOR NEGOCIO_ IN

			SELECT * FROM (
				SELECT 	neg.estado_neg,
					neg.cod_neg,
					neg.cod_cli,
					neg.fecha_negocio,
					conv.agencia,
					dna.item,
					dna.fecha,
					procesado_ca,
					replace(substring(dna.fecha,1,7),'-','') AS periodo_ven,
					(select fac.periodo FROM con.factura fac WHERE negasoc =neg.cod_neg  AND fac.documento ilike 'CA%' and num_doc_fen = dna.item and fac.reg_status = '') as periodo_apoteosys,
					(select fac.valor_factura FROM con.factura fac WHERE negasoc =neg.cod_neg  AND fac.documento ilike 'CA%' and num_doc_fen = dna.item and fac.reg_status = '') as valor
				FROM documentos_neg_aceptado dna
				INNER JOIN negocios neg on (dna.cod_neg = neg.cod_neg)
				INNER JOIN convenios conv on (conv.id_convenio = neg.id_convenio)
				INNER JOIN rel_unidadnegocio_convenios ruc ON (conv.id_convenio = ruc.id_convenio)
				INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
				where
				neg.cod_neg not in (select negocio_reestructuracion from rel_negocios_reestructuracion)
				and neg.estado_neg = 'T'
				and uneg.id = '1'
				and dna.documento_cat != ''
				and dna.procesado_ca = 'N'
				and substring (neg.cod_neg,1,2)= 'MC'
				and replace(substring(dna.fecha,1,7),'-','')  >= '201701'
				--and dna.fecha <	now()::date
				and neg.cod_neg in (select cod_neg from tem.negocios_facturacion_old tem )
				and neg.cod_neg not in (select negasoc from tem.cartera_vendida_micro)
			)t
			WHERE t.periodo_apoteosys=REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
			ORDER BY periodo_ven

	LOOP
		--raise notice 'NEGOCIO_%',NEGOCIO_;
		/**BUSCAMOS LA INFORMACION DEL CLIENTE*/
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
		where nit = NEGOCIO_.cod_cli;

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT';
		MCTYPE.MC_____CODIGO____TD_____B := 'OPER';
		MCTYPE.MC_____CODIGO____CD_____B := 'CA';

		/**BUSCAMOS EL NUMERO DE CUOTAS DEL NEGOCIO PARA VGENERAR LOS DIFERENTES ASIENTOS*/
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		SECUENCIA_INT:=1;
		SW = 'N';
		/**BUSCAMOS LA COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN
			(select
				num_doc_fen,
				fac.documento,
				fac.tipo_documento,
				fac.nit,
				sum (valor_unitario) as valor_deb,
				0::numeric as valor_credt,
				fac.descripcion,
				CASE WHEN (fecha_factura::date>fecha_vencimiento::date) THEN
				   fecha_vencimiento::date
				ELSE fac.fecha_factura::date END AS  creation_date,
				fac.fecha_vencimiento::date as fecha_vencimiento,
				fac.periodo,
				CUENTAS_[1]as cuenta
			from con.factura fac
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			where negasoc = NEGOCIO_.cod_neg
			and fac.periodo != ''
			and facdet.documento ilike 'CA%'
			--and fac.periodo::integer between 201701 and 201710
			and num_doc_fen = NEGOCIO_.item
			and fac.reg_status=''
			group by num_doc_fen,fac.documento,fac.tipo_documento,fac.nit,fac.descripcion,fecha_factura,fecha_vencimiento,fac.periodo
			order by num_doc_fen::integer
			)
			union all
			(select
				num_doc_fen,
				fac.documento,
				fac.tipo_documento,
				fac.nit,
				0::numeric as valor_deb,
				valor_unitario as valor_credt,
				fac.descripcion,
				CASE WHEN (fecha_factura::date>fecha_vencimiento::date) THEN
				   fecha_vencimiento::date
				ELSE fac.fecha_factura::date END AS  creation_date,
				fac.fecha_vencimiento::date as fecha_vencimiento,
				fac.periodo,
				case when (facdet.codigo_cuenta_contable)in ('24080109','24080117')then CUENTAS_[3] else CUENTAS_[2] end as cuenta
			from con.factura fac
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			where negasoc = NEGOCIO_.cod_neg
			and fac.periodo != ''
			and facdet.documento ilike 'CA%'
			--and fac.periodo::integer between 201701 and 201710
			and num_doc_fen = NEGOCIO_.item
			and fac.reg_status=''
			order by num_doc_fen::integer
			)
		LOOP

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(INFOITEMS_.creation_date,1,7),'-','') = INFOITEMS_.periodo THEN INFOITEMS_.creation_date::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(INFOITEMS_.periodo,1,4), SUBSTRING(INFOITEMS_.periodo,5,2)::INT)::DATE END;

			IF(INFOITEMS_.tipo_documento='FAC' AND CON.OBTENER_HOMOLOGACION_APOTEOSYS('MICROCREDITO',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 6)='S')THEN
				--MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.creation_date::TIMESTAMP; --fecha creacion
				MCTYPE.MC_____FECHEMIS__B = FECHADOC_;
				--MCTYPE.MC_____FECHVENC__B = INFOITEMS_.fecha_vencimiento; --fecha vencimiento
				MCTYPE.MC_____FECHVENC__B = FECHADOC_;
			ELSE
				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
			END IF;

			MCTYPE.MC_____FECHA_____B := FECHADOC_;--CASE WHEN (INFOITEMS_.creation_date::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(INFOITEMS_.creation_date,1,7),'-','') = INFOITEMS_.periodo)  THEN INFOITEMS_.creation_date::DATE ELSE FECHADOC_::DATE END;
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := NEGOCIO_.cod_neg;
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( INFOITEMS_.periodo,1,4)::INT;
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( INFOITEMS_.periodo,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF';
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('MICROCREDITO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('MICROCREDITO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 2);
			MCTYPE.MC_____IDENTIFIC_TERCER_B := INFOITEMS_.nit;
			MCTYPE.MC_____DEBMONORI_B := 0;
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := INFOITEMS_.descripcion;
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('MICROCREDITO',INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 3);
			--RAISE NOTICE 'INFOITEMS_.cuenta%',INFOITEMS_.cuenta;
			if (INFOITEMS_.cuenta = '24080109')then
				MCTYPE.MC_____BASE______B := (SELECT cat FROM documentos_neg_aceptado where cod_neg = NEGOCIO_.cod_neg and item = INFOITEMS_.num_doc_fen)::numeric-INFOITEMS_.valor_credt;
			ELSE
				MCTYPE.MC_____BASE______B := 0;
			end if;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('MICROCREDITO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.documento;--factura
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('MICROCREDITO', INFOITEMS_.tipo_documento, INFOITEMS_.cuenta,NEGOCIO_.agencia, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			SW:=CON.SP_INSERT_TABLE_MC_MICRO____(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;
			raise notice 'INFOITEMS_ %',INFOITEMS_;
			raise notice 'MCTYPE %',MCTYPE;

		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'MICROCREDITO') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then
			--update negocios set procesado_ca = 'S' where cod_neg = NEGOCIO_.cod_neg;
			update documentos_neg_aceptado set procesado_ca = 'S' where cod_neg =  NEGOCIO_.cod_neg and item = NEGOCIO_.item;
		end if;
	END LOOP;
RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_micro_intereses_ca_mes_apoteosys()
  OWNER TO postgres;
