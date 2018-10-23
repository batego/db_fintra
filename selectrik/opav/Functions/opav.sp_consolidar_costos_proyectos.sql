-- Function: opav.sp_consolidar_costos_proyectos()

-- DROP FUNCTION opav.sp_consolidar_costos_proyectos();

CREATE OR REPLACE FUNCTION opav.sp_consolidar_costos_proyectos()
  RETURNS character varying AS
$BODY$
DECLARE

retorno varchar ;
recordReporte record;


BEGIN

 TRUNCATE TABLE opav.sl_reporte_consolidado_costos_proyectos ;
 FOR recordReporte IN (SELECT  num_os,
			       id_solicitud,
			       nombre_proyecto,
			       get_nombrecliente(id_cliente) as nombre_cliente,
			       sl.nombre as tipo_negocio ,
			       stt.nombre  as tipo_trabajo
			FROM opav.ofertas o
			LEFT JOIN opav.sl_tipo_negocio sl on (sl.id=o.id_tipo_negocio)
			LEFT JOIN opav.sl_tipo_trabajo stt on (stt.id=o.id_tipo_trabajo)
			WHERE num_os !=''
			)
 LOOP
	raise notice 'recordReporte.num_os % recordReporte.id_solicitud % ',recordReporte.num_os,recordReporte.id_solicitud;
	--se hace  insert a tu tabla
-- 	Inymec
        INSERT INTO opav.sl_reporte_consolidado_costos_proyectos (empresa, tipo_referencia, multiservicio,id_solicitud, proveedor, nombre_proveedor, fecha_documento, tipo_documento, documento, descripcion, valor_antes_iva,
	valor_iva, total_factura_con_iva, valor_pagado, vlr_total_abonos, fecha_pago, cod_orden, vlr_orden_compra, codigo_cuenta,nombre_proyecto,nombre_cuenta,nombre_cliente,tipo_trabajo,tipo_negocio)
	SELECT  empresa,tipo_referencia_1 as tipo_referencia,
	        recordReporte.num_os as mltiservicio,
		recordReporte.id_solicitud,
	        proveedor,
		nombre_proveedor,
		fecha_documento::date,
		tipo_documento,
		documento,
		descripcion,
		valor_antes_iva,
		0.00::numeric as valor_iva,
		0.00::numeric as valor_total_con_iva,
		valor_pagado,
		vlr_total_abonos,
		fecha_pago,
		''::varchar as cod_orden,
		0.00::numeric as vlr_orden_compra,
		codigo_cuenta,
		recordReporte.nombre_proyecto,
		nombre_cuenta,
		recordReporte.nombre_cliente,
		recordReporte.tipo_trabajo,
		recordReporte.tipo_negocio
	FROM opav.eg_costos_inymec(recordReporte.num_os);

	--Provintegral
	INSERT INTO opav.sl_reporte_consolidado_costos_proyectos (empresa, tipo_referencia, multiservicio,id_solicitud, proveedor, nombre_proveedor, fecha_documento, tipo_documento, documento, descripcion, valor_antes_iva,
	valor_iva, total_factura_con_iva, valor_pagado, vlr_total_abonos, fecha_pago, cod_orden, vlr_orden_compra, codigo_cuenta,nombre_proyecto,nombre_cuenta,nombre_cliente,tipo_trabajo,tipo_negocio)
	SELECT
		empresa,
		tipo_referencia_1 as tipo_referencia,
		recordReporte.num_os as multiservicio,
		recordReporte.id_solicitud,
		proveedor,
		nombre_proveedor,
		fecha_documento::date,
		tipo_documento,
		documento,
		descripcion,
		valor_antes_iva,
		valor_iva,
		valor_total_con_iva,
		valor_pagado,
		vlr_total_abonos,
		fecha_pago,
		cod_orden,
		vlr_orden_compra,
		codigo_cuenta,
		recordReporte.nombre_proyecto,
		nombre_cuenta,
		recordReporte.nombre_cliente,
		recordReporte.tipo_trabajo,
		recordReporte.tipo_negocio
	FROM opav.eg_costos_provintegral(recordReporte.id_solicitud);

-- 	Selectrik
        INSERT INTO opav.sl_reporte_consolidado_costos_proyectos (empresa, tipo_referencia, multiservicio,id_solicitud, proveedor, nombre_proveedor, fecha_documento, tipo_documento, documento, descripcion, valor_antes_iva,
	valor_iva, total_factura_con_iva, valor_pagado, vlr_total_abonos, fecha_pago, cod_orden, vlr_orden_compra, codigo_cuenta,nombre_proyecto,nombre_cuenta,nombre_cliente,tipo_trabajo,tipo_negocio)
	SELECT  empresa,
		tipo_referencia_1 as tipo_referencia,
		recordReporte.num_os as multiservicio,
		recordReporte.id_solicitud,
		proveedor,
		nombre_proveedor,
		fecha_documento::date,
		tipo_documento,
		documento,
		descripcion,
		valor_antes_iva,
		valor_iva,
		valor_total_con_iva,
		valor_pagado,
		vlr_total_abonos,
		fecha_pago,
		cod_orden,
		vlr_orden_compra,
		codigo_cuenta,
		recordReporte.nombre_proyecto,
		nombre_cuenta,
		recordReporte.nombre_cliente,
		recordReporte.tipo_trabajo,
		recordReporte.tipo_negocio
	FROM opav.sl_costos_selectrik(recordReporte.num_os);


 END LOOP;

 return 'ok';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_consolidar_costos_proyectos()
  OWNER TO postgres;
