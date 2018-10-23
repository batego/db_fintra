-- Function: con.interfaz_educativo_aval_financiado()

-- DROP FUNCTION con.interfaz_educativo_aval_financiado();

CREATE OR REPLACE FUNCTION con.interfaz_educativo_aval_financiado()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODOS LO NEGOCIOS EDUCATIVOS.
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-07-19  RETOMADO:2017-07-31
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/

NEGOCIO_ RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
RESPUESTA TEXT:='N';
validaciones text;
CUENTA_ASIENTO varchar;

BEGIN
	/**SACAMOS EL LISTADO DE NEGOCIOS PADRES*/
	FOR NEGOCIO_ IN
		select neg.financia_aval,neg.negocio_rel,
			neg.cod_neg,
			neg.cod_cli,
			neg.fecha_negocio,
			sola.renovacion,
			conv.agencia,
			uneg.id as unidad_neg
		from negocios neg
		inner join convenios conv on (conv.id_convenio = neg.id_convenio)
		INNER JOIN rel_unidadnegocio_convenios ruc ON (conv.id_convenio = ruc.id_convenio)
		INNER JOIN unidad_negocio uneg ON (uneg.id = ruc.id_unid_negocio)
		inner join solicitud_aval sola on (sola.cod_neg = neg.cod_neg)
		where neg.estado_neg = 'T' and uneg.id = '12'
		and procesado_mc = 'N'
		AND neg.cod_neg not in (select negocio_reestructuracion from rel_negocios_reestructuracion)
		and neg.financia_aval = true
		and neg.negocio_rel = ''
		and replace(substring(neg.f_desem,1,7),'-','')=REPLACE(SUBSTRING(CURRENT_DATE,1,7),'-','')
		--and neg.cod_neg = 'MC07877'

