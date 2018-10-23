-- Function: kill_cxp_eca(text)

-- DROP FUNCTION kill_cxp_eca(text);

CREATE OR REPLACE FUNCTION kill_cxp_eca(text)
  RETURNS text AS
$BODY$DECLARE
  fccperiodo  ALIAS  FOR  $1;
---------------------------NOTAS CREDITO CABECERAS--------------------------------------
BEGIN

INSERT INTO fin.cxp_doc

select	'', 'FINV', cp.proveedor, 'NC', cp.documento||fccperiodo, 'RECUADO DE FACT '||fc.documento , 'BQ', 'ME', '', 'FAP', cp.proveedor, '0099-01-01 00:00:00', 
	'JGOMEZ', '', 'BANCOLOMBIA', 'CPAG', 'PES',
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end, 0, 
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end, 
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end, 0, 
        case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end,
	1.0000000000, '', '0099-01-01 00:00:00', '', '0099-01-01 00:00:00', '0099-01-01 00:00:00', '', 0, 0, 0, NOW(), 'ADMINM', NOW(), 'ADMINM', 'COL', '', '', '',
	'0099-01-01 00:00:00', '0099-01-01 00:00:00', '0099-01-01 00:00:00', '', '', '', '', 0, 0, '4', 0, 'PES', cp.fecha_documento, cp.fecha_documento, '0099-01-01', 'S', 0, 'N', '4'

from tem.consulta_ivan ci
	left join con.factura fc ON (fc.dstrct='FINV' and fc.tipo_documento='FAC'  and fc.documento=ci.cxc and fc.reg_status='')
	left join fin.cxp_doc cp ON (cp.documento=ci.cxp_ec and cp.reg_status='' and cp.proveedor='8020076706' and cp.dstrct='FINV' and cp.tipo_documento='FAP')
where periodo_consignacion IN(fccperiodo)
group by fc.documento,cp.documento||fccperiodo,fc.valor_factura,fc.valor_saldo,cp.vlr_neto,cp.vlr_saldo,cp.proveedor,cp.fecha_documento;


---------------------------NOTAS DE AJUSTE DETALLES--------------------------------------



INSERT	INTO fin.cxp_items_doc

select	'', 'FINV', cp.proveedor, 'NC', cp.documento||fccperiodo, '001', 
	'RECUADO DE FACT '||fc.documento , 
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end,
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end,
        '16252085', '', '', NOW(), 'ADMINM', NOW(), 'ADMINM', 'COL', '','','',''

from tem.consulta_ivan ci
	left join con.factura fc ON (fc.dstrct='FINV' and fc.tipo_documento='FAC'  and fc.documento=ci.cxc and fc.reg_status='')
	left join fin.cxp_doc cp ON (cp.documento=ci.cxp_ec and cp.reg_status='' and cp.proveedor='8020076706' and cp.dstrct='FINV' and cp.tipo_documento='FAP')
where periodo_consignacion IN(fccperiodo)
group by fc.documento,cp.proveedor,cp.documento||fccperiodo,fc.valor_factura,fc.valor_saldo,cp.vlr_neto,cp.vlr_saldo;


------------------cxp del mes------------------------------------

---------------------------CABECERA-------------------------------

INSERT INTO fin.cxp_doc

select reg_status, dstrct, proveedor, 'FAP', 'EC'||fccperiodo, 'FACTURA GLOBAL PARA NC DEL PERIODO'|| fccperiodo, 
		agencia, handle_code, id_mims, '', '', 
		fecha_aprobacion, aprobador, usuario_aprobacion, banco, sucursal, 
		moneda, sum(vlr_neto), 0, sum(vlr_neto), sum(vlr_neto), 0, 
		sum(vlr_neto), tasa, usuario_contabilizo, fecha_contabilizacion, 
		usuario_anulo, fecha_anulacion, fecha_contabilizacion_anulacion, 
		observacion, num_obs_autorizador, num_obs_pagador, num_obs_registra, 
		last_update, user_update, creation_date, creation_user, base, 
		corrida, cheque, periodo, fecha_procesado, fecha_contabilizacion_ajc, 
		fecha_contabilizacion_ajv, periodo_ajc, periodo_ajv, usuario_contabilizo_ajc, 
		usuario_contabilizo_ajv, transaccion_ajc, transaccion_ajv, clase_documento, 
		transaccion, moneda_banco, max(fecha_documento), max(fecha_vencimiento), 
		ultima_fecha_pago, flujo, transaccion_anulacion, ret_pago, clase_documento_rel
