-- Function: con.reconstruir_cd_endoso(character varying)

-- DROP FUNCTION con.reconstruir_cd_endoso(character varying);

CREATE OR REPLACE FUNCTION con.reconstruir_cd_endoso(comprobante_ character varying)
  RETURNS text AS
$BODY$

DECLARE

CD_ RECORD;
REG_ RECORD;
COMPRODET RECORD;
COMPRODET_DET RECORD;
INTERES_ RECORD;
GRUPO_TRANSACCION_ INT:=0;
TRANSACCION_ INT:=0;
val_deb numeric:=0.00;
val_cre numeric:=0.00;
num_items int:=0;

BEGIN

FOR CD_ IN

	--CONSULTAR LOS REGISTROS QUE SE VAN A CREAR EN LA NUEVA TRANSACCION
	select
		c.tipodoc,
		c.numdoc,
		c.convenio,
		c.grupo_transaccion,
		c.fechadoc,
		c.estado,
  		con.serie_comprobante_cen() as serie_numdoc
	from
	(select
		a.tipodoc,
		a.numdoc,
		a.grupo_transaccion,
		a.fechadoc,
		sp_uneg_negocio_name(b.referencia_1) as convenio,
		case when cuenta ilike '162521%' and valor_debito>0 then 'ENDOSO' ELSE 'DESENDOSO' END AS estado
	from
		con.comprobante a
	inner join con.comprodet b on (b.tipodoc=a.tipodoc and b.numdoc=a.numdoc and b.grupo_transaccion=a.grupo_transaccion)
	where
		a.reg_status='' and
		a.dstrct='FINV' and
		a.tipodoc='CDIAR' and
		a.periodo>='201701' and
		a.detalle ilike '%DIARIO DE ENDOSO%' and
		a.numdoc ilike 'CEN%'
		and b.cuenta ilike  '162521%'
		and a.numdoc=comprobante_
		) as c
	group by
		c.tipodoc,
		c.numdoc,
		c.convenio,
		c.grupo_transaccion,
		c.fechadoc,
		c.estado

