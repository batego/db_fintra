-- Function: corregir_fechas_contables_cxps_ec()

-- DROP FUNCTION corregir_fechas_contables_cxps_ec();

CREATE OR REPLACE FUNCTION corregir_fechas_contables_cxps_ec()
  RETURNS text AS
$BODY$DECLARE
    _group RECORD;
    _count INTEGER;
    code_sql TEXT;
    respuesta TEXT;

BEGIN
    FOR _group IN

SELECT * FROM (
	SELECT  SUBSTR(fec_open,1,4) || SUBSTR(fec_open,6,2) AS periodo_open  ,
		SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),1,4) || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),6,2) AS nuevo_periodo  ,
		(CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END) AS nueva_fecha
		,*,
		'UPDATE fin.cxp_doc SET periodo=''' || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),1,4) || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),6,2) || ''',fecha_documento=''' || (CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END) || ''' WHERE proveedor=''' || proveedor || ''' AND tipo_documento=''' || tipo_documento || ''' AND documento=''' || documento || '''; ' AS correccion_fechaYperiodo_operativa_cxp,

		'UPDATE con.comprobante SET periodo=''' || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),1,4) || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),6,2) || ''',fechadoc=''' || (CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END) || ''' WHERE numdoc=''' || numdoc || ''' AND tipodoc=''' || tipodoc || ''' AND grupo_transaccion=''' || grupo_transaccion || ''';' AS correccion_fechaYperiodo_operativa_comprobantes,

		'UPDATE con.comprodet SET periodo=''' || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),1,4) || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),6,2) || ''' WHERE numdoc=''' || numdoc || ''' AND tipodoc=''' || tipodoc || '''  AND grupo_transaccion=''' || grupo_transaccion || ''';' AS correccion_fechaYperiodo_operativa_comprodet

	FROM (
		SELECT (SELECT MAX(f_facturado_cliente)
					FROM app_accord
					WHERE id_orden=o.id_orden AND id_contratista!='CC027'
					GROUP BY id_orden) AS fec_open	,
		c.periodo AS periodo_factura, com.periodo AS periodo_comprobante, c.fecha_documento AS fecha_factura,com.fechadoc AS fecha_comprobante,
		tipodoc, numdoc, grupo_transaccion,c.dstrct, tipo_documento, documento,proveedor
		FROM fin.cxp_doc c,con.comprobante com,app_ofertas o
		WHERE SUBSTR(documento,1,2) IN ('EC') AND proveedor='8020076706' AND tipo_documento IN ('FAP')  AND numdoc=documento AND SUBSTR(documento,1,7)=SUBSTR(factura_comision_eca,1,7)

	) ali
	ORDER BY numdoc
)	correccion_contable_cxps_pr
WHERE periodo_factura!=nuevo_periodo OR periodo_factura!=periodo_comprobante OR fecha_factura!=nueva_fecha OR fecha_comprobante!=fecha_factura


LOOP
 IF (NOT (_group.correccion_fechaYperiodo_operativa_cxp IS NULL)) THEN
    code_sql:=_group.correccion_fechaYperiodo_operativa_cxp || _group.correccion_fechaYperiodo_operativa_comprobantes || _group.correccion_fechaYperiodo_operativa_comprodet;
 END IF;

    EXECUTE(code_sql);

    END LOOP;
    SELECT INTO respuesta 'Proceso ejecutado.';
    RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION corregir_fechas_contables_cxps_ec()
  OWNER TO postgres;
