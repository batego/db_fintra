-- Type: opav.rs_reporte_costos_fintra

-- DROP TYPE opav.rs_reporte_costos_fintra;

CREATE TYPE opav.rs_reporte_costos_fintra AS
   (empresa text,
    tipo_referencia_1 text,
    referencia_1 text,
    proveedor text,
    nombre_proveedor text,
    fecha_documento text,
    tipo_documento text,
    documento text,
    descripcion text,
    valor_antes_iva numeric,
    valor_iva numeric,
    valor_total_con_iva numeric,
    valor_pagado numeric,
    vlr_total_abonos numeric,
    fecha_pago date,
    cod_orden character varying,
    vlr_orden_compra numeric,
    codigo_cuenta character varying,
    nombre_cuenta character varying);
ALTER TYPE opav.rs_reporte_costos_fintra
  OWNER TO postgres;
