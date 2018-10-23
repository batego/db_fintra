-- Function: con.interfaz_consumo_apoteosys()

-- DROP FUNCTION con.interfaz_consumo_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_consumo_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODOS LO NEGOCIOS CONSUMO.
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-08-10
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

NEGOCIO_ RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
num_cuota_invalida integer;
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
RESPUESTA TEXT:='N';
validaciones text;
CUENTA_ASIENTO varchar;

BEGIN
	/**SACAMOS EL LISTADO DE NEGOCIOS PADRES*/
	FOR NEGOCIO_ IN
		select neg.financia_aval,
			neg.negocio_rel,
			uneg.id as unidad_neg,
			neg.cod_neg,
			neg.cod_cli,
			neg.fecha_negocio,
			sola.renovacion,
			conv.agencia
		from negocios neg
		inner join convenios conv on (conv.id_convenio = neg.id_convenio)
		INNER JOIN rel_unidadnegocio_convenios ruc ON (conv.id_convenio = ruc.id_convenio)
		INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
		inner join solicitud_aval sola on (sola.cod_neg = neg.cod_neg)
		where neg.estado_neg = 'T' and uneg.id = '14'
		and procesado_mc = 'N'
		AND neg.cod_neg not in (select negocio_reestructuracion from rel_negocios_reestructuracion)
		and neg.financia_aval = true
		and neg.negocio_rel = ''
		and replace(substring(neg.f_desem,1,7),'-','') = '201709'
	LOOP
