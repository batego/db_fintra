-- Function: etes.contabilizar_cxp_transferencia(character varying, character varying)

-- DROP FUNCTION etes.contabilizar_cxp_transferencia(character varying, character varying);

CREATE OR REPLACE FUNCTION etes.contabilizar_cxp_transferencia(numcxp character varying, usuario character varying)
  RETURNS text AS
$BODY$
DECLARE

rs text :='OK';
vectorCuentas varchar[]='{}';
grupoTransaccion integer:=0;

BEGIN

       --VALIDAMOS EL PERFIL CONTABLE PARA CREAR LA CXP DE LA TRANSFERENCIA--
        IF(etes.validacion_cuentas('CXP_TRANSFERENCIA'))THEN

		vectorCuentas:=etes.get_cuentas_perfil('CXP_TRANSFERENCIA');
		RAISE NOTICE 'CUENTA DETALLE :vectorCuentas[2]: %', vectorCuentas[2] ;

				--4.)CONTABILIZAMOS LA CXP.

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
					tipo_documento,
					documento,
					grupoTransaccion as grupo_transaccion,
					'OP'::text as sucursal,
					replace(substring(now(),1,7),'-','') as perido,
					now()::date as fechadoc,
					'CONTABLILIZACION CXP TRANSFERENCIA'::text as detalle,
					proveedor as tercero,
					vlr_neto as valor_debito,
					vlr_neto as valor_credito,
					(SELECT (COUNT(0)+1)::INTEGER FROM fin.cxp_items_doc WHERE documento =fin.cxp_doc.documento) as total_items,
					moneda_banco as moneda,
					'0099-01-01 00:00:00'::timestamp as fecha_aplicacion,
					usuario::text as aprobador,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::text as user_update,
					now() as creation_date,
					usuario as creation_user,
					'COL'::text as base,
					usuario as usuario_aplicacion,
					'002'::text as tipo_operacion,
					''::text as moneda_foranea,
					0.00::numeric as vlr_for,
					''::text as ref_1,
					''::text as ref_2
				FROM fin.cxp_doc    WHERE  documento = numCxP  and tipo_documento='FAP' ;

				--4.1)DETALLE CREDITO DE LA CXP

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
					tipo_documento,
					documento,
					grupoTransaccion as grupo_transaccion,
					nextval('con.comprodet_transaccion_seq') as transaccion,
					replace(substring(now(),1,7),'-','') as perido,
					vectorCuentas[1] as codigo_cuenta,
					'AR-'||proveedor::text as auxiliar,
					'CONTABLILIZACION CXP TRANSFERENCIA'::text as detalle,
					0.0::numeric as valor_debito,
					sum(vlr) as valor_credito,
					proveedor as tercero,
					documento as documento_interno,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::text as user_update,
					now() as creation_date,
					usuario as creation_user,
					'COL'::text as base,
					tipo_documento as tipodoc_rel,
					documento as documento_rel,
					''::text as  abc,
					0.00 as vlr_for,
					''::text as tipo_referencia_1,
					''::text as referencia_1,
					''::text as tipo_referencia_2,
					''::text as referencia_2,
					''::text as tipo_referencia_3,
					''::text as referencia_3
				FROM fin.cxp_items_doc  WHERE  documento = numCxP and tipo_documento='FAP'
				GROUP BY reg_status,
					dstrct,
					documento,
					codigo_cuenta,
					proveedor,
					tipo_documento ;

				--4.2)DETALLE DEBITO DE LA CXP

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
					tipo_documento,
					documento,
					grupoTransaccion as grupo_transaccion,
					nextval('con.comprodet_transaccion_seq') as transaccion,
					replace(substring(now(),1,7),'-','') as perido,
					codigo_cuenta,
					''::text as auxiliar,
					'CONTABLILIZACION CXP TRANSFERENCIA'::text as detalle,
					vlr as valor_debito,
					0.0::numeric as valor_credito,
					proveedor as tercero,
					documento as documento_interno,
					'0099-01-01 00:00:00'::timestamp as last_update,
					''::text as user_update,
					now() as creation_date,
					usuario as creation_user,
					'COL'::text as base,
					tipo_documento as tipodoc_rel,
					documento as documento_rel,
					''::text as  abc,
					0.00 as vlr_for,
					''::text as tipo_referencia_1,
					''::text as referencia_1,
					''::text as tipo_referencia_2,
					''::text as referencia_2,
					'ANTIC'::text as tipo_referencia_3,
					 planilla as referencia_3
				FROM fin.cxp_items_doc  WHERE documento = numCxP and tipo_documento='FAP' ;


				--4.3 MARCAMOS LA CXP COMO CONTABILIZADA
				UPDATE fin.cxp_doc
				SET fecha_contabilizacion=now(),
					usuario_contabilizo=usuario,
					transaccion=grupoTransaccion,
					periodo=replace(substring(now(),1,7),'-',''),
					last_update=now(),
					user_update=usuario
				WHERE documento=numCxP and tipo_documento='FAP' ;

	ELSE
	  rs:='ERROR';
	END IF;

	RETURN 	 rs;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.contabilizar_cxp_transferencia(character varying, character varying)
  OWNER TO postgres;
