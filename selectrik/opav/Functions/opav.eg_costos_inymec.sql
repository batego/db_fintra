-- Function: opav.eg_costos_inymec(character varying)

-- DROP FUNCTION opav.eg_costos_inymec(character varying);

CREATE OR REPLACE FUNCTION opav.eg_costos_inymec(_multiservicio character varying)
  RETURNS SETOF opav.rs_reporte_costos_inymec AS
$BODY$
DECLARE

recordCostosInymec record;
recordCdiar record;
_totalComision numeric:=0;
_auxDocumento varchar:='';
_auxProveedor varchar:='';
_auxTipoDocumento varchar:='';
rs opav.rs_reporte_costos_inymec;
BEGIN

	 raise notice 'multiservicio: %',_multiservicio;

	 FOR recordCostosInymec IN (
					SELECT  'INYMEC'::TEXT as empresa,
						tipo_referencia_1,
						referencia_1,
						proveedor,
						nombre_proveedor,
						fecha_documento,
						tipo_documento,
						documento,
						descripcion,
						valor_antes_iva,
						valor_iva,
						valor_total_con_iva,
						valor_pagado,
						vlr_total_abonos,
						fecha_pago,
						codigo_cuenta,
						nombre_largo
					FROM dblink('dbname=inymec
							port=5432
							host=localhost
							user=postgres
							password=bdversion17'::text,
							'SELECT
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
								case when cxp.ultima_fecha_pago =''0099-01-01''::date then null else  cxp.ultima_fecha_pago end as fecha_pago,
								cxpdet.codigo_cuenta,
								c.nombre_largo
							FROM fin.cxp_doc cxp
							INNER JOIN fin.cxp_items_doc cxpdet on (cxp.documento=cxpdet.documento AND cxp.tipo_documento=cxpdet.tipo_documento and cxp.proveedor=cxpdet.proveedor)
							LEFT JOIN fin.cxp_imp_item  impuesto on (cxpdet.documento=impuesto.documento and cxpdet.proveedor=impuesto.proveedor and  impuesto.cod_impuesto like ''IVA%'' AND impuesto.item=cxpdet.item )
							INNER JOIN con.cuentas c on (c.cuenta=cxpdet.codigo_cuenta)
							WHERE cxp.tipo_referencia_1=''NUMOS''
							AND cxp.reg_status=''''
							AND cxp.referencia_3 !=''ALTER''
							AND cxp.tipo_referencia_3 !=''ALTER''
							AND substring(cxpdet.codigo_cuenta,1,1) in (''C'',''G'')
							AND cxp.referencia_1='''||_multiservicio||'''
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
							order by proveedor'::text) tabla(
											tipo_referencia_1 character varying,
											referencia_1 character varying,
											proveedor character varying,
											nombre_proveedor character varying,
											fecha_documento character varying,
											tipo_documento character varying,
											documento character varying,
											descripcion character varying,
											valor_antes_iva numeric,
											valor_iva numeric,
											valor_total_con_iva numeric,
											valor_pagado numeric,
											vlr_total_abonos numeric,
											fecha_pago date,
											codigo_cuenta character varying,
											nombre_largo varchar
											)
											)

	LOOP
		raise notice 'recordCostosInymec.antes_de_iva : % recordCostosInymec.valor_iva :% ',recordCostosInymec.valor_antes_iva,recordCostosInymec.valor_iva;
		recordCostosInymec.valor_total_con_iva:=recordCostosInymec.valor_antes_iva+recordCostosInymec.valor_iva;

		IF(_auxDocumento='' and _auxProveedor ='' and _auxTipoDocumento='')THEN
			_auxDocumento:=recordCostosInymec.documento;
			_auxProveedor:=recordCostosInymec.proveedor;
			_auxTipoDocumento:=recordCostosInymec.tipo_documento;

		ELSIF(_auxDocumento=recordCostosInymec.documento and _auxProveedor =recordCostosInymec.proveedor and _auxTipoDocumento =recordCostosInymec.tipo_documento)THEN
			recordCostosInymec.valor_pagado:=0;
			recordCostosInymec.vlr_total_abonos:=0;

		ELSE
			_auxDocumento:=recordCostosInymec.documento;
			_auxProveedor:=recordCostosInymec.proveedor;
			_auxTipoDocumento:=recordCostosInymec.tipo_documento;
		END IF;

---		raise notice 'dsds %',recordCostosInymec;


		rs.empresa := recordCostosInymec.empresa;
		rs.tipo_referencia_1 := recordCostosInymec.tipo_referencia_1;
		rs.referencia_1 := recordCostosInymec.referencia_1;
		rs.proveedor := recordCostosInymec.proveedor;
		rs.nombre_proveedor := recordCostosInymec.nombre_proveedor;
		rs.fecha_documento := recordCostosInymec.fecha_documento;
		rs.tipo_documento := recordCostosInymec.tipo_documento;
		rs.documento := recordCostosInymec.documento;
		rs.descripcion := recordCostosInymec.descripcion;
		rs.valor_antes_iva := recordCostosInymec.valor_antes_iva;
		rs.valor_iva := recordCostosInymec.valor_iva;
		rs.valor_total_con_iva := recordCostosInymec.valor_total_con_iva;
		rs.valor_pagado := recordCostosInymec.valor_pagado;
		rs.vlr_total_abonos := recordCostosInymec.vlr_total_abonos;
		rs.fecha_pago := recordCostosInymec.fecha_pago;
		rs.vlr_orden_compra := 0.00;
		rs.codigo_cuenta := recordCostosInymec.codigo_cuenta;
		rs.nombre_cuenta :=recordCostosInymec.nombre_largo;


		return next rs;

	END LOOP;

	--2.)Buscamos los gastos asocidos a comprobantes diarios

	FOR recordCdiar IN (SELECT  tipo_referencia_1,
					multiservicio ,
					proveedor ,
					nombre_proveedor ,
					fecha_documento ,
					tipo_documento ,
					documento ,
					descripcion ,
					valor_comprobante,
					cuenta,
					nombre_largo
				FROM dblink('dbname=inymec
					port=5432
					host=localhost
					user=postgres
					password=bdversion17'::text,
					'SELECT
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
					WHERE referencia_1='''||_multiservicio||'''
					AND substring(cd.cuenta,1,1) in (''G'',''C'')
					AND cd.tipodoc=''CDIAR'''::text)tabla
					(tipo_referencia_1 varchar,
					multiservicio varchar,
					proveedor varchar,
					nombre_proveedor varchar,
					fecha_documento varchar,
					tipo_documento varchar,
					documento varchar,
					descripcion varchar,
					valor_comprobante numeric,
					cuenta varchar,
					nombre_largo varchar)
	)LOOP

		raise notice 'recordCdiar %',recordCdiar;

		rs.empresa:='INYMEC';
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
ALTER FUNCTION opav.eg_costos_inymec(character varying)
  OWNER TO postgres;
