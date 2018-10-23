-- Table: administrativo.uac

-- DROP TABLE administrativo.uac;

CREATE TABLE administrativo.uac
(
  solicitud character varying(255),
  cedula character varying(255),
  "nombres y apellidos" character varying(255),
  codigo_est character varying(255),
  fecha_aprobacion character varying(255),
  fecha_desembolso character varying(255),
  total_desembolsado character varying(255),
  plazo character varying(255),
  tasa character varying(255),
  cuota character varying(255),
  calculo_cuota character varying(255),
  vencimiento_1ra_cuota character varying(255),
  cuotas_vencidas character varying(255),
  fecha_ultimo_pago character varying(255),
  vencimiento_mayor character varying(255),
  fecha_vencimiento character varying(255),
  cuotas_canceladas character varying(255),
  mayo character varying(255),
  junio character varying(255),
  julio character varying(255),
  agosto character varying(255),
  septiembre character varying(255),
  octubre character varying(255),
  noviembre character varying(255),
  diciembre character varying(255),
  total_factura character varying(255),
  total_pagos character varying(255),
  saldo_factura character varying(255),
  cuotas_pagas character varying(255),
  cuotas_pendientes character varying(255),
  vp character varying(255),
  codeudor character varying(255),
  referencias character varying(255),
  no_referencias character varying(255),
  cedula_codeudor character varying(255),
  nombre_codeudor character varying(255),
  direccion_codeudor character varying(255),
  barrio_codeudor character varying(255),
  telefono_codeudor character varying(255),
  celular_codeudor character varying(255),
  correo_codeudor character varying(255),
  nacimiento_codeudor character varying(255),
  "AQ" character varying(255),
  "AR" character varying(255),
  "AS" character varying(255)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.uac
  OWNER TO postgres;