LOOP

	raise notice 'NUMDOC ORIGINAL: %',CD_.numdoc;
	raise notice 'NUMDOC NUEVO: %',CD_.serie_numdoc;
	raise notice 'CONVENIO: %',CD_.convenio;
	raise notice 'ESTADO: %', CD_.estado;

	select INTO GRUPO_TRANSACCION_ nextval('con.comprobante_grupo_transaccion_seq');

	INSERT INTO con.comprobante(
		    reg_status, dstrct, tipodoc, numdoc, GRUPO_TRANSACCION, sucursal,
		    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
		    total_items, moneda, fecha_aplicacion, aprobador, last_update,
		    user_update, creation_date, creation_user, base, usuario_aplicacion,
		    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
	select reg_status, dstrct, tipodoc, cd_.serie_numdoc, grupo_transaccion_, sucursal,
		    periodo, fechadoc, detalle||' - '||CD_.CONVENIO, tercero, total_debito, total_credito,
		    total_items, moneda, fecha_aplicacion, aprobador, last_update,
		    'APOTEOSYS', creation_date, 'APOTEOSYS', base, usuario_aplicacion,
		    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2
	from con.comprobante where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.NUMDOC;

	raise notice 'GRUPO_TRANSACCION: %',GRUPO_TRANSACCION_;

	/*FOR COMPRODET IN

		select reg_status, dstrct, tipodoc, numdoc,  GRUPO_TRANSACCION, TRANSACCION,
			    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
			    tercero, documento_interno, last_update, user_update, creation_date,
			    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
			    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
			    tipo_referencia_3, referencia_3
		from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.NUMDOC and
					sp_uneg_negocio_name(referencia_1)=cd_.convenio

	LOOP*/

		--select INTO TRANSACCION_ nextval('con.comprodet_transaccion_seq');

		--raise notice 'TRANSACCION: %',TRANSACCION_;

	INSERT INTO con.comprodet(
		    reg_status, dstrct, tipodoc, numdoc, GRUPO_TRANSACCION, TRANSACCION,
		    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
		    tercero, documento_interno, last_update, user_update, creation_date,
		    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
		    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
		    tipo_referencia_3, referencia_3)
	select reg_status, dstrct, tipodoc, CD_.SERIE_NUMDOC, GRUPO_TRANSACCION_, nextval('con.comprodet_transaccion_seq'),
		    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
		    tercero, documento_interno, last_update, 'APOTEOSYS', creation_date,
		    'APOTEOSYS', base, tipodoc_rel, documento_rel, abc, vlr_for,
		    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
		    tipo_referencia_3, referencia_3
	from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.NUMDOC and GRUPO_TRANSACCION=cd_.grupo_transaccion
		and sp_uneg_negocio_name(referencia_1)=cd_.convenio;

	--END LOOP;

        --CUANDO ES EQUEMA NUEVO
	FOR COMPRODET_DET IN

		SELECT
			A.TIPODOC_REL,
			A.DOCUMENTO_REL,
			A.REFERENCIA_1,
			A.VALOR_DEBITO,--SI ES <> 0 ESTA EN ENDOSADO Y SI ES 0 ES LA REVERSION
			FAC.FECHA_FACTURA,
			FAC.FECHA_VENCIMIENTO,
			SUBSTRING(A.DOCUMENTO_REL,1,2) AS TIPO,
			COALESCE(TEM.ESQUEMA,'N') AS TIPO_ESQUEMA,
			COALESCE(DNA.TIENE_CUOTA,'N') AS TIENE_CUOTA
		FROM CON.COMPRODET A
		INNER JOIN CON.FACTURA FAC ON(FAC.DSTRCT='FINV' AND FAC.TIPO_DOCUMENTO='FAC' AND FAC.DOCUMENTO=A.DOCUMENTO_REL)
		LEFT JOIN (SELECT COD_NEG,'S'::VARCHAR AS TIENE_CUOTA FROM DOCUMENTOS_NEG_ACEPTADO WHERE REG_STATUS='' AND CUOTA_MANEJO>0 GROUP BY COD_NEG) DNA ON (DNA.COD_NEG=A.REFERENCIA_1)
		LEFT JOIN  TEM.NEGOCIOS_FACTURACION_OLD_FENALCO  TEM  ON (TEM.COD_NEG=A.REFERENCIA_1)
		WHERE
			A.DSTRCT='FINV' AND
			A.TIPODOC='CDIAR' AND
			A.NUMDOC = CD_.serie_numdoc AND
			--DOCUMENTO_REL='FG2268201' AND
			A.CUENTA='16252102'
		GROUP BY
			A.TIPODOC_REL,
			A.DOCUMENTO_REL,
			A.REFERENCIA_1,
			A.VALOR_DEBITO,
			FAC.FECHA_FACTURA,
			FAC.FECHA_VENCIMIENTO,
			COALESCE(TEM.ESQUEMA,'N'),
			COALESCE(DNA.TIENE_CUOTA,'N')

	LOOP

		--if((COMPRODET_DET.VALOR_DEBITO>0) OR (COMPRODET_DET.VALOR_DEBITO=0 and COMPRODET_DET.fecha_vencimiento::date>CD_.fechadoc::date))then
		if((COMPRODET_DET.VALOR_DEBITO>0) OR (COMPRODET_DET.VALOR_DEBITO=0 AND COMPRODET_DET.FECHA_VENCIMIENTO::DATE>='2017-01-01'))then

			--esquema nuevo tiene los dos conceptos en el detalle
			for interes_ in

-- 				select
-- 					conv.agencia,
-- 					conv.cuenta_interes,
-- 					cu1.nombre_largo as nom_cuenta_interes,
-- 					conv.cuenta_cuota_administracion,
-- 					cu2.nombre_largo as nom_cuenta_cuota_administracion,
-- 					pe.cuenta_cabecera_cdiar,
-- 					cu3.nombre_largo as nom_cuenta_cabecera_cdiar,
-- 					a.*
-- 				from
-- 					con.factura_detalle a
-- 					INNER JOIN negocios neg on(neg.cod_neg=a.numero_remesa)
-- 					INNER JOIN convenios conv on (conv.id_convenio = neg.id_convenio)
-- 					INNER JOIN administrativo.proceso_endoso pe on(a.descripcion=pe.concepto)
-- 					INNER JOIN con.cuentas cu1 on(cu1.cuenta=conv.cuenta_interes)
-- 					INNER JOIN con.cuentas cu2 on(cu2.cuenta=conv.cuenta_cuota_administracion)
-- 					INNER JOIN con.cuentas cu3 on(cu3.cuenta=pe.cuenta_cabecera_cdiar)
-- 				where
-- 					a.tipo_documento='FAC' and
-- 					a.documento in(COMPRODET_DET.documento_rel) and
-- 					a.descripcion  in('CUOTA-ADMINISTRACION','INTERESES')

				select
					conv.agencia,
					conv.cuenta_interes,
					cu1.nombre_largo as nom_cuenta_interes,
					conv.cuenta_cuota_administracion,
					cu2.nombre_largo as nom_cuenta_cuota_administracion,
					pe.cuenta_cabecera_cdiar,
					cu3.nombre_largo as nom_cuenta_cabecera_cdiar,
					b.documento as documento_int,
					b.tipodoc,
					(select cod from con.mc_causacion_intereses where codneg=a.numero_remesa and cod=b.documento)as pru,
					a.*
				from
					con.factura_detalle a
					INNER JOIN negocios neg on(neg.cod_neg=a.numero_remesa)
					INNER JOIN convenios conv on (conv.id_convenio = neg.id_convenio)
					INNER JOIN administrativo.proceso_endoso pe on(a.descripcion=pe.concepto)
					INNER JOIN con.cuentas cu1 on(cu1.cuenta=conv.cuenta_interes)
					INNER JOIN con.cuentas cu2 on(cu2.cuenta=conv.cuenta_cuota_administracion)
					INNER JOIN con.cuentas cu3 on(cu3.cuenta=pe.cuenta_cabecera_cdiar)
					left JOIN (SELECT reg_status, CODNEG,
								       SUBSTRING(COD,1,2) AS PREFIJO,
								       COD AS DOCUMENTO,
								       LPAD((SUBSTRING(COD,10,2)::INTEGER+1),2,'00') AS CUOTA,
								       FECHA_DOC::DATE AS FECHA_VEN,
								       VALOR,
								       TIPODOC
								FROM ING_FENALCO --WHERE reg_status=''
							) B on (a.numero_remesa=B.CODNEG AND B.TIPODOC=(
													case when cu3.nombre_largo ilike '%CUOTA ADM%' THEN 'CM'
													WHEN cu3.nombre_largo ilike '%ANTICIPADO%FENALCO%' THEN 'IF'
													WHEN cu3.nombre_largo ilike '%NATICIPADO%FEN%' THEN 'IF'
													ELSE 'N' END)
								AND SUBSTRING(a.documento,8,2) =B.CUOTA)
				where
					a.tipo_documento='FAC' and
					a.documento in(COMPRODET_DET.documento_rel) and
					(b.documento not in (select cod from con.mc_causacion_intereses where codneg=a.numero_remesa and cod=b.documento) and
					(SELECT procesado_dif from ing_fenalco where cod=b.documento and codneg=a.numero_remesa)='N')
					and
					a.descripcion  in('CUOTA-ADMINISTRACION','INTERESES')

			loop

				select INTO TRANSACCION_ nextval('con.comprodet_transaccion_seq');

				--raise notice 'TRANSACCION: %',TRANSACCION_;

				INSERT INTO con.comprodet(
					    reg_status, dstrct, tipodoc, numdoc, GRUPO_TRANSACCION, TRANSACCION,
					    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
					    tercero, documento_interno, last_update, user_update, creation_date,
					    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
					    tipo_referencia_3, referencia_3)
					SELECT reg_status, dstrct, tipodoc, cd_.serie_numdoc, GRUPO_TRANSACCION_, TRANSACCION_,
					    periodo,
					    CASE WHEN interes_.DESCRIPCION='INTERESES' THEN interes_.CUENTA_INTERES ELSE interes_.cuenta_cuota_administracion END,
					    auxiliar,
					    CASE WHEN interes_.DESCRIPCION='INTERESES' THEN interes_.nom_cuenta_interes ELSE interes_.nom_cuenta_cuota_administracion END,
					    CASE WHEN COMPRODET_DET.VALOR_DEBITO<>0 THEN interes_.VALOR_UNITARIO ELSE 0 END,
					    CASE WHEN COMPRODET_DET.VALOR_DEBITO=0 THEN interes_.VALOR_UNITARIO ELSE 0 END,
					    tercero, documento_interno, last_update, 'APOTEOSYS', creation_date,
					    'APOTEOSYS', base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, interes_.tipodoc, interes_.documento_int,
					    tipo_referencia_3, referencia_3
					    from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.serie_NUMDOC and GRUPO_TRANSACCION=GRUPO_TRANSACCION_
						and TRANSACCION=(select max(transaccion) from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.serie_NUMDOC and
						GRUPO_TRANSACCION=GRUPO_TRANSACCION_ AND tipodoc_rel=COMPRODET_DET.tipodoc_rel AND documento_rel=COMPRODET_DET.documento_rel);

				select INTO TRANSACCION_ nextval('con.comprodet_transaccion_seq');

				--raise notice 'TRANSACCION: %',TRANSACCION_;

				INSERT INTO con.comprodet(
					    reg_status, dstrct, tipodoc, numdoc, GRUPO_TRANSACCION, TRANSACCION,
					    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
					    tercero, documento_interno, last_update, user_update, creation_date,
					    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
					    tipo_referencia_3, referencia_3)
					SELECT reg_status, dstrct, tipodoc, cd_.serie_numdoc, GRUPO_TRANSACCION_, TRANSACCION_,
					    periodo,
					    interes_.cuenta_cabecera_cdiar,
					    --CASE WHEN interes_.DESCRIPCION='INTERESES' THEN '16252135' ELSE '16252136' END,
					    auxiliar,
					    interes_.nom_cuenta_cabecera_cdiar,
					    --CASE WHEN interes_.DESCRIPCION='INTERESES' THEN 'INTERESES POR ANTICIPADO' ELSE 'INTERESES POR ANTICIPADO FENALCO' END,
					    --0, interes_.VALOR_UNITARIO,
					    CASE WHEN COMPRODET_DET.VALOR_DEBITO<>0 THEN 0 ELSE interes_.VALOR_UNITARIO END,
					    CASE WHEN COMPRODET_DET.VALOR_DEBITO=0 THEN 0 ELSE interes_.VALOR_UNITARIO END,
					    tercero, documento_interno, last_update, 'APOTEOSYS', creation_date,
					    'APOTEOSYS', base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, interes_.tipodoc, interes_.documento_int,
					    tipo_referencia_3, referencia_3
					    from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.serie_NUMDOC and GRUPO_TRANSACCION=GRUPO_TRANSACCION_
						and TRANSACCION=(select max(transaccion) from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.serie_NUMDOC and
						GRUPO_TRANSACCION=GRUPO_TRANSACCION_ AND tipodoc_rel=COMPRODET_DET.tipodoc_rel AND documento_rel=COMPRODET_DET.documento_rel);

			end loop;

			--aqui vamos agregar lo de la cuota de admin
			IF (COMPRODET_DET.TIPO_ESQUEMA='S' and COMPRODET_DET.TIENE_CUOTA='S' AND COMPRODET_DET.TIPO='CM' and COMPRODET_DET.FECHA_FACTURA::DATE>='2017-01-01'::DATE) THEN

				select INTO REG_
					a.cuenta,
					b.nombre_largo,
					--a.valor_debito,
					a.valor_credito
				from
					con.comprodet a
				inner join
					con.cuentas b on(b.cuenta=a.cuenta)
				where
					a.reg_status='' and
					a.tipodoc='FAC' and
					a.numdoc = COMPRODET_DET.DOCUMENTO_REL and
					a.tipodoc_rel='FAC' and
					a.documento_rel = COMPRODET_DET.DOCUMENTO_REL;


				select INTO TRANSACCION_ nextval('con.comprodet_transaccion_seq');

				INSERT INTO con.comprodet(
					    reg_status, dstrct, tipodoc, numdoc, GRUPO_TRANSACCION, TRANSACCION,
					    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
					    tercero, documento_interno, last_update, user_update, creation_date,
					    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
					    tipo_referencia_3, referencia_3)
					SELECT reg_status, dstrct, tipodoc, cd_.serie_numdoc, GRUPO_TRANSACCION_, TRANSACCION_,
					    periodo,
					    REG_.CUENTA,
					    auxiliar,
					    REG_.nombre_largo,
					    --REG_.VALOR_CREDITO, 0,
					    CASE WHEN COMPRODET_DET.VALOR_DEBITO<>0 THEN REG_.VALOR_CREDITO ELSE 0 END,
					    CASE WHEN COMPRODET_DET.VALOR_DEBITO=0 THEN REG_.VALOR_CREDITO ELSE 0 END,
					    tercero, documento_interno, last_update, 'APOTEOSYS', creation_date,
					    'APOTEOSYS', base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, interes_.tipodoc, interes_.documento_int,
					    tipo_referencia_3, referencia_3
					    from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.serie_NUMDOC and GRUPO_TRANSACCION=GRUPO_TRANSACCION_
						and TRANSACCION=(select max(transaccion) from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.serie_NUMDOC and
						GRUPO_TRANSACCION=GRUPO_TRANSACCION_ AND tipodoc_rel=COMPRODET_DET.tipodoc_rel AND documento_rel=COMPRODET_DET.documento_rel);


				select INTO TRANSACCION_ nextval('con.comprodet_transaccion_seq');

				INSERT INTO con.comprodet(
					    reg_status, dstrct, tipodoc, numdoc, GRUPO_TRANSACCION, TRANSACCION,
					    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
					    tercero, documento_interno, last_update, user_update, creation_date,
					    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
					    tipo_referencia_3, referencia_3)
					SELECT reg_status, dstrct, tipodoc, cd_.serie_numdoc, GRUPO_TRANSACCION_, TRANSACCION_,
					    periodo,
					    '16252136',
					    auxiliar,
					    (SELECT nombre_largo FROM con.cuentas where cuenta='16252136'),
					    --0, REG_.VALOR_CREDITO,
					    CASE WHEN COMPRODET_DET.VALOR_DEBITO<>0 THEN 0 ELSE REG_.VALOR_CREDITO END,
					    CASE WHEN COMPRODET_DET.VALOR_DEBITO=0 THEN 0 ELSE REG_.VALOR_CREDITO END,
					    tercero, documento_interno, last_update, 'APOTEOSYS', creation_date,
					    'APOTEOSYS', base, tipodoc_rel, documento_rel, abc, vlr_for,
					    tipo_referencia_1, referencia_1, interes_.tipodoc, interes_.documento_int,
					    tipo_referencia_3, referencia_3
					    from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.serie_NUMDOC and GRUPO_TRANSACCION=GRUPO_TRANSACCION_
						and TRANSACCION=(select max(transaccion) from con.comprodet where dstrct='FINV' and TIPODOC='CDIAR' and numdoc =CD_.serie_NUMDOC and
						GRUPO_TRANSACCION=GRUPO_TRANSACCION_ AND tipodoc_rel=COMPRODET_DET.tipodoc_rel AND documento_rel=COMPRODET_DET.documento_rel);


			END IF;

		END IF;

	END LOOP;


	select
	into
		val_deb,
		val_cre,
		num_items
		sum(valor_debito),
		sum(valor_credito),
		count(*)
	from
		con.comprodet
	where
		dstrct='FINV' and
		TIPODOC='CDIAR' and
		numdoc =CD_.serie_numdoc and
		GRUPO_TRANSACCION=GRUPO_TRANSACCION_;

	update
		con.comprobante
	set
		total_debito=val_deb,
		total_credito=val_cre,
		total_items = num_items
	where
		dstrct='FINV' and
		TIPODOC='CDIAR' and
		numdoc =CD_.serie_numdoc and
		GRUPO_TRANSACCION=GRUPO_TRANSACCION_;

		raise notice '# Items: %',num_items;

		raise notice 'UPDATE: %','OK';
		raise notice 'FIN %','------------------------------------------------------------';

END LOOP;

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.reconstruir_cd_endoso(character varying)
  OWNER TO postgres;
