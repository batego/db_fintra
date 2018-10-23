-- Function: opav.sl_costos_selectrik(character varying)

-- DROP FUNCTION opav.sl_costos_selectrik(character varying);

CREATE OR REPLACE FUNCTION opav.sl_costos_selectrik(_multiservicio character varying)
  RETURNS SETOF opav.rs_reporte_costos_selectik AS
$BODY$
DECLARE

recordCostosSelectrik record;
recordCdiar record;
_totalComision numeric:=0;
_auxDocumento varchar:='';
_auxProveedor varchar:='';
_auxTipoDocumento varchar:='';
rs opav.rs_reporte_costos_selectik;
BEGIN

	 raise notice 'multiservicio: %',_multiservicio;

	 FOR recordCostosSelectrik IN (SELECT  'SELECTRIK'::TEXT as empresa,
						cxp.tipo_referencia_1,
						cxp.referencia_1,
						cxp.proveedor,
						get_nombp(cxp.proveedor) as nombre_proveedor,
						cxp.fecha_documento,
						cxp.tipo_documento,
						cxp.documento,
						cxp.descripcion,
						sum(cxpdet.vlr) as valor_antes_iva,
						coalesce(sum(impuesto.vlr_total_impuesto),0.00) as valor_iva,
						0.00::numeric as valor_total_con_iva,
						cxp.vlr_neto as valor_pagado,
						cxp.vlr_total_abonos,
						case when cxp.ultima_fecha_pago ='0099-01-01'::date then null else  cxp.ultima_fecha_pago end as fecha_pago,
						cxpdet.codigo_cuenta,
						c.nombre_largo
					FROM fin.cxp_doc cxp
					INNER JOIN fin.cxp_items_doc cxpdet on (cxp.documento=cxpdet.documento AND cxp.tipo_documento=cxpdet.tipo_documento and cxp.proveedor=cxpdet.proveedor)
					LEFT JOIN fin.cxp_imp_item  impuesto on (cxpdet.documento=impuesto.documento and cxpdet.proveedor=impuesto.proveedor and  impuesto.cod_impuesto like 'IVA%' AND impuesto.item=cxpdet.item )
					INNER JOIN con.cuentas c on (c.cuenta=cxpdet.codigo_cuenta)
					WHERE cxp.tipo_referencia_1='NUMOS'
					AND cxp.reg_status=''
					AND cxp.referencia_3 !='ALTER'
					AND cxp.tipo_referencia_3 !='ALTER'
					AND (substring(cxpdet.codigo_cuenta,1,1) in ('C','G') OR cxpdet.codigo_cuenta in ('14350101','13300501','24080206','24080211','22050101','28050101'))--estas cuentas no deben estar rpaternina
					AND cxp.referencia_1=_multiservicio
					GROUP BY
					cxp.tipo_referencia_1,
					cxp.referencia_1,
					cxp.proveedor,
					cxp.tipo_documento,
					cxp.documento,
					cxp.descripcion,
					cxp.vlr_neto,
					cxp.vlr_total_abonos,
					cxp.fecha_documento,
					cxp.ultima_fecha_pago,
					cxpdet.codigo_cuenta,
					c.nombre_largo
					order by proveedor

					)

	LOOP
		raise notice 'recordCostosSelectrik.antes_de_iva : % recordCostosSelectrik.valor_iva :% ',recordCostosSelectrik.valor_antes_iva,recordCostosSelectrik.valor_iva;
		recordCostosSelectrik.valor_total_con_iva:=recordCostosSelectrik.valor_antes_iva+recordCostosSelectrik.valor_iva;

		IF(_auxDocumento='' and _auxProveedor ='' and _auxTipoDocumento='')THEN
			_auxDocumento:=recordCostosSelectrik.documento;
			_auxProveedor:=recordCostosSelectrik.proveedor;
			_auxTipoDocumento:=recordCostosSelectrik.tipo_documento;

		ELSIF(_auxDocumento=recordCostosSelectrik.documento and _auxProveedor =recordCostosSelectrik.proveedor and _auxTipoDocumento =recordCostosSelectrik.tipo_documento)THEN
			recordCostosSelectrik.valor_pagado:=0;
			recordCostosSelectrik.vlr_total_abonos:=0;

		ELSE
			_auxDocumento:=recordCostosSelectrik.documento;
			_auxProveedor:=recordCostosSelectrik.proveedor;
			_auxTipoDocumento:=recordCostosSelectrik.tipo_documento;
		END IF;

