-- Function: opav.eg_costos_provintegral_consolidado(character varying)

-- DROP FUNCTION opav.eg_costos_provintegral_consolidado(character varying);

CREATE OR REPLACE FUNCTION opav.eg_costos_provintegral_consolidado(_multiservicio character varying)
  RETURNS SETOF opav.rs_reporte_costos_provintegral AS
$BODY$
DECLARE

recordCostosProvi record;
rs opav.rs_reporte_costos_provintegral;
_auxDocumento varchar:='';
_auxProveedor varchar:='';
_auxTipoDocumento varchar:='';
_auxOrdenCompra varchar:='';

BEGIN

	       --raise notice '_multiservicio: %',_multiservicio;
	       FOR recordCostosProvi IN (
						SELECT
							'PROVINTEGRAL'::TEXT AS empresa,
							tipo_referencia_1,
							referencia_1,
							proveedor,
							nombre_proveedor,
							fecha_documento,
							tipo_documento,
							documento,
							descripcion,
							valor_antes_iva ,
							valor_iva,
							total_factura_con_iva,
							valor_pagado,
							vlr_total_abonos,
							fecha_pago,
							cod_orden,
							vlr_orden_compra,
							codigo_cuenta
						FROM
						dblink('dbname=provint
							port=5432
							host=181.57.229.83
							user=postgres
							password=bdversion17'::text,
							'SELECT
								tipo_referencia_1,
								referencia_1,
								proveedor,
								nombre_proveedor,
								fecha_documento,
								tipo_documento,
								documento,
								descripcion,
								SUM(valor_antes_iva) AS valor_antes_iva ,
								SUM(valor_iva) as valor_iva,
								0.00::numeric as total_factura_con_iva ,
								valor_pagado,
								vlr_total_abonos,
								fecha_pago,
								cod_orden,
								vlr_compra AS vlr_orden_compra,
								codigo_cuenta
							FROM (SELECT
								      ''NUMOS''::varchar as tipo_referencia_1,
								      ordencompra.multiservicio as referencia_1,
								      ordencompra.nit_proveedor as  proveedor,
								      get_nombp(ordencompra.nit_proveedor) as nombre_proveedor,
								      cxp.fecha_documento,
								      cxp.tipo_documento,
								      cxp.documento,
								      cxp.descripcion,
								      cxpdet.vlr as valor_antes_iva,
								      coalesce(impuesto.vlr_total_impuesto,0.00) as valor_iva,
								      cxp.vlr_neto as valor_pagado,
								      cxp.vlr_total_abonos,
								      case when cxp.ultima_fecha_pago =''0099-01-01''::date then
									 (SELECT fecha_documento FROM fin.cxp_doc ap
										WHERE ap.documento_relacionado=cxp.documento AND reg_status='''' AND ap.tipo_documento=''NC''
										AND ap.proveedor=ordencompra.nit_proveedor)
								      else  cxp.ultima_fecha_pago end as fecha_pago,
								      ordencompra.cod_orden,
								      sum(ordencompra.vlr_compra) AS vlr_compra,
								      cxpdet.codigo_cuenta
								FROM ordencompra ordencompra
								LEFT JOIN (SELECT fac_prov,cod_orden FROM relacion_oc_fac WHERE reg_status='''' GROUP BY fac_prov,cod_orden) rocxp  on (rocxp.cod_orden=ordencompra.cod_orden)
								LEFT JOIN fin.cxp_doc cxp on (cxp.documento=rocxp.fac_prov and cxp.proveedor=ordencompra.nit_proveedor and cxp.reg_status='''')
								LEFT JOIN fin.cxp_items_doc cxpdet on (cxpdet.documento=cxp.documento and cxpdet.proveedor=cxp.proveedor and cxp.tipo_documento=cxpdet.tipo_documento)
								LEFT JOIN fin.cxp_imp_item  impuesto on (cxpdet.documento=impuesto.documento and cxpdet.proveedor=impuesto.proveedor and  impuesto.cod_impuesto like ''IVA%'' AND impuesto.item=cxpdet.item )
								WHERE  ordencompra.reg_status='''' and cxpdet.codigo_cuenta like ''1435%''
								AND ordencompra.multiservicio='''||_multiservicio||'''
								GROUP BY
								ordencompra.multiservicio,
								ordencompra.nit_proveedor,
								cxp.fecha_documento,
								cxp.tipo_documento,
								cxp.documento,
								cxp.descripcion,
								cxpdet.vlr,
								impuesto.vlr_total_impuesto,
								cxp.vlr_neto,
								cxp.vlr_total_abonos,
								cxp.ultima_fecha_pago,
								ordencompra.cod_orden,
								cxpdet.codigo_cuenta
							)mytable
							GROUP BY
								tipo_referencia_1,
								referencia_1,
								proveedor,
								nombre_proveedor,
								fecha_documento,
								tipo_documento,
								documento,
								descripcion,
								valor_pagado,
								vlr_total_abonos,
								fecha_pago,
								cod_orden,
								vlr_compra,
								codigo_cuenta'::text) tabla (
									tipo_referencia_1 character varying,
									referencia_1 character varying,
									proveedor character varying,
									nombre_proveedor character varying,
									fecha_documento character varying,
									tipo_documento character varying,
									documento character varying,
									descripcion character varying,
									valor_antes_iva numeric ,
									valor_iva numeric,
									total_factura_con_iva numeric,
									valor_pagado numeric,
									vlr_total_abonos numeric,
									fecha_pago date,
									cod_orden character varying,
									vlr_orden_compra numeric,
									codigo_cuenta character varying
									)
					)
		LOOP


			RAISE notice 'valor_antes_iva : % valor_iva : % total_factura_con_iva : %',recordCostosProvi.valor_antes_iva,recordCostosProvi.valor_iva,recordCostosProvi.total_factura_con_iva;

			recordCostosProvi.total_factura_con_iva:=recordCostosProvi.valor_antes_iva+recordCostosProvi.valor_iva;
			IF(_auxDocumento='' and _auxProveedor ='' and _auxTipoDocumento='')THEN

				_auxDocumento:=recordCostosProvi.documento;
				_auxProveedor:=recordCostosProvi.proveedor;
				_auxTipoDocumento:=recordCostosProvi.tipo_documento;

			ELSIF(_auxDocumento=recordCostosProvi.documento and _auxProveedor =recordCostosProvi.proveedor and _auxTipoDocumento =recordCostosProvi.tipo_documento)THEN
				recordCostosProvi.valor_pagado:=0;
				recordCostosProvi.vlr_total_abonos:=0;

			ELSE
				_auxDocumento:=recordCostosProvi.documento;
				_auxProveedor:=recordCostosProvi.proveedor;
				_auxTipoDocumento:=recordCostosProvi.tipo_documento;
			END IF;

			--validamos la orden compra

			IF(_auxOrdenCompra='')THEN
			   _auxOrdenCompra:=recordCostosProvi.cod_orden;
			ELSIF (_auxOrdenCompra=recordCostosProvi.cod_orden)THEN
			    recordCostosProvi.vlr_orden_compra:=0;
			ELSE
			   _auxOrdenCompra:=recordCostosProvi.cod_orden;
			END IF;

			rs:=recordCostosProvi;
			return next rs;
		END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.eg_costos_provintegral_consolidado(character varying)
  OWNER TO postgres;
