-- Function: generar_re2()

-- DROP FUNCTION generar_re2();

CREATE OR REPLACE FUNCTION generar_re2()
  RETURNS text AS
$BODY$DECLARE
  _respuesta TEXT;
  _fechas_consignacion RECORD;
  _fecha_consignacion date;
  _cod_re CHARACTER VARYING;
  _rsp TEXT;
  sql TEXT;
BEGIN
_respuesta:= ' Proceso ejecutado. documentos: ' ;--20100610

FOR _fechas_consignacion IN	(SELECT i.fecha_consignacion
		FROM con.ingreso_detalle id
			INNER JOIN
			con.ingreso i ON (i.dstrct=id.dstrct AND i.tipo_documento=id.tipo_documento AND i.num_ingreso=id.num_ingreso)
		WHERE (id.ref1='' OR id.ref1 IS NULL)
			AND (id.factura LIKE 'PM%' or id.factura LIKE 'RM%')
			AND i.reg_status!='A'
			AND id.reg_status!='A'
			AND i.tipo_documento='ICA'--20100603
			AND i.creation_user='ADMIN'  AND i.cuenta='16252088'--20100610
			--AND id.creation_user='NAVIRE' --20100603
		GROUP BY i.fecha_consignacion) LOOP
		--se recorren todas las fechas de consignacion de notas de ajuste que tengan pm y que todavia no tengan ref1

	_fecha_consignacion :=_fechas_consignacion.fecha_consignacion;

	SELECT INTO _cod_re get_lcod('RE');--se consigue el nuevo codigo de cxc re

	_respuesta:= _respuesta || _cod_re || '.';--20100610

	INSERT INTO tem.consignaciones_eca_cxc_re(
            fecha_consignacion, cxc_re, ultimo, last_update)
		VALUES (_fecha_consignacion, _cod_re,1, NOW());
		--se inserta una fila que indica que para una fecha de consignacion va a haber una cxc re

		--insercion en factura_detalle (re) con los datos de los detalles de los ingresos
		INSERT INTO con.factura_detalle SELECT '' AS reg_status, 'FINV' AS dstrct, 'FAC' AS tipo_documento
		  ,_cod_re AS documento
		  ,tem.getUltimoRe(_cod_re) AS item
		 , '8020076706' AS nit, '131' AS concepto, REPLACE(id.factura,'N','P') AS numero_remesa
		 ,(REPLACE((CASE WHEN id.factura!='' THEN id.factura ELSE id.nitcli END),'N','P') || '_recaudo de ' || i.fecha_consignacion || ' de eca de ica ' || id.num_ingreso || ' en item ' || id.item) AS descripcion, '16252088' AS codigo_cuenta_contable, '1' AS cantidad, --se debe modificar codigo_cuenta_contable
		       id.valor_ingreso AS valor_unitario, id.valor_ingreso AS valor_unitariome, id.valor_ingreso AS valor_item, id.valor_ingreso AS valor_itemme, 1 AS valor_tasa,
		       'PES' AS moneda, '0099-01-01 00:00:00' AS last_update,  '' AS user_update, NOW() AS creation_date, 'ADMIN' AS creation_user,
		       'COL' as BASE, 'RD-' || i.nitcli AS auxiliar, id.valor_ingreso, 'FAC' AS tipo_doc_rel, 0 AS transaccion,
		       (id.tipo_documento || '__' || id.num_ingreso || '__' || id.item) AS documento_relacionado
		 FROM con.ingreso_detalle id2--20100603
				INNER JOIN
				con.ingreso i ON (i.dstrct=id2.dstrct AND i.tipo_documento=id2.tipo_documento AND i.num_ingreso=id2.num_ingreso)
				LEFT OUTER JOIN con.ingreso_detalle id ON (i.dstrct=id.dstrct AND i.tipo_documento=id.tipo_documento AND i.num_ingreso=id.num_ingreso AND id.reg_status!='A')--20100603
			WHERE (id2.ref1='' OR id2.ref1 IS NULL)
				AND (id2.factura LIKE 'PM%' or id.factura LIKE 'RM%' )--importante porque factura a veces es vacio en el residuo y tambien deberia aparecer en la re; para eso se puso el left outer join
				AND i.reg_status!='A'
				AND id2.reg_status!='A'
				AND i.tipo_documento='ICA'--20100603
				--AND i.num_ingreso IN ('IA094909')
				--AND id.creation_user='NAVIRE'
				AND i.fecha_consignacion=_fecha_consignacion--'2010-01-28'
				AND i.creation_user='ADMIN'  AND i.cuenta='16252088'--20100610
		GROUP BY id.factura,i.fecha_consignacion,id.num_ingreso,id.item ,id.valor_ingreso,i.nitcli,id.tipo_documento,id.nitcli
		ORDER BY id.num_ingreso,id.item;

 sql:='INSERT INTO copia.ingreso_detalle_por_res3
   SELECT idx.*,NOW()
   FROM con.ingreso_detalle idx,
    (SELECT fdx.* ,SUBSTR(documento_relacionado,1,3) AS tipo_ica,
     SUBSTR(REPLACE(documento_relacionado,''ICA__'',''''),1,STRPOS(REPLACE(documento_relacionado,''ICA__'',''''),''__'')-1) AS num_ica,
     SUBSTR(REPLACE(documento_relacionado,''ICA__'',''''),STRPOS(REPLACE(documento_relacionado,''ICA__'',''''),''__'')+2,4) AS item_ica
     FROM con.factura_detalle fdx
     WHERE fdx.dstrct=''FINV'' AND fdx.tipo_documento=''FAC'' AND fdx.documento='||quote_literal(_cod_re)||') dets_cxc
   WHERE idx.dstrct=''FINV''
    AND idx.tipo_documento= dets_cxc.tipo_ica
    AND idx.num_ingreso=dets_cxc.num_ica
    AND idx.item=dets_cxc.item_ica;';

	raise notice '%',sql;

		INSERT INTO copia.ingreso_detalle_por_res3
			SELECT idx.*,NOW()
			FROM con.ingreso_detalle idx,
				(SELECT fdx.* ,SUBSTR(documento_relacionado,1,3) AS tipo_ica,
					SUBSTR(REPLACE(documento_relacionado,'ICA__',''),1,STRPOS(REPLACE(documento_relacionado,'ICA__',''),'__')-1) AS num_ica,
					SUBSTR(REPLACE(documento_relacionado,'ICA__',''),STRPOS(REPLACE(documento_relacionado,'ICA__',''),'__')+2,4) AS item_ica
				 FROM con.factura_detalle fdx
				 WHERE fdx.dstrct='FINV' AND fdx.tipo_documento='FAC' AND fdx.documento=_cod_re) dets_cxc
			WHERE idx.dstrct='FINV'
				AND idx.tipo_documento= dets_cxc.tipo_ica
				AND idx.num_ingreso=dets_cxc.num_ica
				AND idx.item=dets_cxc.item_ica;



		UPDATE con.ingreso_detalle idx
		SET ref1=dets_cxc.tipo_documento || '__' || dets_cxc.documento || '__' || dets_cxc.item
			,last_update=NOW()
			,user_update='NAVIRE'
		FROM (SELECT fdx.* ,SUBSTR(documento_relacionado,1,3) AS tipo_ica,
				SUBSTR(REPLACE(documento_relacionado,'ICA__',''),1,STRPOS(REPLACE(documento_relacionado,'ICA__',''),'__')-1) AS num_ica,
				SUBSTR(REPLACE(documento_relacionado,'ICA__',''),STRPOS(REPLACE(documento_relacionado,'ICA__',''),'__')+2,4) AS item_ica
		      FROM con.factura_detalle fdx
		      WHERE fdx.dstrct='FINV' AND fdx.tipo_documento='FAC' AND fdx.documento=_cod_re) dets_cxc
		WHERE idx.dstrct='FINV'
			AND idx.tipo_documento= dets_cxc.tipo_ica
			AND idx.num_ingreso=dets_cxc.num_ica
			AND idx.item=dets_cxc.item_ica;

		INSERT INTO con.factura   SELECT '' AS reg_status , 'FINV' AS dstrct, 'FAC' AS tipo_documento, _cod_re AS documento, '8020076706' AS nit, 'CL00932' AS codcli, '131' AS concepto,
		    _fecha_consignacion as fecha_factura, _fecha_consignacion+interval'1 month' as fecha_vencimiento, '0099-01-01' as fecha_ultimo_pago, '0099-01-01' as fecha_impresion,
		    'recaudo de ' || _fecha_consignacion || ' de eca' as descripcion, 'recaudo de ' || _fecha_consignacion || ' de eca' as observacion
		   ,  SUM(valor_item)   AS valor_factura, 0 as valor_abono
		   ,  SUM(valor_item)   as valor_saldo,
		      SUM(valor_item)   as valor_facturame, 0 as valor_abonome,
		      SUM(valor_item)   as valor_saldome, '1' as tasa, 'PES' as moneda,
		      count(valor_item) AS cantidad_items,
			'CREDITO' AS forma_pago, 'OP' as agencia_facturacion, 'BQ' as agencia_cobro,
		    '' as zona, '' as clasificacion1, '' as clasificacion2, '' as clasificacion3, 0 as transaccion,
		    0 as transaccion_anulacion, '0099-01-01 00:00:00' as fecha_contabilizacion, '0099-01-01 00:00:00' as fecha_anulacion,
		    '0099-01-01 00:00:00' as fecha_contabilizacion_anulacion, 'COL' as base,'0099-01-01 00:00:00' as  last_update,'' as  user_update,
		    now() as creation_date, 'NAVINSERT' as creation_user, '0099-01-01' as fecha_probable_pago,'S' as  flujo,'' as  rif,
		    'OR' as cmc,'' as  usuario_anulo,'' as  formato, '' as agencia_impresion, '' as periodo,0 as  valor_tasa_remesa,
		    '' as negasoc, '0' as num_doc_fen, '0' as obs, '' as pagado_fenalco, '' as corficolombiana, 'fec_ing' as tipo_ref1,
		    _fecha_consignacion as ref1,'' as  tipo_ref2, '' as ref2, '' as dstrct_ultimo_ingreso, '' as tipo_documento_ultimo_ingreso,
		    '' as num_ingreso_ultimo_ingreso, '0' as item_ultimo_ingreso, '0099-01-01 00:00:00' as fec_envio_fiducia
		FROM con.factura_detalle fd
		WHERE fd.dstrct='FINV' AND fd.tipo_documento='FAC' AND fd.documento=_cod_re;

END LOOP; --fechas_consignacion
SELECT INTO _rsp actualizar_intereses_mora(5000000);
  RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION generar_re2()
  OWNER TO postgres;
COMMENT ON FUNCTION generar_re2() IS 'Generar cxc re de eca';
