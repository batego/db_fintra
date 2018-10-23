-- Function: etes.contabilizar_egreso_transferencia(character varying, date, character varying, character varying)

-- DROP FUNCTION etes.contabilizar_egreso_transferencia(character varying, date, character varying, character varying);

CREATE OR REPLACE FUNCTION etes.contabilizar_egreso_transferencia(nro_egreso character varying, fecha_documento date, periodo_contable character varying, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

rs text :='OK';
vectorCuentas varchar[]='{}';
grupoTransaccion integer:=0;

BEGIN

       --VALIDAMOS EL PERFIL CONTABLE PARA CREAR LA CXP DE LA EDS--
      IF(etes.validacion_cuentas('EGRESO_TRANSFERENCIA'))THEN

	vectorCuentas:=etes.get_cuentas_perfil('EGRESO_TRANSFERENCIA');
	RAISE NOTICE 'CUENTA COMISION BANCO :vectorCuentas[2]: %', vectorCuentas[2] ;

				--1.)CONTABILIZAMOS EGRESO TRANSFERENCIA.

				SELECT INTO grupoTransaccion nextval('con.comprobante_grupo_transaccion_seq');

				INSERT INTO con.comprobante(
						    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, sucursal,
						    periodo, fechadoc, detalle, tercero, total_debito, total_credito,
						    total_items, moneda, fecha_aplicacion, aprobador, last_update,
						    user_update, creation_date, creation_user, base, usuario_aplicacion,
						    tipo_operacion, moneda_foranea, vlr_for, ref_1, ref_2)
				 SELECT
					reg_status,
					dstrct,
					'EGR'::VARCHAR AS tipodoc ,
					document_no as numdoc,
					grupoTransaccion as grupo_transaccion,
					'OP'::varchar as sucursal,
					periodo_contable::varchar as periodo,
					fecha_documento::date as fechadoc,
					'CONTABILIZACION EGRESO TRANSFERENCIA '||document_no::varchar as detalle,
					nit AS tercero,
					vlr as total_debito,
					vlr_for as total_credito,
					(SELECT (COUNT(0)+1)::INTEGER FROM egresodet  WHERE document_no =egreso.document_no) as total_items,
					'PES'::VARCHAR AS moneda,
					'0099-01-01 00:00:00'::timestamp as fecha_aplicacion,
					usuario AS aprobador,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::VARCHAR AS user_update,
					NOW() AS creation_date,
					usuario AS creation_user,
					'COL'::VARCHAR as base,
					''::VARCHAR AS usuario_aplicacion,
					'003'::varchar as tipo_operacion,
					''::varchar as moneda_foranea,
					0.0::numeric as vlr_for,
					''::varchar as ref_1,
					''::varchar as ref_2
					from egreso
					where document_no = nro_egreso AND dstrct='FINV' AND reg_status='' AND fecha_contabilizacion='0099-01-01 00:00:00'::timestamp ;

				if(FOUND)THEN

					--4.1)DETALLE CREDITO DEL EGRESO VS BANCO

					INSERT INTO con.comprodet(
						    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
						    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
						    tercero, documento_interno, last_update, user_update, creation_date,
						    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
						    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
						    tipo_referencia_3, referencia_3)
					 SELECT
						reg_status,
						dstrct,
						'EGR'::varchar as tipo_documento,
						document_no as numdoc,
						grupoTransaccion as grupo_transaccion,
						nextval('con.comprodet_transaccion_seq') as transaccion,
						periodo_contable as perido,
						'11100103'::VARCHAR AS cuenta,--CUENTA BANCO
						''::text as auxiliar,
						'BANCOLOMBIA-CC'::text as detalle,
						0.0::numeric as valor_debito,
						sum(vlr) as valor_credito,
						(SELECT nit FROM egreso  where document_no=egresodet.document_no) as tercero,
						document_no as documento_interno,
						'0099-01-01 00:00:00'::timestamp as last_update,
						''::text as user_update,
						now() as creation_date,
						usuario as creation_user,
						'COL'::text as base,
						''::varchar as tipodoc_rel,
						document_no as documento_rel,
						'N/A'::text as  abc,
						0.00 as vlr_for,
						''::text as tipo_referencia_1,
						''::text as referencia_1,
						''::text as tipo_referencia_2,
						''::text as referencia_2,
						''::text as tipo_referencia_3,
						''::text as referencia_3
						from egresodet
						where document_no = nro_egreso AND dstrct='FINV' AND reg_status=''
						group by reg_status,dstrct,document_no ;


					--4.2)DETALLE CREDITO COMISION BANCARIA.
					INSERT INTO con.comprodet(
						    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
						    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
						    tercero, documento_interno, last_update, user_update, creation_date,
						    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
						    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
						    tipo_referencia_3, referencia_3)
					SELECT
						reg_status,
						dstrct,
						'EGR'::varchar as tipo_documento,
						document_no as numdoc,
						grupoTransaccion as grupo_transaccion,
						nextval('con.comprodet_transaccion_seq') as transaccion,
						periodo_contable as perido,
						cuenta,
						''::text as auxiliar,
						(SELECT get_nombp(nit) FROM egreso  where document_no=egresodet.document_no)::text as detalle,
						0.0::numeric as valor_debito,
						vlr*(-1) as valor_credito,
						(SELECT nit FROM egreso  where document_no=egresodet.document_no) as tercero,
						document_no as documento_interno,
						'0099-01-01 00:00:00'::timestamp as last_update,
						''::text as user_update,
						now() as creation_date,
						usuario as creation_user,
						'COL'::text as base,
						tipo_documento::varchar as tipodoc_rel,
						documento as documento_rel,
						'N/A'::text as  abc,
						0.00 as vlr_for,
						''::text as tipo_referencia_1,
						''::text as referencia_1,
						''::text as tipo_referencia_2,
						''::text as referencia_2,
						''::text as tipo_referencia_3,
						''::text as referencia_3
						from egresodet
						where document_no = nro_egreso and cuenta=vectorCuentas[2]::VARCHAR AND dstrct='FINV' AND reg_status='' ;

					--4.2)DETALLE DEBITO DEL EGRESO

					INSERT INTO con.comprodet(
						    reg_status, dstrct, tipodoc, numdoc, grupo_transaccion, transaccion,
						    periodo, cuenta, auxiliar, detalle, valor_debito, valor_credito,
						    tercero, documento_interno, last_update, user_update, creation_date,
						    creation_user, base, tipodoc_rel, documento_rel, abc, vlr_for,
						    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
						    tipo_referencia_3, referencia_3)
					 SELECT
						reg_status,
						dstrct,
						'EGR'::varchar as tipo_documento,
						document_no as numdoc,
						grupoTransaccion as grupo_transaccion,
						nextval('con.comprodet_transaccion_seq') as transaccion,
						periodo_contable as perido,
						cuenta,
						''::text as auxiliar,
						(SELECT get_nombp(nit) FROM egreso  where document_no=egresodet.document_no)::text as detalle,
						vlr as valor_debito,
						0.0::numeric as  valor_credito,
						(SELECT nit FROM egreso  where document_no=egresodet.document_no) as tercero,
						document_no as documento_interno,
						'0099-01-01 00:00:00'::timestamp as last_update,
						''::text as user_update,
						now() as creation_date,
						usuario as creation_user,
						'COL'::text as base,
						tipo_documento::varchar as tipodoc_rel,
						documento as documento_rel,
						'N/A'::text as  abc,
						0.00 as vlr_for,
						''::text as tipo_referencia_1,
						''::text as referencia_1,
						''::text as tipo_referencia_2,
						''::text as referencia_2,
						''::text as tipo_referencia_3,
						''::text as referencia_3
					from egresodet
					where document_no = nro_egreso and cuenta=vectorCuentas[1]::VARCHAR ;

					--4.3)ACTUALIZAMOS CABECERA CON VALOR CORRECTO DEL COMPROBANTE.
					update con.comprobante
					set
					total_debito=(select SUM(valor_debito) from con.comprodet where  numdoc = nro_egreso and tipodoc='EGR' ),
					total_credito=(select SUM(valor_credito) from con.comprodet where  numdoc = nro_egreso and tipodoc='EGR' )
					where numdoc=nro_egreso and tipodoc='EGR' ;

					--4.4) MARCAMOS EL EGRESO COMO CONTABILIZADO

					update egreso
					set
					   transaccion = grupoTransaccion,
					   fecha_contabilizacion = now(),
					   usuario_contabilizacion = usuario,
					   periodo=periodo_contable
					where document_no = nro_egreso;

				ELSE
				 rs:='ERROR';
				END IF;

	ELSE
	  rs:='ERROR';
	END IF;

	RETURN 	 rs;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.contabilizar_egreso_transferencia(character varying, date, character varying, character varying)
  OWNER TO postgres;