/**
select con.interfaz_educativo_aval_financiado();

delete from con.mc_fenalco____ where procesado='N'

select MC_____CODIGO____PF_____B,MC_____NUMERO____PERIOD_B ,procesado, COUNT(0)--,MC_____NUMEVENC__B
from con.mc_fenalco____
where MC_____CODIGO____CD_____B in ('FA','FB','FAV','FBV') and procesado in ('N','R') --and MC_____CODIGO____CPC____B = '23050101'
group by MC_____CODIGO____PF_____B,MC_____NUMERO____PERIOD_B ,procesado
order by MC_____CODIGO____PF_____B,MC_____NUMERO____PERIOD_B
*/

	LOOP
		SELECT INTO SECUENCIA_GEN NEXTVAL('CON.INTERFAZ_SECUENCIA_OPER_APOTEOSYS');

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
		SECUENCIA_INT:=1;
		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/
		FOR INFOITEMS_ IN
			(select
				'cartera' as descr,
				1::integer AS iteracion,
				fac.documento,
				num_doc_fen,
				fac.tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE fac.nit END AS nit,
				--fac.nit,
				sum (valor_unitario) as valor_deb,
				0::numeric as valor_credt,
				'CARTERA FENALCO' AS descripcion,
				f_desem::date as creation_date,
				fac.fecha_vencimiento,
				replace(substring(f_desem,1,7),'-','') as periodo,
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				D.NOMBRE,
				D.DIRECCION,
				D.TELEFONO
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			LEFT JOIN NIT D ON(D.CEDULA=fac.nit)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=fac.nit)
			where negasoc = NEGOCIO_.cod_neg
			and fac.reg_status = ''
			and facdet.reg_status = ''
			and valor_unitario > 0
			group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.documento, HT.NIT_APOTEOSYS
			,tipo_iden, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
			order by num_doc_fen::integer
			)
			union all
			((select
				'cuota admin' as descr,
				2::integer AS iteracion,
				B.documento,
				num_doc_fen,
				'NEG' as tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE fac.nit END AS nit,
				--fac.nit,
				0::numeric as valor_deb,
				sum (valor_unitario) as valor_credt,
				fac.descripcion,
				f_desem::date as creation_date,
				fac.fecha_vencimiento,
				replace(substring(f_desem,1,7),'-','') as periodo,
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				D.NOMBRE,
				D.DIRECCION,
				D.TELEFONO
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			inner  JOIN (SELECT CODNEG,
					       SUBSTRING(COD,1,2) AS PREFIJO,
					       COD AS DOCUMENTO,
					       LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00') AS CUOTA,
					       FECHA_DOC::DATE AS FECHA_VEN,
					       VALOR
					FROM ING_FENALCO WHERE tipodoc='CM'
					ORDER BY
					COD,LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00')::INTEGER
				     ) B on (FAC.NEGASOC=B.CODNEG AND LPAD(SUBSTRING(FAC.DOCUMENTO,8,2),2,'00') =B.CUOTA)
			LEFT JOIN NIT D ON(D.CEDULA=fac.nit)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=fac.nit)
			where negasoc = NEGOCIO_.cod_neg
			and facdet.descripcion in ('CUOTA-ADMINISTRACION')
			and fac.reg_status = ''
			and facdet.reg_status = ''and valor_unitario > 0
			group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,B.documento,HT.NIT_APOTEOSYS
			,tipo_iden, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
			order by num_doc_fen::integer)
			union all
			(select
				'cuota admin' as descr,
				2::integer AS iteracion,
				fac.documento,
				num_doc_fen,
				'NEG' as tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE fac.nit END AS nit,
				--fac.nit,
				0::numeric as valor_deb,
				sum (valor_unitario) as valor_credt,
				fac.descripcion,
				f_desem::date as creation_date,
				fac.fecha_vencimiento,
				replace(substring(f_desem,1,7),'-','') as periodo,
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				D.NOMBRE,
				D.DIRECCION,
				D.TELEFONO
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			LEFT JOIN NIT D ON(D.CEDULA=fac.nit)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=fac.nit)
			where negasoc = NEGOCIO_.cod_neg
			and fac.reg_status = ''
			and fac.documento ilike 'CM%'
			and facdet.reg_status = ''and valor_unitario > 0
			group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,fac.documento, HT.NIT_APOTEOSYS
			,tipo_iden, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
			order by num_doc_fen::integer)
			)
			union all
			(select
				'interes' as descr,
				3::integer AS iteracion,
				B.documento,
				num_doc_fen,
				'NEG' as tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE fac.nit END AS nit,
				--fac.nit,
				0::numeric as valor_deb,
				sum (valor_unitario) as valor_credt,
				fac.descripcion,
				f_desem::date as creation_date,
				fac.fecha_vencimiento,
				replace(substring(f_desem,1,7),'-','') as periodo,
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				D.NOMBRE,
				D.DIRECCION,
				D.TELEFONO
			from con.factura fac
			inner join negocios neg on (fac.negasoc = neg.cod_neg)
			inner join con.factura_detalle facdet on (fac.documento = facdet.documento)
			inner  JOIN (SELECT CODNEG,
					       SUBSTRING(COD,1,2) AS PREFIJO,
					       COD AS DOCUMENTO,
					       LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00') AS CUOTA,
					       FECHA_DOC::DATE AS FECHA_VEN,
					       VALOR
					FROM ING_FENALCO WHERE tipodoc='IF'
					ORDER BY
					COD,LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00')::INTEGER
				     ) B on (FAC.NEGASOC=B.CODNEG AND LPAD(SUBSTRING(FAC.DOCUMENTO,8,2),2,'00') =B.CUOTA)
			LEFT JOIN NIT D ON(D.CEDULA=fac.nit)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=fac.nit)
			where negasoc = NEGOCIO_.cod_neg
			and facdet.descripcion in ('INTERESES')
			and fac.reg_status = ''
			and facdet.reg_status = ''and valor_unitario > 0
			group by num_doc_fen,f_desem,fac.fecha_vencimiento,negasoc,fac.tipo_documento,fac.nit,fac.descripcion,fac.periodo,B.documento, HT.NIT_APOTEOSYS
			,tipo_iden, E.CODIGO_DANE2, D.NOMBRE1, D.NOMBRE2, D.APELLIDO1, D.APELLIDO2,D.NOMBRE,D.DIRECCION,D.TELEFONO
			order by num_doc_fen::integer
			)
			union all
			(SELECT
				'fenalco' as descr,
				4::integer AS iteracion,
				documento as doc,
				documento as documento,
				tipo_documento,
				CASE WHEN HT.NIT_APOTEOSYS IS NOT NULL THEN HT.NIT_APOTEOSYS ELSE proveedor END AS proveedor,
				--proveedor,
				0::numeric as valor_deb,
				vlr_neto as valor_credt,
				descripcion,
				f_desem::date as creation_date,
				f_desem::DATE AS fecha_vencimiento,
				replace(substring(f_desem,1,7),'-','') as periodo,
				(CASE
				WHEN tipo_iden ='CED' THEN 'CC'
				WHEN tipo_iden ='RIF' THEN 'CE'
				WHEN tipo_iden ='NIT' THEN 'NIT' ELSE
				'CC' END) as tipo_doc,
				(CASE
				WHEN tipo_iden in  ('RIF','NIT') THEN 'RCOM'  -->regimen comun
				WHEN tipo_iden in  ('CED')  THEN 'RSCP'
				END) as codigo,
				(CASE
				WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
				ELSE '08001' END) as codigociu,
				(D.NOMBRE1||' '||D.NOMBRE2) AS nombre_corto,
				(D.APELLIDO1||' '||D.APELLIDO2) AS apellidos,
				D.NOMBRE,
				D.DIRECCION,
				D.TELEFONO
			from fin.cxp_doc
			inner join negocios neg on ( neg.cod_neg = cxp_doc.documento_relacionado)
			LEFT JOIN NIT D ON(D.CEDULA=PROVEEDOR)
			LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
			LEFT JOIN CON.HOMOLOGA_TERCEROS HT ON(HT.NIT_FINTRA=proveedor)
			WHERE documento_relacionado in ( NEGOCIO_.cod_neg )
			and vlr_neto > 0
			and cxp_doc.reg_status = ''
			and substring (documento,1,2) in ('PM','PB')
			)
		LOOP
			CUENTA_ASIENTO := con.interfaz_cuenta_diferidos_apoteosys(substring(NEGOCIO_.cod_neg,1,2), INFOITEMS_.iteracion, NEGOCIO_.agencia,NEGOCIO_.unidad_neg::VARCHAR);
			--raise notice 'cod: %, iteracion: %, agencia: %',substring(NEGOCIO_.cod_neg,1,2), INFOITEMS_.iteracion, NEGOCIO_.agencia;
			IF(INFOITEMS_.tipo_documento in ('FAC','FAP','NEG') AND CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO',INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 6)='S')THEN
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
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO', INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 1);
			MCTYPE.MC_____CODIGO____CU_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO', INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 2);
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
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO',INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 3);
			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO', INFOITEMS_.tipo_documento, CUENTA_ASIENTO,NEGOCIO_.agencia, 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := INFOITEMS_.documento; -->factura
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('EDUCATIVO', INFOITEMS_.tipo_documento, CUENTA_ASIENTO, NEGOCIO_.agencia, 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			--FUNCION PARA INSERTAR EL REGISTRO EN LA TABLA TEMPORAL DE FINTRA
			SW:=CON.SP_INSERT_TABLE_MC_FENALCO____(MCTYPE);
			SECUENCIA_INT := SECUENCIA_INT + 1;

			--raise notice 'valor_deb: % valor_credt: %',INFOITEMS_.valor_deb,INFOITEMS_.valor_credt;
		END LOOP;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES(MCTYPE,'EDUCATIVO') ='N' THEN
			SW = 'N';
			CONTINUE;
		END IF;

		if(SW = 'S')then
			raise notice 'paso: %',NEGOCIO_.cod_neg;
			RESPUESTA := con.interfaz_educativo_aval_apoteosys(NEGOCIO_.cod_neg, MCTYPE.MC_____NUMERO____B, MCTYPE.MC_____CODIGO____TD_____B, MCTYPE.MC_____CODIGO____CD_____B,INFOITEMS_.creation_date::date,INFOITEMS_.fecha_vencimiento::DATE,INFOITEMS_.periodo);
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
ALTER FUNCTION con.interfaz_educativo_aval_financiado()
  OWNER TO postgres;
