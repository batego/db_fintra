-- Type: opav.rs_reporte_costos_provintegral

-- DROP TYPE opav.rs_reporte_costos_provintegral;

CREATE TYPE opav.rs_reporte_costos_provintegral AS
   (empresa text,
    tipo_referencia_1 character varying,
    referencia_1 character varying,
    proveedor character varying,
    nombre_proveedor character varying,
    fecha_documento character varying,
    tipo_documento character varying,
    documento character varying,
    descripcion character varying,
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
ALTER TYPE opav.rs_reporte_costos_provintegral
  OWNER TO postgres;
