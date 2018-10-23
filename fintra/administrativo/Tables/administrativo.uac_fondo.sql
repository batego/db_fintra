-- Table: administrativo.uac_fondo

-- DROP TABLE administrativo.uac_fondo;

CREATE TABLE administrativo.uac_fondo
(
  solicitud character varying(255),
  cedula character varying(255),
  nombres_apellidos character varying(255),
  direccion_deudor character varying(255),
  telefono_deudor character varying(255),
  codigo_est character varying(255),
  fecha_aprobacion character varying(255),
  total_desembolsado character varying(255),
  plazo character varying(255),
  tasa character varying(255),
  cuota character varying(255),
  saldo_capital character varying(255),
  vencimiento_1ra_cuota character varying(255),
  cuotas_vencidas character varying(255),
  total_factura character varying(255),
  total_pagos character varying(255),
  saldo_factura character varying(255),
  cuotas_pagas character varying(255),
  cuotas_pendientes character varying(255),
  vp character varying(255),
  cedula_codeudor character varying(255),
  nombre_codeudor character varying(255),
  direccion_codeudor character varying(255),
  telefono_codeudor character varying(255)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.uac_fondo
  OWNER TO postgres;

