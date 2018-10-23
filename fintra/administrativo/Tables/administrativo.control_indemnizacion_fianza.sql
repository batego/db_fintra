-- Table: administrativo.control_indemnizacion_fianza

-- DROP TABLE administrativo.control_indemnizacion_fianza;

CREATE TABLE administrativo.control_indemnizacion_fianza
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  periodo_foto character varying(6) NOT NULL DEFAULT ''::character varying,
  nit_empresa_fianza character varying(15) NOT NULL DEFAULT ''::character varying,
  codcli character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_cliente character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_cliente character varying(150) NOT NULL DEFAULT ''::character varying,
  negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  num_pagare character varying(20) NOT NULL DEFAULT ''::character varying,
  nro_aval character varying(20) NOT NULL DEFAULT ''::character varying,
  documento character varying(20) NOT NULL DEFAULT ''::character varying,
  cuota character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_vencimiento timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_indemnizacion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  altura_mora character varying(30) NOT NULL DEFAULT ''::character varying,
  dias_vencidos integer NOT NULL DEFAULT 0,
  valor_factura numeric(11,2) NOT NULL DEFAULT 0.00,
  valor_saldo_capital numeric(11,2) NOT NULL DEFAULT 0.00,
  valor_saldo_seguro numeric(11,2) NOT NULL DEFAULT 0.00,
  valor_saldo_mi numeric(11,2) NOT NULL DEFAULT 0.00,
  valor_saldo_ca numeric(11,2) NOT NULL DEFAULT 0.00,
  ixm numeric(11,2) NOT NULL DEFAULT 0.00,
  gac numeric(11,2) NOT NULL DEFAULT 0.00,
  valor_indemnizado numeric(11,2) NOT NULL DEFAULT 0.00,
  id_convenio integer NOT NULL DEFAULT 0,
  estado_factura character varying(20) NOT NULL DEFAULT ''::character varying,
  num_ingreso character varying(11) NOT NULL DEFAULT ''::character varying,
  num_cxc_fianza character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_desistimiento timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  valor_desistido numeric(11,2) NOT NULL DEFAULT 0.00,
  ultimo_comprobante_desistimiento character varying(30) NOT NULL DEFAULT ''::character varying,
  numero_desistimientos integer NOT NULL DEFAULT 0,
  linea_negocio character varying(30) NOT NULL DEFAULT ''::character varying,
  cartera_en character varying(30) NOT NULL DEFAULT ''::character varying,
  estado_proceso character varying(2) NOT NULL DEFAULT ''::character varying,
  pagare_acelerado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  valor_saldo_cm numeric(11,2) NOT NULL DEFAULT 0.00
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.control_indemnizacion_fianza
  OWNER TO postgres;