---		raise notice 'dsds %',recordCostosSelectrik;


		rs.empresa := recordCostosSelectrik.empresa;
		rs.tipo_referencia_1 := recordCostosSelectrik.tipo_referencia_1;
		rs.referencia_1 := recordCostosSelectrik.referencia_1;
		rs.proveedor := recordCostosSelectrik.proveedor;
		rs.nombre_proveedor := recordCostosSelectrik.nombre_proveedor;
		rs.fecha_documento := recordCostosSelectrik.fecha_documento;
		rs.tipo_documento := recordCostosSelectrik.tipo_documento;
		rs.documento := recordCostosSelectrik.documento;
		rs.descripcion := recordCostosSelectrik.descripcion;
		rs.valor_antes_iva := recordCostosSelectrik.valor_antes_iva;
		rs.valor_iva := recordCostosSelectrik.valor_iva;
		rs.valor_total_con_iva := recordCostosSelectrik.valor_total_con_iva;
		rs.valor_pagado := recordCostosSelectrik.valor_pagado;
		rs.vlr_total_abonos := recordCostosSelectrik.vlr_total_abonos;
		rs.fecha_pago := recordCostosSelectrik.fecha_pago;
		rs.vlr_orden_compra := 0.00;
		rs.codigo_cuenta := recordCostosSelectrik.codigo_cuenta;
		rs.nombre_cuenta :=recordCostosSelectrik.nombre_largo;

		return next rs;

	END LOOP;

	--2.)Buscamos los gastos asocidos a comprobantes diarios

	FOR recordCdiar IN (SELECT
				cd.tipo_referencia_1,
				cd.referencia_1 as multiservicio,
				cd.tercero as proveedor,
				get_nombp(cd.tercero) as nombre_proveedor,
				co.fechadoc as fecha_documento,
				cd.tipodoc as tipo_documento,
				cd.numdoc as documento,
				cd.detalle as descripcion,
				cd.valor_debito AS valor_comprobante,
				cd.cuenta,
				c.nombre_largo
			FROM con.comprodet cd
			INNER JOIN con.comprobante co on (cd.grupo_transaccion=co.grupo_transaccion and co.numdoc=cd.numdoc)
			INNER JOIN con.cuentas c on (c.cuenta=cd.cuenta)
			WHERE referencia_1=_multiservicio
			AND substring(cd.cuenta,1,1) in ('G','C')
			AND cd.tipodoc='CDIAR'
	)LOOP

		--raise notice 'recordCdiar %',recordCdiar;

		rs.empresa:='SELECTRIK';
		rs.tipo_referencia_1:=recordCdiar.tipo_referencia_1;
		rs.referencia_1 :=recordCdiar.multiservicio;
		rs.proveedor:=recordCdiar.proveedor;
		rs.nombre_proveedor:=recordCdiar.nombre_proveedor;
		rs.fecha_documento :=recordCdiar.fecha_documento;
		rs.tipo_documento :=recordCdiar.tipo_documento;
		rs.documento :=recordCdiar.documento;
		rs.descripcion :=recordCdiar.descripcion;
		rs.valor_antes_iva :=recordCdiar.valor_comprobante;
		rs.valor_iva := 0.00;
		rs.valor_total_con_iva :=recordCdiar.valor_comprobante;
		rs.valor_pagado :=0.00;
		rs.vlr_total_abonos :=0.00;
		rs.fecha_pago :='01-01-99'::DATE;
		rs.codigo_cuenta :=recordCdiar.cuenta;
		rs.nombre_cuenta :=recordCdiar.nombre_largo;
		return next rs;
	END LOOP;



END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_costos_selectrik(character varying)
  OWNER TO postgres;
