-- Table: opav.sl_reporte_consolidado_costos_proyectos

-- DROP TABLE opav.sl_reporte_consolidado_costos_proyectos;

CREATE TABLE opav.sl_reporte_consolidado_costos_proyectos
(
  empresa text,
  tipo_referencia text,
  multiservicio text,
  id_solicitud text,
  nombre_proyecto text,
  proveedor text,
  nombre_proveedor text,
  fecha_documento timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tipo_documento text,
  documento text,
  descripcion text,
  valor_antes_iva numeric,
  valor_iva numeric,
  total_factura_con_iva numeric,
  valor_pagado numeric,
  vlr_total_abonos numeric,
  fecha_pago timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  cod_orden text,
  vlr_orden_compra numeric,
  codigo_cuenta text,
  nombre_cuenta text,
  nombre_cliente text,
  tipo_trabajo text,
  tipo_negocio text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_reporte_consolidado_costos_proyectos
  OWNER TO postgres;
