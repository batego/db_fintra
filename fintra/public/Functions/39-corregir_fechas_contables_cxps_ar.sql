-- Function: corregir_fechas_contables_cxps_ar()

-- DROP FUNCTION corregir_fechas_contables_cxps_ar();

CREATE OR REPLACE FUNCTION corregir_fechas_contables_cxps_ar()
  RETURNS text AS
$BODY$DECLARE
    _group RECORD;
    _count INTEGER;
    code_sql TEXT;
    respuesta TEXT;

BEGIN
    code_sql:='';
    FOR _group IN

SELECT * FROM (
	SELECT  SUBSTR(fec_open,1,4) || SUBSTR(fec_open,6,2) AS periodo_open  ,
		SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),1,4) || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),6,2) AS nuevo_periodo  ,
		(CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END) AS nueva_fecha
		,*,

		SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),1,4) || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),6,2) AS periodo9  ,
		'UPDATE fin.cxp_doc SET periodo=''' || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),1,4) || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),6,2) || ''',fecha_documento=''' || (CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END) || ''' WHERE proveedor=''' || proveedor || ''' AND tipo_documento=''' || tipo_documento || ''' AND documento=''' || documento || '''; ' AS correccion_cxp,

		'UPDATE con.comprobante SET periodo=''' || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),1,4) || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),6,2) || ''',fechadoc=''' || (CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END) || ''' WHERE numdoc=''' || numdoc || ''' AND tipodoc=''' || tipodoc || ''' AND grupo_transaccion=''' || grupo_transaccion || ''';' AS correccion_fec_comp,

		'UPDATE con.comprodet SET periodo=''' || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),1,4) || SUBSTR((CASE WHEN fec_open<'2009-01-01' THEN '2009-01-11' ELSE fec_open END),6,2) || ''' WHERE numdoc=''' || numdoc || ''' AND tipodoc=''' || tipodoc || '''  AND grupo_transaccion=''' || grupo_transaccion || ''';' AS correccion_fec_comp_det

	FROM (
		SELECT (SELECT MAX(f_facturado_cliente)
					FROM app_accord
					WHERE factura_retencion=c.documento
					GROUP BY factura_retencion) AS fec_open
		,c.periodo AS periodo_factura, com.periodo AS periodo_comprobante, c.fecha_documento AS fecha_factura,com.fechadoc AS fecha_comprobante,
		tipodoc, numdoc, grupo_transaccion,c.dstrct, tipo_documento, documento,proveedor
		FROM fin.cxp_doc c,con.comprobante com
		WHERE SUBSTR(documento,1,2) IN ('AR') AND proveedor='9002335631' AND tipo_documento IN ('FAP')  AND numdoc=documento AND tipodoc='FAP'

	) ali
) correccion_contable_cxps_ar
WHERE periodo_factura!=nuevo_periodo OR periodo_factura!=periodo_comprobante OR fecha_factura!=nueva_fecha OR fecha_comprobante!=fecha_factura


LOOP
 IF (NOT (_group.correccion_cxp IS NULL)) THEN
    code_sql:=_group.correccion_cxp || _group.correccion_fec_comp || _group.correccion_fec_comp_det;
 END IF;

    EXECUTE(code_sql);

    END LOOP;
    SELECT INTO respuesta 'Proceso ejecutado.';
    RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION corregir_fechas_contables_cxps_ar()
  OWNER TO postgres;
