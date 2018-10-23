-- Function: sp_migrarcarterageotech(character varying)

-- DROP FUNCTION sp_migrarcarterageotech(character varying);

CREATE OR REPLACE FUNCTION sp_migrarcarterageotech(_periodo character varying)
  RETURNS text AS
$BODY$

DECLARE

	RsFotoxPeriodo record;

	Respta text := 'NEGATIVO';

BEGIN

	--1. CREAR LOS CLIENTES
	--delete from cliente where nit in (select tercero from con.foto_cartera_apoteosys where transferido = 'N' group by tercero) and substring(codcli,1,2) = 'GL'
	--select * from cliente where nit in (select tercero from con.foto_cartera_apoteosys where transferido = 'N' group by tercero) and substring(codcli,1,2) = 'GL'
	INSERT INTO cliente(
		estado, codcli, nomcli, creation_date,
		last_update, nit, dstrct, moneda, plazo, hc,
		direccion, telefono, nomcontacto, telcontacto, email_contacto, dir_factura, direccion_contacto,
		rif, ciudad, ciudad_factura, pais, pais_envio, creation_user, user_update
	)
	select
		estado, 'G'||substring(codcli,2,20) as codcli, nombre_tercero, now(),
		now() as last_update, tercero, 'FINV' as dstrct, moneda, 0 as plazo, '' as hc,
		direccion_contacto::varchar(100) as direccion_contacto,
		telcontacto::varchar(100) as telcontacto,
		nomcontacto::varchar(100) as nomcontacto,
		telcontacto::varchar(100) as telcontacto,
		coalesce(email_contacto::varchar(100),'') as email_contacto,
		dir_factura::varchar(100) as dir_factura,
		direccion_contacto::varchar(100) as direccion_contacto,
		'' as rif, ciudad, 'BQ' as ciudad_factura, 'CO' as pais, 'CO' as pais_envio, 'HCUELLO' as creation_user, '' as user_update --select *
	from con.foto_cartera_apoteosys
	where codcli is not null
	--and tercero in (select tercero from con.foto_cartera_apoteosys where transferido = 'N' group by tercero)
	and tercero not in (select nit from cliente where nit in (select tercero from con.foto_cartera_apoteosys where transferido = 'N' group by tercero)) --and substring(codcli,1,2) = 'GL'
	and tipo_documento = 'FACN'
	and transferido = 'N'
	and periodo_creacion = _Periodo
	group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23;


	--2. CARGAR LA FOTO DE GEOTECH PARA FINTRA
	     --truncate con.foto_cartera_geotech;
	     --select * from con.foto_cartera_geotech;
	INSERT INTO con.foto_cartera_geotech(
		    periodo_lote, id_convenio, creation_date, reg_status, dstrct, --
		    tipo_documento, documento, nit, codcli, concepto, fecha_negocio, --
		    fecha_factura, fecha_vencimiento, fecha_ultimo_pago, descripcion, --
		    valor_factura, valor_abono, valor_saldo, valor_facturame, valor_abonome, valor_saldome, --
		    forma_pago, transaccion, fecha_contabilizacion, creation_date_cxc, creation_user,
		    cmc, periodo, negasoc, num_doc_fen, agente, fecha_asignacion, usuario_asignacion,
		    agencia_cobro, agente_campo, estado_cartera, tramo_periodo_lote, tramo_anterior)
	SELECT
		    periodo_creacion, 56, fecha_creacion_pg, '', 'GEOT',
		    tipo_documento, factura_geotech, tercero, get_codnit(tercero), 'NoConc', fecha_foto_pg,
		    fecha_facturacion_pg, fecha_vencimiento_pg, '0099-01-01', coalesce(observacion,''),
		    valor_factura, abono, saldo, valor_factura, abono, saldo,
		    '', 0, '0099-01-01', '0099-01-01', 'HCUELLO',
		    'CMC', replace(substring(fecha_facturacion_pg,1,7),'-',''), tercero, '1', '', '0099-01-01', '',
		    '', '', '', '', ''
	FROM con.foto_cartera_apoteosys
	WHERE tipo_documento = 'FACN'
	AND transferido = 'N'
	AND periodo_creacion = _Periodo;


	--3. CREAR LAS FACTURAS ---> Debería manejarlo en un ciclo, para poder verificar el saldo de cada una de las facturas y hacer el update. O en dos pasos: a) insert y b) update from select
	     --delete from con.factura where descripcion = 'CXC DE GEOTECH';
	     --select * from con.factura where descripcion = 'CXC DE GEOTECH';
	INSERT INTO con.factura(
		    reg_status, dstrct, tipo_documento, documento, nit, codcli, concepto,
		    fecha_factura, fecha_vencimiento, fecha_ultimo_pago, fecha_impresion,
		    descripcion, observacion, valor_factura, valor_abono, valor_saldo,
		    valor_facturame, valor_abonome, valor_saldome, valor_tasa, moneda,
		    cantidad_items, forma_pago, agencia_facturacion, agencia_cobro,
		    zona, clasificacion1, clasificacion2, clasificacion3, transaccion,
		    transaccion_anulacion, fecha_contabilizacion, fecha_anulacion,
		    fecha_contabilizacion_anulacion, base, last_update, user_update,
		    creation_date, creation_user, fecha_probable_pago, flujo, rif,
		    cmc, usuario_anulo, formato, agencia_impresion, periodo, valor_tasa_remesa,
		    negasoc, num_doc_fen, obs, pagado_fenalco, corficolombiana, tipo_ref1,
		    ref1, tipo_ref2, ref2, dstrct_ultimo_ingreso, tipo_documento_ultimo_ingreso,
		    num_ingreso_ultimo_ingreso, item_ultimo_ingreso, fec_envio_fiducia,
		    nit_enviado_fiducia, tipo_referencia_1, referencia_1, tipo_referencia_2,
		    referencia_2, tipo_referencia_3, referencia_3, nc_traslado, fecha_nc_traslado,
		    tipo_nc, numero_nc, factura_traslado, factoring_formula_aplicada,
		    nit_endoso, devuelta, fc_eca, fc_bonificacion, indicador_bonificacion,
		    fi_bonificacion, endoso_fenalco)
	SELECT
		'', 'FINV','FAC', factura_geotech, tercero,  ''/*get_codnit(tercero)*/, '',
		now()::date, fecha_vencimiento_pg, '0099-01-01 00:00:00'::timestamp without time zone, now()::date,
		'CXC DE GEOTECH', '', valor_factura, abono, saldo,
		valor_factura, abono, saldo, 1.000000, 'PES',
		1,'CREDITO','OP','OP',
		'','','','', 0,
		0, '0099-01-01 00:00:00'::timestamp without time zone, '0099-01-01 00:00:00'::timestamp without time zone,
		'0099-01-01 00:00:00'::timestamp without time zone, 'COL', '0099-01-01 00:00:00'::timestamp without time zone, '',
		NOW(), coalesce(usuariocrea,'ADMINSIS'),'0099-01-01 00:00:00'::timestamp without time zone, 'S', '',
		'', '', '', 'OP', '', 0,
		tercero, '1', '0', '', '', '',
		'', '', '', '', '',
		'', 0, '0099-01-01 00:00:00'::timestamp without time zone,
		'', '', '', '',
		'', '','', 'N', '0099-01-01 00:00:00'::timestamp without time zone,
		'', '', '', 'N',
		'', '', '','', '',
		'', 'N' --select *
	FROM con.foto_cartera_apoteosys
	WHERE tipo_documento = 'FACN'
	AND transferido = 'N'
	AND periodo_creacion = _Periodo;


	--4. ACTUALIZAR FROM SELECT --> PARA SABER SI ESTÁ PROCESADO
	     --UPDATE con.foto_cartera_apoteosys SET transferido = 'N'
	UPDATE con.foto_cartera_apoteosys
	SET transferido = 'S'
	WHERE tipo_documento = 'FACN'
	AND transferido = 'N'
	AND periodo_creacion = _Periodo;

	Respta := 'POSITIVO';


	RETURN Respta;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_migrarcarterageotech(character varying)
  OWNER TO postgres;