from
(((select * from fin.cxp_doc limit 1) EXCEPT (select * from fin.cxp_doc limit 1))
union
(select	'', 'FINV', cp.proveedor, 'NC', cp.documento||fccperiodo, 'RECUADO DE FACT '||fc.documento , 'BQ', 'PE', '', 'FAP', cp.proveedor, '0099-01-01 00:00:00', 
	'JGOMEZ', '', 'BANCOLOMBIA', 'CPAG', 'PES',
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end, 0, 
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end, 
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end, 0, 
        case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end,
	1.0000000000, '', '0099-01-01 00:00:00', '', '0099-01-01 00:00:00', '0099-01-01 00:00:00', '', 0, 0, 0, NOW(), 'ADMINM', NOW(), 'ADMINM', 'COL', '', '', '',
	'0099-01-01 00:00:00', '0099-01-01 00:00:00', '0099-01-01 00:00:00', '', '', '', '', 0, 0, '4', 0, 'PES', cp.fecha_documento, cp.fecha_documento, '0099-01-01', 'S', 0, 'N', '4'

from tem.consulta_ivan ci
	left join con.factura fc ON (fc.dstrct='FINV' and fc.tipo_documento='FAC'  and fc.documento=ci.cxc and fc.reg_status='')
	left join fin.cxp_doc cp ON (cp.documento=ci.cxp_ec and cp.reg_status='' and cp.proveedor='8020076706' and cp.dstrct='FINV' and cp.tipo_documento='FAP')
where periodo_consignacion IN(fccperiodo)
group by fc.documento,cp.documento||fccperiodo,fc.valor_factura,fc.valor_saldo,cp.vlr_neto,cp.vlr_saldo,cp.proveedor,cp.fecha_documento))as foo
group by	reg_status, dstrct, proveedor, tipo_documento,  
		agencia, handle_code, id_mims, tipo_documento_rel, documento_relacionado, 
		fecha_aprobacion, aprobador, usuario_aprobacion, banco, sucursal, 
		moneda, tasa, usuario_contabilizo, fecha_contabilizacion, 
		usuario_anulo, fecha_anulacion, fecha_contabilizacion_anulacion, 
		observacion, num_obs_autorizador, num_obs_pagador, num_obs_registra, 
		last_update, user_update, creation_date, creation_user, base, 
		corrida, cheque, periodo, fecha_procesado, fecha_contabilizacion_ajc, 
		fecha_contabilizacion_ajv, periodo_ajc, periodo_ajv, usuario_contabilizo_ajc, 
		usuario_contabilizo_ajv, transaccion_ajc, transaccion_ajv, clase_documento, 
		transaccion, moneda_banco,
		ultima_fecha_pago, flujo, transaccion_anulacion, ret_pago, clase_documento_rel;

----------------------DETALLES-----------------------------------------------------------------


INSERT	INTO fin.cxp_items_doc

select	'', 'FINV', cp.proveedor, 'FAP', 'EC'||fccperiodo, 
	((select count(*) from (
	select cpp.oid,cp.documento,cii.periodo_consignacion
	from tem.consulta_ivan cii
		LEFT JOIN con.factura fcc ON (fcc.dstrct='FINV' and fcc.tipo_documento='FAC'  and fcc.documento=cii.cxc and fcc.reg_status='')
		LEFT JOIN fin.cxp_doc cpp ON (cpp.documento=cii.cxp_ec and cpp.reg_status='' and cpp.proveedor='8020076706' and cpp.dstrct='FINV' and cpp.tipo_documento='FAP')
	group by fcc.documento,cpp.proveedor,cpp.documento,fcc.valor_factura,fcc.valor_saldo,cpp.vlr_neto,cpp.vlr_saldo,cpp.oid,cii.periodo_consignacion) as foo
	where foo.oid<cp.oid and foo.periodo_consignacion IN(fccperiodo))+1) as item, 
	'RECUADO DE FACT '||fc.documento , 
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end,
	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
	then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
	else cp.vlr_saldo end,
        '16252085', '', '', NOW(), 'ADMINM', NOW(), 'ADMINM', 'COL', '','','',''

from tem.consulta_ivan ci
	left join con.factura fc ON (fc.dstrct='FINV' and fc.tipo_documento='FAC'  and fc.documento=ci.cxc and fc.reg_status='')
	left join fin.cxp_doc cp ON (cp.documento=ci.cxp_ec and cp.reg_status='' and cp.proveedor='8020076706' and cp.dstrct='FINV' and cp.tipo_documento='FAP')
where periodo_consignacion IN(fccperiodo)
group by fc.documento,cp.proveedor,cp.documento,fc.valor_factura,fc.valor_saldo,cp.vlr_neto,cp.vlr_saldo,cp.oid;

---------------------------BAJAR SALDOS A CXPS------------------------------------------------
EXECUTE (select list(sql) from(
select 'UPDATE fin.cxp_doc SET vlr_total_abonos=vlr_total_abonos+'||	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
							then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
							else cp.vlr_saldo end ||
				', vlr_saldo=vlr_saldo-'|| case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
							     then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
							     else cp.vlr_saldo end ||
				', vlr_total_abonos_me=vlr_total_abonos_me+'||	case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
							then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
							else cp.vlr_saldo end ||
				', vlr_saldo_me=vlr_saldo_me-'|| case when cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura)<cp.vlr_saldo 
							     then round(cp.vlr_neto*(sum(valor_ingreso)/fc.valor_factura),2) 
							     else cp.vlr_saldo end ||'
WHERE documento='''||cp.documento||''' AND tipo_documento=''FAP'' AND proveedor='''||cp.proveedor||''';
' as sql
from tem.consulta_ivan ci
	left join con.factura fc ON (fc.dstrct='FINV' and fc.tipo_documento='FAC'  and fc.documento=ci.cxc and fc.reg_status='')
	left join fin.cxp_doc cp ON (cp.documento=ci.cxp_ec and cp.reg_status='' and cp.proveedor='8020076706' and cp.dstrct='FINV' and cp.tipo_documento='FAP')
where periodo_consignacion IN(fccperiodo)
group by fc.documento,cp.proveedor,cp.documento,fc.valor_factura,fc.valor_saldo,cp.vlr_neto,cp.vlr_saldo
) as foo);
RETURN 'OK';
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION kill_cxp_eca(text)
  OWNER TO postgres;
COMMENT ON FUNCTION kill_cxp_eca(text) IS 'Mata las cxp EC de un determinado periodo con NCs y crea una cxp detallada por el valor total de las NCs';

