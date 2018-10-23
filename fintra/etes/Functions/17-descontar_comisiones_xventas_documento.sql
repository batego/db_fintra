-- Function: etes.descontar_comisiones_xventas_documento(character varying, integer, character varying)

-- DROP FUNCTION etes.descontar_comisiones_xventas_documento(character varying, integer, character varying);

CREATE OR REPLACE FUNCTION etes.descontar_comisiones_xventas_documento(numerocxp character varying, id_estacion integer, periodo_in character varying)
  RETURNS text AS
$BODY$

DECLARE

 count_cxp_generadas integer:=0;
 perido_corte NUMERIC:=0;
 recordTotalVentas record;
 valor_comision numeric:=0;
 recordRangos record;
 retorno text:='NO GENERADA';

BEGIN

	/*-------------------------------------------------------
	--VERIFICAMOS QUE LA CXP GENERADA SE LA PRIMERA DEL MES--
	--------------------------------------------------------*/


	Select into count_cxp_generadas count(0) from (
		SELECT cxp.documento FROM fin.cxp_doc as cxp
		INNER JOIN etes.ventas_eds ventas on (ventas.documento_cxp=cxp.documento)
		WHERE documento LIKE 'EDS%' AND tipo_documento='FAP'
		AND handle_code='EG' AND cxp.dstrct='FINV' AND cxp.reg_status='' and ventas.id_eds=id_estacion and ventas.documento_cxp=numerocxp
		group by cxp.documento
	)t ;

	raise NOTICE 'count_cxp_generadas: %',count_cxp_generadas;

	--1.) Si es uno(1) es la primera cuenta de cobro del mes **cambiar a 1 ojo**.
	IF(count_cxp_generadas = 1)THEN

		--1.1) Buscamos el perido de la facturas del mes anterior.
			perido_corte:=periodo_in;
			RAISE NOTICE 'PERIODO : %',perido_corte;

		--1.2 ) Buscamos los galones consumidos por mes.

			select into recordTotalVentas sum(cantidad_suministrada) as galones_xmes ,sum(total_venta) as total_venta
			FROM etes.ventas_eds as ventas
			inner join etes.productos_es as producto on (producto.id=ventas.id_producto)
			WHERE REPLACE(SUBSTRING(creation_date,1,7),'-','')::NUMERIC =perido_corte
			and producto.cod_producto='PES00002' AND id_eds=id_estacion;

			RAISE NOTICE 'recordTotalVentas : %',recordTotalVentas;

		--1.3) Buscamos el valor correspondiente al galonaje obtenido.

			SELECT into recordRangos * FROM etes.rangos_comisiones_eds rangos
			INNER JOIN etes.configcomerial_productos cofprod on (cofprod.id=rangos.id_config_productos and cofprod.reg_status='')
			WHERE cofprod.id_eds=id_estacion  and recordTotalVentas.galones_xmes between rangos.galonaje_inicial and rangos.galonaje_final  ;

			RAISE NOTICE 'recordRangos : %',recordRangos;

		--1.4) Calculamos el valor de la comision o valor nota credito.
			if(recordRangos.valor_descuento > 0)then

				valor_comision:= ROUND(recordTotalVentas.galones_xmes*recordRangos.valor_descuento,2);
			ELSE
				valor_comision:= ROUND(recordTotalVentas.total_venta * (recordRangos.porcentaje_descuento/100),2);
			end if;

			RAISE NOTICE 'valor_comision : %',valor_comision;


		--2.0)CREAMOS LA NOTA CREDITO

		--2.1)Cabecera nota credito.
		if(valor_comision is not null or valor_comision > 0)then

			INSERT INTO fin.cxp_doc(
				    reg_status, dstrct, proveedor, tipo_documento, documento, descripcion,
				    agencia, handle_code, id_mims, tipo_documento_rel, documento_relacionado,
				    fecha_aprobacion, aprobador, usuario_aprobacion, banco, sucursal,
				    moneda, vlr_neto, vlr_total_abonos, vlr_saldo, vlr_neto_me, vlr_total_abonos_me,
				    vlr_saldo_me, tasa, usuario_contabilizo, fecha_contabilizacion,
				    usuario_anulo, fecha_anulacion, fecha_contabilizacion_anulacion,
				    observacion, num_obs_autorizador, num_obs_pagador, num_obs_registra,
				    last_update, user_update, creation_date, creation_user, base,
				    corrida, cheque, periodo, fecha_procesado, fecha_contabilizacion_ajc,
				    fecha_contabilizacion_ajv, periodo_ajc, periodo_ajv, usuario_contabilizo_ajc,
				    usuario_contabilizo_ajv, transaccion_ajc, transaccion_ajv, clase_documento,
				    transaccion, moneda_banco, fecha_documento, fecha_vencimiento,
				    ultima_fecha_pago, flujo, transaccion_anulacion, ret_pago, clase_documento_rel,
				    tipo_referencia_1, referencia_1, tipo_referencia_2, referencia_2,
				    tipo_referencia_3, referencia_3, indicador_traslado_fintra, factoring_formula_aplicada,
				    factura_tipo_nomina)
			     SELECT reg_status, dstrct, proveedor, 'NC'::varchar AS tipo_documento, documento, 'NOTA CREDITO DESCUENTO GALONES X VENTA'::varchar as descripcion,
				       agencia, handle_code, id_mims, tipo_documento as tipo_documento_rel, documento as documento_relacionado,
				       now() as fecha_aprobacion, (select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO') AS aprobador, (select table_code from tablagen where table_type= 'AUTCXP' AND dato='PREDETERMINADO') AS usuario_aprobacion, banco, sucursal,
				       moneda, valor_comision::NUMERIC AS vlr_neto, 0.00 AS vlr_total_abonos, valor_comision::NUMERIC AS vlr_saldo, valor_comision::NUMERIC AS vlr_neto_me, 0.00 AS vlr_total_abonos_me,
				       valor_comision::NUMERIC AS vlr_saldo_me, tasa,''::VARCHAR AS usuario_contabilizo, '0099-01-01 00:00:00'::timestamp AS fecha_contabilizacion,
				       ''::VARCHAR AS usuario_anulo, '0099-01-01 00:00:00'::timestamp AS fecha_anulacion, '0099-01-01 00:00:00'::timestamp AS fecha_contabilizacion_anulacion,
				       observacion, num_obs_autorizador, num_obs_pagador, num_obs_registra,
				       '0099-01-01 00:00:00'::timestamp AS last_update,''::VARCHAR AS user_update, NOW() AS  creation_date,creation_user, base,
				       ''::varchar as corrida, ''::varchar as cheque, ''::varchar as periodo, fecha_procesado, fecha_contabilizacion_ajc,
				       fecha_contabilizacion_ajv, periodo_ajc, periodo_ajv, usuario_contabilizo_ajc,
				       usuario_contabilizo_ajv, transaccion_ajc, transaccion_ajv, clase_documento,
				       0 as transaccion, moneda_banco, NOW()::date as fecha_documento,NOW()::date as fecha_vencimiento,
				       '0099-01-01'::date as ultima_fecha_pago, flujo, 0::integer as transaccion_anulacion, ret_pago, clase_documento_rel,
				       tipo_documento as tipo_referencia_1,documento as referencia_1, tipo_referencia_2, referencia_2,
				       tipo_referencia_3, referencia_3, indicador_traslado_fintra, factoring_formula_aplicada,
				       factura_tipo_nomina
			   FROM fin.cxp_doc
			   where documento = numeroCXP and dstrct='FINV' And tipo_documento='FAP';

		--2.2)Detalle nota credito.

			INSERT INTO fin.cxp_items_doc(
				    reg_status, dstrct, proveedor, tipo_documento, documento, item,
				    descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
				    last_update, user_update, creation_date, creation_user, base,
				    codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
				    referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
				    referencia_3)
			    select  reg_status, dstrct, proveedor, 'NC'::VARCHAR AS tipo_documento, documento, '001'::VARCHAR AS item,
					'NOTA CREDITO DESCUENTO GALONES X VENTA'::varchar AS descripcion, valor_comision::NUMERIC AS vlr,valor_comision::NUMERIC AS vlr_me,'I010290024175'::VARCHAR AS codigo_cuenta, codigo_abc, ''::VARCHAR AS planilla,
					'0099-01-01 00:00:00'::timestamp AS last_update, ''::VARCHAR AS user_update, NOW() AS creation_date, creation_user, base,
					codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
					referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
					referencia_3
				from fin.cxp_items_doc
				where documento = numeroCXP and dstrct='FINV' And tipo_documento='FAP'
				GROUP BY
				reg_status, dstrct, proveedor,documento,codigo_abc,creation_user, base,
				codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
				referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
				referencia_3;

		--2.3)Actualizamos la cxp operativamente.

			UPDATE fin.cxp_doc
				SET
				vlr_total_abonos= vlr_total_abonos+valor_comision,
				vlr_total_abonos_me= vlr_total_abonos_me+valor_comision,
				vlr_saldo= vlr_saldo-valor_comision,
				vlr_saldo_me= vlr_saldo_me-valor_comision,
				last_update=now(),
				user_update=creation_user
			WHERE documento=numeroCXP and tipo_documento='FAP' and dstrct='FINV'  ;

		--2.4)Creamos la relacion de la cuenta de cobro con la nota.

			RAISE NOTICE 'id_estacion : %',id_estacion;

			INSERT INTO etes.rel_cxp_nota_credito(
				    reg_status, dstrct, id_eds, cxp_cuentas_cobro, cxp_nota,
				    periodo, creation_date, creation_user, last_update, user_update)
			    VALUES ('', 'FINV', id_estacion, numeroCXP, numeroCXP,
				    REPLACE(SUBSTRING(NOW(),1,7),'-',''), NOW(),'ADMIN','0099-01-01 00:00:00'::timestamp, '');


			retorno:='GENERADA';

		end if;
	END IF;

	return retorno;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.descontar_comisiones_xventas_documento(character varying, integer, character varying)
  OWNER TO postgres;
