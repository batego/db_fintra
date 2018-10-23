-- Function: dv_reporte_ordencompra()

-- DROP FUNCTION dv_reporte_ordencompra();

CREATE OR REPLACE FUNCTION dv_reporte_ordencompra()
  RETURNS SETOF record AS
$BODY$

DECLARE

	RsOcompra record;

BEGIN

	FOR RsOcompra IN

		SELECT
		(CASE WHEN oferta.num_os != '' THEN oferta.num_os
			ELSE oferta.aviso
		END) as Multiservicio_o_Aviso,
		--oferta.cliente,
		proveedor.payment_name as proveedor,
		proveedor.nit as nit_proveedor,
		replace(orden.consecutivo, 'OC', '') as orden_compra,
		--sum(compra.vlr_compra) as valor_oc,
		(select sum(compra.vlr_compra) from ordencompra where cod_orden= orden.consecutivo limit 1) as vlr_oc,
		orden.fecha::Date as fecha_oc,
		cxp.documento as factura,
		cxp.fecha_documento as fecha_factura,
		cxpd.vlr as vlr_sin_iva,
		cxpi.vlr_total_impuesto as iva,
		cxp.vlr_neto as vl_a_pagar_factura,
		cxp.vlr_total_abonos as vl_abono_factura,
		cxp.vlr_saldo as vl_saldo_factura,
		cxp.ultima_fecha_pago,
		e.document_no as egreso,
		e.vlr as vlr_egreso,
		e.branch_code
		FROM ordencompra compra
		INNER JOIN orden ON (orden.reg_status != 'A' AND compra.cod_orden = orden.consecutivo)
		LEFT JOIN fin.cxp_doc cxp ON cxp.documento = compra.documento_cxp AND tipo_documento='FAP' AND cxp.proveedor = orden.Proveedor_nit
		INNER JOIN fin.cxp_items_doc cxpd ON (cxpd.documento = cxp.documento)
		INNER JOIN fin.cxp_imp_doc cxpi ON (cxpi.documento = cxp.documento and cod_impuesto = 'IVA02')
		INNER JOIN egreso e ON (e.document_no=cxp.cheque and e.nit=cxp.proveedor)
		INNER JOIN dblink('dbname=selectrik port=5432 host=162.242.200.185 user=postgres password=bdversion17','Select of.id_solicitud, of.num_os, of.aviso,
			    (SELECT nomcli FROM cliente WHERE codcli = of.id_cliente) as cliente
			    FROM opav.ofertas of
			    WHERE of.reg_status != ''A''
			    AND (of.num_os != '''' OR of.aviso != '''')')
		AS oferta (id_solicitud character varying(15), num_os character varying(15), aviso character varying(30),
			   cliente character varying(160)) ON oferta.id_solicitud = compra.multiservicio
		/*LEFT JOIN dblink('dbname=selectrik port=5432 host=162.242.200.185 user=postgres password=bdversion17','SELECT id_contratista, descripcion
			    FROM opav.app_contratistas
			    WHERE  reg_status != ''A'' ')
		AS contratista (id character varying(20), contratista character varying(60)) ON contratista.id = orden.contratista*/
		INNER JOIN proveedor ON proveedor.nit = orden.proveedor_nit
		WHERE --orden.fecha::Date BETWEEN ? AND ?
		orden.consecutivo = 'OC0009273'
		group by  orden.fecha, oferta.num_os, oferta.aviso, proveedor.nit, proveedor.payment_name, orden.consecutivo,cxp.vlr_neto,cxp.vlr_total_abonos,cxp.vlr_saldo,
		cxp.ultima_fecha_pago,e.document_no,e.vlr,cxp.fecha_documento,e.branch_code,cxp.documento,oferta.cliente,cxpd.vlr,cxpi.vlr_total_impuesto
		ORDER BY orden.fecha,multiservicio_o_aviso,factura

	LOOP

		RETURN NEXT RsOcompra;

	END LOOP;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_reporte_ordencompra()
  OWNER TO postgres;