-- 		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');
		SECUENCIA_INT:=1;
		raise notice 'NEGOCIO: %',NEGOCIO_.cod_neg;
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
			else 'RSCP'
			END) as codigo,
			(CASE
			WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
			ELSE '08001' END) as codigociu,
			(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
			(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
			*
		from  NIT D --ON(D.CEDULA=prov.NIT)
		LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
		where cedula = NEGOCIO_.cod_cli;
		--Regimen simplicado RSCP
		--Regimen comun RCOM

		MCTYPE.MC_____CODIGO____CONTAB_B := 'FINT' ;
		MCTYPE.MC_____CODIGO____TD_____B := 'OPER' ;
		MCTYPE.MC_____CODIGO____CD_____B := substring(NEGOCIO_.cod_neg,1,2);
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN  ; --SECUENCIA GENERAL

		select into num_cuota_invalida count(*) from con.factura where negasoc = NEGOCIO_.cod_neg and char_length(num_doc_fen)>2;

		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		if(num_cuota_invalida > 0)then
			continue;
		else
			FOR INFOITEMS_ IN
				(select
					'cartera' as descr,
					1::integer AS iteracion,
					num_doc_fen,
					fac.documento,
					fac.tipo_documento,
					fac.nit,
					sum (valor_unitario) as valor_deb,
					0::numeric as valor_credt,
					'CARTERA FENALCO' AS descripcion,
					f_desem::date as creation_date,
					fac.fecha_vencimiento,
					replace(substring(f_desem,1,7),'-','') as periodo
				from con.factura fac
				inner join negocios neg on (fac.negasoc = neg.cod_neg)
				inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
				where negasoc = NEGOCIO_.cod_neg
				and fac.reg_status = ''
				and facdet.reg_status = ''
				and valor_unitario <> 0
				group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.documento
				order by num_doc_fen::integer
				)
				union all
				(select
					'interes' as descr,
					2::integer AS iteracion,
					num_doc_fen,
					fac.documento,
					'NEG' as tipo_documento,
					fac.nit,
					0::numeric as valor_deb,
					sum (valor_unitario) as valor_credt,
					fac.descripcion,
					f_desem::date as creation_date,
					fac.fecha_vencimiento,
					replace(substring(f_desem,1,7),'-','') as periodo
				from con.factura fac
				inner join negocios neg on (fac.negasoc = neg.cod_neg)
				inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
				where negasoc = NEGOCIO_.cod_neg
				and facdet.descripcion in ('INTERESES')
				and fac.reg_status = ''
				and facdet.reg_status = ''and valor_unitario <> 0
				group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,fac.documento
				order by num_doc_fen::integer
				)
				union all
				((select
					'cuota admin' as descr,
					3::integer AS iteracion,
					num_doc_fen,
					fac.documento,
					'NEG' as tipo_documento,
					fac.nit,
					0::numeric as valor_deb,
					sum (valor_unitario) as valor_credt,
					fac.descripcion,
					f_desem::date as creation_date,
					fac.fecha_vencimiento,
					replace(substring(f_desem,1,7),'-','') as periodo
				from con.factura fac
				inner join negocios neg on (fac.negasoc = neg.cod_neg)
				inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
				where negasoc = NEGOCIO_.cod_neg
				and facdet.descripcion in ('CUOTA-ADMINISTRACION')
				and fac.reg_status = ''
				and facdet.reg_status = ''and valor_unitario <> 0
				group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,fac.documento
				order by num_doc_fen::integer)
				union all
				(select
					'cuota admin' as descr,
					3::integer AS iteracion,
					num_doc_fen,
					fac.documento,
					'NEG' as tipo_documento,
					fac.nit,
					0::numeric as valor_deb,
					sum (valor_unitario) as valor_credt,
					fac.descripcion,
					f_desem::date as creation_date,
					fac.fecha_vencimiento,
					replace(substring(f_desem,1,7),'-','') as periodo
				from con.factura fac
				inner join negocios neg on (fac.negasoc = neg.cod_neg)
				inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
				where negasoc = NEGOCIO_.cod_neg
				and fac.reg_status = ''
				and fac.documento ilike 'CM%'
				and facdet.reg_status = ''and valor_unitario <> 0
				group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,fac.documento
				order by num_doc_fen::integer)
				)union all
				(SELECT
					'fenalco' as descr,
					4::integer AS iteracion,
					'1' as num_doc_fen,
					'' as documento,
					cxp.tipo_documento,
					cxp.proveedor,
					0::numeric as valor_deb,
					vlr_neto as valor_credt,
					cxp.descripcion,
					f_desem::date as creation_date,
					f_desem::date as fecha_vencimiento,
					replace(substring(f_desem,1,7),'-','') as periodo
				from fin.cxp_doc cxp
				inner join negocios neg on ( neg.cod_neg = cxp.documento_relacionado)
				WHERE documento_relacionado in (NEGOCIO_.cod_neg)
				and vlr_neto <> 0
				and cxp.reg_status = ''
				and substring (cxp.documento,1,2) in ('PM','PB')
				group by neg.cod_neg,cxp.tipo_documento,cxp.proveedor,cxp.descripcion,f_desem,vlr_neto
				)
				union all
				(select
					'remesa' as descr,
					5::integer AS iteracion,
					num_doc_fen,
					fac.documento,
					'NEG' as tipo_documento,
					fac.nit,
					0::numeric as valor_deb,
					sum (valor_unitario) as valor_credt,
					fac.descripcion,
					f_desem::date as creation_date,
					fac.fecha_vencimiento,
					replace(substring(f_desem,1,7),'-','') as periodo
				from con.factura fac
				inner join negocios neg on (fac.negasoc = neg.cod_neg)
				inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
				where negasoc = NEGOCIO_.cod_neg
				and facdet.descripcion in ('REMESA')
				and fac.reg_status = ''
				and facdet.reg_status = ''and valor_unitario <> 0
				group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,fac.documento
				order by num_doc_fen::integer
				)
			LOOP
				CUENTA_ASIENTO := con.interfaz_cuenta_diferidos_apoteosys(substring(NEGOCIO_.cod_neg,1,2), INFOITEMS_.iteracion, NEGOCIO_.agencia,NEGOCIO_.unidad_neg::varchar);
				raise notice 'cod: %, iteracion: %, agencia: %, cuenta: %',substring(NEGOCIO_.cod_neg,1,2), INFOITEMS_.iteracion, NEGOCIO_.agencia,CUENTA_ASIENTO;
				IF(INFOITEMS_.tipo_documento in ('FAC','FAP','NEG') AND CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO',INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 6)='S')THEN
					MCTYPE.MC_____FECHVENC__B = INFOITEMS_.fecha_vencimiento; --fecha vencimiento
					if (INFOITEMS_.fecha_vencimiento < INFOITEMS_.creation_date)then /** se valida si la fecha de vencimeinto es menor a la de creacion*/
						MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.fecha_vencimiento; --fecha creacion
					else
						MCTYPE.MC_____FECHEMIS__B = INFOITEMS_.creation_date; --fecha creacion
					end if;

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
				MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 1);
				MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 2);
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
				MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO',INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 3);
				IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.tipo_documento, CUENTA_ASIENTO,NEGOCIO_.agencia, 4)='S')THEN
					if(INFOITEMS_.descr in ('fenalco'))then
						MCTYPE.MC_____NUMDOCSOP_B := NEGOCIO_.cod_neg; -->factura
					else
						MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.documento;
					end if;
				ELSE
					MCTYPE.MC_____NUMDOCSOP_B := '';
				END IF;

				IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CONSUMO', INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 5)::INT=1)THEN
					MCTYPE.MC_____NUMEVENC__B := 1;
				ELSE
					MCTYPE.MC_____NUMEVENC__B := NULL;
				END IF;

				--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
				SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
				SECUENCIA_INT := SECUENCIA_INT + 1;

				--raise notice 'valor_deb: % valor_credt: %',INFOITEMS_.valor_deb,INFOITEMS_.valor_credt;
			END LOOP;
		end if;
		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'CONSUMO') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		raise notice 'MCTYPE:1 %',MCTYPE;
		if(SW = 'S')then
			--raise notice 'paso1: %',NEGOCIO_.cod_neg;
			RESPUESTA := con.interfaz_consumo_aval_apoteosys(NEGOCIO_.cod_neg, MCTYPE.MC_____NUMERO____B, MCTYPE.MC_____CODIGO____TD_____B, MCTYPE.MC_____CODIGO____CD_____B,INFOITEMS_.creation_date::date);
			IF(RESPUESTA = 'N')then
				CONTINUE;
			end if;
			update negocios set procesado_mc = 'S' where cod_neg = NEGOCIO_.cod_neg;
		end if;

	END LOOP;
RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_consumo_apoteosys()
  OWNER TO postgres;
