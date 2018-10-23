-- Function: kill_cxp_ecaii()

-- DROP FUNCTION kill_cxp_ecaii();

CREATE OR REPLACE FUNCTION kill_cxp_ecaii()
  RETURNS text AS
$BODY$DECLARE
BEGIN
---------------------------NOTAS CREDITO CABECERAS--------------------------------------

insert into fin.cxp_doc
--(select * from fin.cxp_doc where tipo_documento='NC' limit 1 ) union all
(select	'', 'FINV', cp.proveedor, 'NC', cp.documento, list(cip.descripcion), 'BQ', cp.handle_code, '', 'FAP', cp.proveedor, '0099-01-01 00:00:00', 
	'JGOMEZ', '', 'BANCOLOMBIA', 'CPAG', 'PES',
	cp.vlr_neto, 0,cp.vlr_neto, cp.vlr_neto, 0,cp.vlr_neto,
	1.0000000000, '', '0099-01-01 00:00:00', '', '0099-01-01 00:00:00', '0099-01-01 00:00:00', '', 0, 0, 0, NOW(), 'ADMINM', NOW(), 'ADMINM', 'COL', '', '', '',
	'0099-01-01 00:00:00', '0099-01-01 00:00:00', '0099-01-01 00:00:00', '', '', '', '', 0, 0, '4', 0, 'PES', cp.fecha_documento, cp.fecha_documento, '0099-01-01', 'S', 0, 'N', '4'
from fin.cxp_doc cp
	inner join fin.cxp_items_doc cip ON (cip.documento=cp.documento and cip.tipo_documento=cp.tipo_documento and cip.proveedor=cp.proveedor and cip.reg_status='')
where cp.documento like 'AR%' and cp.vlr_saldo!=0 and cp.reg_status='' and fecha_documento< SUBSTRING(NOW()::DATE,1,8)||'01' and cp.tipo_documento='FAP'
group by cp.proveedor,cp.documento,cp.descripcion,cp.handle_code,cp.vlr_neto, cp.fecha_documento, cp.fecha_documento);


---------------------------NOTAS DE CREDITO DETALLES--------------------------------------



INSERT	INTO fin.cxp_items_doc
--(select * from fin.cxp_items_doc where tipo_documento='NC' limit 1 ) union all
(select	'', 'FINV', cp.proveedor, 'NC', cp.documento, '001', 
	list(cip.descripcion), cp.vlr_neto, cp.vlr_neto,'23050709',
	'', '', NOW(), 'ADMINM', NOW(), 'ADMINM', 'COL', '','','',''

from fin.cxp_doc cp
	inner join fin.cxp_items_doc cip ON (cip.documento=cp.documento and cip.tipo_documento=cp.tipo_documento and cip.proveedor=cp.proveedor and cip.reg_status='')
where cp.documento like 'AR%' and cp.vlr_saldo!=0 and cp.reg_status='' and cp.fecha_documento< SUBSTRING(NOW()::DATE,1,8)||'01' and cp.tipo_documento='FAP'
group by cp.proveedor,cp.documento,cp.descripcion,cp.handle_code,cp.vlr_neto, cp.fecha_documento, cp.fecha_documento);



------------------cxp del mes------------------------------------

---------------------------CABECERA-------------------------------


insert into fin.cxp_doc
--(select * from fin.cxp_doc where tipo_documento='FAP' limit 1 ) union all
(select '', dstrct, proveedor, 'FAP', 'AR'||substring(replace(fecha_documento,'-',''),1,6) , 'FACTURA GLOBAL PARA ARs DEL PERIODO '|| substring(replace(fecha_documento,'-',''),1,6) as periodo, 
		agencia, 'PN', '', '', '', 
		'0099-01-01 00:00:00', aprobador, usuario_aprobacion, banco, sucursal, 
		moneda, sum(vlr_neto), 0, sum(vlr_neto), sum(vlr_neto), 0, 
		sum(vlr_neto), tasa, '', '0099-01-01 00:00:00', 
		'', '0099-01-01 00:00:00', '0099-01-01 00:00:00', 
		'', 0, 0, 0, 
		'0099-01-01 00:00:00', '', NOW(), 'ADMINM', base, 
		'', '', '', '0099-01-01 00:00:00', '0099-01-01 00:00:00', 
		'0099-01-01 00:00:00', '', '', '', 
		'', 0, 0, '4', 
		0, moneda_banco, (substring(fecha_documento,1,8)||'28')::date, (substring(fecha_documento,1,8)||'28')::DATE + interval '1 month', 
		'0099-01-01 00:00:00', flujo, transaccion_anulacion, ret_pago, clase_documento_rel
from fin.cxp_doc cp
where documento like 'AR%' and cp.vlr_saldo!=0 and reg_status='' and cp.fecha_documento< SUBSTRING(NOW()::DATE,1,8)||'01' and cp.tipo_documento='FAP'
group by substring(replace(fecha_documento,'-',''),1,6), dstrct, proveedor,   
		agencia,  aprobador, usuario_aprobacion, banco, sucursal, 
		moneda, tasa, base, moneda_banco,  flujo, transaccion_anulacion, ret_pago, clase_documento_rel,substring(fecha_documento,1,8)
order by substring(replace(fecha_documento,'-',''),1,6));




----------------------DETALLES CXP-----------------------------------------------------------------
delete from tem.ultimo_it;

INSERT	INTO fin.cxp_items_doc
--(select * from fin.cxp_items_doc where tipo_documento='FAP' limit 1 ) union all
select * from
(select	''::text, 'FINV'::text, cp.proveedor, 'FAP'::text, ('AR'||substring(replace(fecha_documento,'-',''),1,6))::text as documento, (tem.getultimoitem('AR'||substring(replace(fecha_documento,'-',''),1,6))||'')::text as item, 
	list(cip.descripcion)::text, cp.vlr_neto, cp.vlr_neto,'23050709'::text,
	''::text, ''::text, NOW(), 'ADMINM'::text, NOW(), 'ADMINM'::text, 'COL'::text, ''::text,''::text,''::text,''::text

from fin.cxp_doc cp
	inner join fin.cxp_items_doc cip ON (cip.documento=cp.documento and cip.tipo_documento=cp.tipo_documento and cip.proveedor=cp.proveedor and cip.reg_status='')
where cp.documento like 'AR%' and cp.vlr_saldo!=0 and cp.reg_status='' and cp.fecha_documento< SUBSTRING(NOW()::DATE,1,8)||'01' and cp.tipo_documento='FAP'
group by cp.proveedor,cp.documento,cp.descripcion,cp.handle_code,cp.vlr_neto, cp.fecha_documento, cp.fecha_documento) x
order by documento,item::integer;





---------------------------BAJAR SALDOS A CXPS------------------------------------------------
update fin.cxp_doc cp set vlr_total_abonos= vlr_neto, vlr_saldo= 0, vlr_total_abonos_me= vlr_neto, vlr_saldo_me=0
--select * from fin.cxp_doc cp
where documento like 'AR%' and cp.vlr_saldo!=0 and reg_status='' and cp.tipo_documento='FAP' and cp.fecha_documento< SUBSTRING(NOW()::DATE,1,8)||'01';

return 'OK';
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION kill_cxp_ecaii()
  OWNER TO postgres;
COMMENT ON FUNCTION kill_cxp_ecaii() IS 'Mata las cxp AR de un determinado periodo con NCs y crea una cxp detallada por el valor total de las NCs';

