-- Function: generar_re()

-- DROP FUNCTION generar_re();

CREATE OR REPLACE FUNCTION generar_re()
  RETURNS text AS
$BODY$DECLARE
	_respuesta TEXT;
	_fechas_consignacion RECORD;
	_fecha_consignacion date;
	_cuenta_contable CHARACTER VARYING;
	_subclasificacion_corficolombiana CHARACTER VARYING;
	_cod_re CHARACTER VARYING;
	_prefijo_re CHARACTER VARYING;
	_cmc CHARACTER VARYING;
	_rsp TEXT;
BEGIN
	_respuesta:= ' Proceso ejecutado. documentos: ' ;--20100610

	FOR _fechas_consignacion IN

		--se recorren todas las fechas de consignacion de notas de ajuste que tengan pm y que todavia no tengan ref1
		SELECT  i.cuenta, i.fecha_consignacion
		,(select clasificacion1 from con.factura where documento = id.factura) as clasificacion_facturas_corfi
		FROM con.ingreso_detalle id
		     INNER JOIN con.ingreso i ON (i.dstrct=id.dstrct AND i.tipo_documento=id.tipo_documento AND i.num_ingreso=id.num_ingreso)
		WHERE
			(id.ref1='' OR id.ref1 IS NULL) AND
			(id.factura LIKE 'PM%' or id.factura LIKE 'RM%') AND
			i.reg_status!='A' AND
			id.reg_status!='A' AND
			i.tipo_documento='ICA' AND
			i.creation_user='ADMIN' AND
			i.cuenta in ('16252088','16252116','13050705','83251002','13050722','13050728','16252170')
			--and i.fecha_consignacion = '2013-06-28'
		GROUP BY i.cuenta, i.fecha_consignacion, clasificacion_facturas_corfi

	LOOP

		_fecha_consignacion :=_fechas_consignacion.fecha_consignacion;
		_cuenta_contable :=_fechas_consignacion.cuenta;
		_subclasificacion_corficolombiana := _fechas_consignacion.clasificacion_facturas_corfi;

		_cmc = '';
		_prefijo_re = '';

		SELECT INTO _cod_re get_lcod('RE'); --se consigue el nuevo codigo de cxc re

		IF ( _cuenta_contable = '16252088' ) THEN

			IF ( _subclasificacion_corficolombiana = 'CORFIA' ) THEN
				_prefijo_re := 'CORFIA->';
				_cmc := 'OR';
			ELSIF ( _subclasificacion_corficolombiana = 'CORFIB' ) THEN
				_prefijo_re := 'CORFIB->';
				_cmc := 'OR';
			ELSIF ( _subclasificacion_corficolombiana = 'FIDFIV' ) THEN
				_prefijo_re := 'FIDFIV->';
				_cmc := 'SV';
			END IF;

		ELSIF ( _cuenta_contable = '16252116' ) THEN
			_prefijo_re := 'FIDCOP->';
			_cmc := 'EP';

		ELSIF ( _cuenta_contable = '16252170' ) THEN
			_prefijo_re := 'FIDTSP->';
			_cmc := 'RT';

		ELSIF ( _cuenta_contable = '13050705' ) THEN
			_prefijo_re := 'FIDFIV->';
			_cmc := 'RI';

		ELSIF ( _cuenta_contable = '83251002' ) THEN
			_prefijo_re := 'FIDPVC->';
			_cmc := 'CX';


		ELSIF ( _cuenta_contable = '13050728' ) THEN
			_prefijo_re := 'FIDFUP->';
			_cmc := 'FG';

		ELSIF ( _cuenta_contable = '13050722' ) THEN
			_prefijo_re := 'AIRES->';
			_cmc := 'RS';

		END IF;

		_respuesta:= _respuesta || _prefijo_re || _cod_re || '.'; --20100610

		--se inserta una fila que indica que para una fecha de consignacion va a haber una cxc re
		INSERT INTO tem.consignaciones_eca_cxc_re(fecha_consignacion, cxc_re, ultimo, last_update) VALUES (_fecha_consignacion, _cod_re,1, NOW());


		--insercion en factura_detalle (re) con los datos de los detalles de los ingresos
		INSERT INTO con.factura_detalle SELECT '' AS reg_status, 'FINV' AS dstrct, 'FAC' AS tipo_documento
			,_cod_re AS documento
			,tem.getUltimoRe(_cod_re) AS item
			, '8020076706' AS nit, '131' AS concepto, REPLACE(id.factura,'N','P') AS numero_remesa
			,(REPLACE((CASE WHEN id.factura!='' THEN id.factura ELSE id.nitcli END),'N','P') || '_recaudo de ' || i.fecha_consignacion || ' de eca de ica ' || id.num_ingreso || ' en item ' || id.item) AS descripcion, _cuenta_contable AS codigo_cuenta_contable, '1' AS cantidad, --se debe modificar codigo_cuenta_contable
			id.valor_ingreso AS valor_unitario, id.valor_ingreso AS valor_unitariome, id.valor_ingreso AS valor_item, id.valor_ingreso AS valor_itemme, 1 AS valor_tasa,
			'PES' AS moneda, '0099-01-01 00:00:00' AS last_update,  '' AS user_update, NOW() AS creation_date, 'ADMIN' AS creation_user,
			'COL' as BASE, 'RD-' || i.nitcli AS auxiliar, id.valor_ingreso, 'FAC' AS tipo_doc_rel, 0 AS transaccion,
			(id.tipo_documento || '__' || id.num_ingreso || '__' || id.item) AS documento_relacionado
			FROM con.ingreso_detalle id2
				INNER JOIN con.ingreso i ON (i.dstrct=id2.dstrct AND i.tipo_documento=id2.tipo_documento AND i.num_ingreso=id2.num_ingreso)
				LEFT OUTER JOIN con.ingreso_detalle id ON (i.dstrct=id.dstrct AND i.tipo_documento=id.tipo_documento AND i.num_ingreso=id.num_ingreso AND id.reg_status!='A') --20100603
			WHERE (id2.ref1='' OR id2.ref1 IS NULL)
			AND (id2.factura LIKE 'PM%' or id.factura LIKE 'RM%' ) --importante porque factura a veces es vacio en el residuo y tambien deberia aparecer en la re; para eso se puso el left outer join
			AND i.reg_status != 'A'
			AND id2.reg_status != 'A'
			AND i.tipo_documento = 'ICA'
			AND i.fecha_consignacion = _fecha_consignacion --'2010-01-28'
			AND i.creation_user = 'ADMIN'
			AND i.cuenta = _cuenta_contable -- 16252088 | 16252116
			AND (select clasificacion1 from con.factura where documento = id.factura) = _subclasificacion_corficolombiana
			GROUP BY id.factura,i.fecha_consignacion,id.num_ingreso,id.item ,id.valor_ingreso,i.nitcli,id.tipo_documento,id.nitcli
			ORDER BY id.num_ingreso,id.item;

		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		--insercion en factura_detalle (re) que van a la cuenta de los otros ingresos.
		INSERT INTO con.factura_detalle SELECT '' AS reg_status, 'FINV' AS dstrct, 'FAC' AS tipo_documento
			,_cod_re AS documento
			,tem.getUltimoRe(_cod_re) AS item
			, '8020076706' AS nit, '131' AS concepto, REPLACE(id.factura,'N','P') AS numero_remesa
			,(REPLACE((CASE WHEN id.factura!='' THEN id.factura ELSE id.nitcli END),'N','P') || '_recaudo de ' || i.fecha_consignacion || ' de eca de ica ' || id.num_ingreso || ' en item ' || id.item) AS descripcion, _cuenta_contable AS codigo_cuenta_contable, '1' AS cantidad, --se debe modificar codigo_cuenta_contable
			id.valor_ingreso AS valor_unitario, id.valor_ingreso AS valor_unitariome, id.valor_ingreso AS valor_item, id.valor_ingreso AS valor_itemme, 1 AS valor_tasa,
			'PES' AS moneda, '0099-01-01 00:00:00' AS last_update,  '' AS user_update, NOW() AS creation_date, 'ADMIN' AS creation_user,
			'COL' as BASE, 'RD-' || i.nitcli AS auxiliar, id.valor_ingreso, 'FAC' AS tipo_doc_rel, 0 AS transaccion,
			(id.tipo_documento || '__' || id.num_ingreso || '__' || id.item) AS documento_relacionado
			FROM con.ingreso_detalle id2
				INNER JOIN con.ingreso i ON (i.dstrct=id2.dstrct AND i.tipo_documento=id2.tipo_documento AND i.num_ingreso=id2.num_ingreso)
				LEFT OUTER JOIN con.ingreso_detalle id ON (i.dstrct=id.dstrct AND i.tipo_documento=id.tipo_documento AND i.num_ingreso=id.num_ingreso AND id.reg_status!='A') --20100603
			WHERE (id2.ref1='' OR id2.ref1 IS NULL)
			AND (id2.factura LIKE 'PM%' or id.factura LIKE 'RM%' ) --importante porque factura a veces es vacio en el residuo y tambien deberia aparecer en la re; para eso se puso el left outer join
			AND i.reg_status != 'A'
			AND id2.reg_status != 'A'
			AND i.tipo_documento = 'ICA'
			AND i.fecha_consignacion = _fecha_consignacion --'2010-01-28'
			AND i.creation_user = 'ADMIN'
			AND i.cuenta = _cuenta_contable
			AND (select clasificacion1 from con.factura where documento = id.factura) is null
			AND (select clasificacion1 from con.factura where documento = (select factura from con.ingreso_detalle where num_ingreso = id.num_ingreso and item = 1 ) ) = _subclasificacion_corficolombiana
			GROUP BY id.factura,i.fecha_consignacion,id.num_ingreso,id.item ,id.valor_ingreso,i.nitcli,id.tipo_documento,id.nitcli
			ORDER BY id.num_ingreso,id.item;

		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		INSERT INTO con.ingreso_detalle_por_res3
		SELECT idx.reg_status, idx.dstrct, idx.tipo_documento, idx.num_ingreso, idx.item, idx.nitcli,
		       idx.valor_ingreso, idx.valor_ingreso_me, idx.factura, idx.fecha_factura, idx.codigo_retefuente,
		       idx.valor_retefuente, idx.valor_retefuente_me, idx.tipo_doc, idx.documento, idx.codigo_reteica,
		       idx.valor_reteica, idx.valor_reteica_me, idx.valor_diferencia_tasa, idx.creation_user,
		       idx.creation_date, idx.user_update, idx.last_update, idx.base, idx.cuenta, idx.auxiliar,
		       idx.fecha_contabilizacion, idx.fecha_anulacion_contabilizacion, idx.periodo,
		       idx.fecha_anulacion, idx.periodo_anulacion, idx.transaccion, idx.transaccion_anulacion,
		       idx.descripcion, idx.valor_tasa, idx.saldo_factura, idx.procesado, idx.id, idx.ref1,
		       idx.tipo_referencia_1, idx.referencia_1, idx.tipo_referencia_2, idx.referencia_2,
		       idx.tipo_referencia_3, idx.referencia_3, NOW()
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

		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE con.ingreso_detalle idx
		SET ref1=dets_cxc.tipo_documento || '__' || dets_cxc.documento || '__' || dets_cxc.item, last_update=NOW(), user_update='HCUELLO'
		FROM (
		      SELECT fdx.* ,SUBSTR(documento_relacionado,1,3) AS tipo_ica,
			     SUBSTR(REPLACE(documento_relacionado,'ICA__',''),1,STRPOS(REPLACE(documento_relacionado,'ICA__',''),'__')-1) AS num_ica,
			     SUBSTR(REPLACE(documento_relacionado,'ICA__',''),STRPOS(REPLACE(documento_relacionado,'ICA__',''),'__')+2,4) AS item_ica
		      FROM con.factura_detalle fdx
		      WHERE fdx.dstrct='FINV' AND fdx.tipo_documento='FAC' AND fdx.documento=_cod_re) dets_cxc
		WHERE idx.dstrct='FINV'
		      AND idx.tipo_documento= dets_cxc.tipo_ica
		      AND idx.num_ingreso=dets_cxc.num_ica
		      AND idx.item=dets_cxc.item_ica;

		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
		    _cmc as cmc,'' as  usuario_anulo,'' as  formato, '' as agencia_impresion, '' as periodo,0 as  valor_tasa_remesa,
		    '' as negasoc, '0' as num_doc_fen, '0' as obs, '' as pagado_fenalco, '' as corficolombiana, 'fec_ing' as tipo_ref1,
		    _fecha_consignacion as ref1,'Cargue_enfiducia' as  tipo_ref2, _prefijo_re as ref2, '' as dstrct_ultimo_ingreso, '' as tipo_documento_ultimo_ingreso,
		    '' as num_ingreso_ultimo_ingreso, '0' as item_ultimo_ingreso, '0099-01-01 00:00:00' as fec_envio_fiducia
		FROM con.factura_detalle fd
		WHERE fd.dstrct='FINV' AND fd.tipo_documento='FAC' AND fd.documento=_cod_re;

	END LOOP; --fechas_consignacion

	SELECT INTO _rsp actualizar_intereses_mora(5000000);

	RETURN _respuesta;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION generar_re()
  OWNER TO postgres;
COMMENT ON FUNCTION generar_re() IS 'Generar cxc re de eca';
