-- Function: generarfacturasinteres()

-- DROP FUNCTION generarfacturasinteres();

CREATE OR REPLACE FUNCTION generarfacturasinteres()
  RETURNS text AS
$BODY$

DECLARE
	mcad TEXT;
	_numerofac_query CHARACTER VARYING;

	CuotasNegocios record;

BEGIN
	mcad = '';

	--FOR CuotasNegocios IN select * from tem.cambios_definitivos where accion = 'MENOR' and generar = 'GENERAR' and ano = '2013' and factura_hija = 'NoFiducia' and cod_neg not in('FA01650','FA00431') LOOP
	FOR CuotasNegocios IN select * from tem.cambios_definitivos where accion = 'IGUAL' and diff != '0' and generar = 'GENERAR' and ano = '2013' and factura_hija = 'NoFiducia' LOOP


		--'CXC_INTERES_FA' | 'CXC_INTERES_FID'
		_numerofac_query = '';
		SELECT INTO _numerofac_query get_lcod('CXC_INTERES_FA'); --CXC_INTERES_FID | CXC_INTERES_FA

		--select * from con.factura where documento = 'CI00584'
		--select * from con.factura_detalle where documento = 'FI00584'

		--INSERTA FACTURA CI/FI (CABECERA)
		INSERT INTO con.factura SELECT
		reg_status,
		dstrct,
		tipo_documento,
		_numerofac_query,
		CuotasNegocios.nit,
		CuotasNegocios.cod_cli,
		concepto,
		substring(now(),1,10)::date,
		CuotasNegocios.fecha,
		fecha_ultimo_pago,
		fecha_impresion,
		'CXC_INTERES_FA', --CXC_INTERES_FA | CXC_INTERES_FID
		observacion,
		CuotasNegocios.diff,
		'0.00',
		CuotasNegocios.diff,
		CuotasNegocios.diff,
		'0.00',
		CuotasNegocios.diff,
		valor_tasa,
		moneda,
		cantidad_items,
		forma_pago,
		agencia_facturacion,
		agencia_cobro,
		zona,
		clasificacion1,
		clasificacion2,
		clasificacion3,
		'0',
		'0',
		'0099-01-01 00:00:00',
		fecha_anulacion,
		fecha_contabilizacion_anulacion,
		base,
		last_update,
		user_update,
		now(),
		'HCUELLO',
		fecha_probable_pago,
		flujo,
		rif,
		'FA', --FA | CL
		usuario_anulo,
		formato,
		agencia_impresion,
		'',
		valor_tasa_remesa,
		CuotasNegocios.cod_neg,
		num_doc_fen,--??
		obs,
		pagado_fenalco,
		corficolombiana,
		tipo_ref1,
		ref1,
		tipo_ref2,
		ref2,
		dstrct_ultimo_ingreso,
		tipo_documento_ultimo_ingreso,
		num_ingreso_ultimo_ingreso,
		item_ultimo_ingreso,
		fec_envio_fiducia,
		nit_enviado_fiducia,
		tipo_referencia_1,
		referencia_1,
		tipo_referencia_2,
		referencia_2,
		tipo_referencia_3,
		referencia_3,
		nc_traslado,
		fecha_nc_traslado,
		tipo_nc,
		numero_nc,
		factura_traslado,
		factoring_formula_aplicada,
		nit_endoso,
		devuelta,
		fc_eca,
		fc_bonificacion,
		indicador_bonificacion,
		fi_bonificacion
		FROM con.factura WHERE documento = 'FI00584';

		--INSERTA FACTURA CI/FI (DETALLE)
		insert into con.factura_detalle select
		reg_status,
		dstrct,
		tipo_documento,
		_numerofac_query,
		item,
		CuotasNegocios.nit,
		concepto,
		CuotasNegocios.documento, --factura_hija | documento
		descripcion,
		'16252141', --CI: 16252101 | FI: 16252141
		cantidad,
		CuotasNegocios.diff,
		CuotasNegocios.diff,
		CuotasNegocios.diff,
		CuotasNegocios.diff,
		valor_tasa,
		moneda,
		last_update,
		user_update,
		now(),
		'HCUELLO',
		base,
		'RD-'||CuotasNegocios.nit,
		valor_ingreso,
		tipo_documento_rel,
		transaccion,
		documento_relacionado,
		tipo_referencia_1,
		referencia_1,
		tipo_referencia_2,
		referencia_2,
		tipo_referencia_3,
		referencia_3
		from con.factura_detalle where documento = 'FI00584';

		--update documentos_neg_aceptado set interes_causado = CuotasNegocios.interes_causado where cod_neg = CuotasNegocios.cod_neg and item = CuotasNegocios.item and capital = CuotasNegocios.capital and interes = CuotasNegocios.interes;
		update documentos_neg_aceptado set interes_causado = interes where cod_neg = CuotasNegocios.cod_neg and capital = CuotasNegocios.capital and item = CuotasNegocios.item and interes = CuotasNegocios.interes;


	END LOOP;

	mcad := 'PROCESO TERMINADO!';

	RETURN mcad;

END;
--$$
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION generarfacturasinteres()
  OWNER TO postgres;
