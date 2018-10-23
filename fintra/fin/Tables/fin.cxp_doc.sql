-- Table: fin.cxp_doc

-- DROP TABLE fin.cxp_doc;

CREATE TABLE fin.cxp_doc
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(15) NOT NULL DEFAULT ''::character varying,
  documento character varying(30) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::text,
  agencia character varying(15) NOT NULL DEFAULT ''::character varying,
  handle_code character varying(15) NOT NULL DEFAULT ''::character varying, -- codigo hcmims
  id_mims character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_documento_rel character varying(15) NOT NULL DEFAULT ''::character varying,
  documento_relacionado text NOT NULL DEFAULT ''::text,
  fecha_aprobacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  aprobador character varying(15) NOT NULL DEFAULT ''::character varying,
  usuario_aprobacion character varying(15) NOT NULL DEFAULT ''::character varying,
  banco character varying(30) NOT NULL DEFAULT ''::character varying,
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying,
  moneda character varying(15) NOT NULL DEFAULT ''::character varying,
  vlr_neto moneda,
  vlr_total_abonos moneda,
  vlr_saldo moneda,
  vlr_neto_me moneda, -- valor neto moneda extranjera
  vlr_total_abonos_me moneda, -- valor total abonos moneda extranjera
  vlr_saldo_me moneda, -- valor saldo moneda extranjera
  tasa numeric(18,10) NOT NULL DEFAULT 0,
  usuario_contabilizo character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_anulo character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_contabilizacion_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  observacion text NOT NULL DEFAULT ''::text,
  num_obs_autorizador numeric(5,0) NOT NULL DEFAULT 0, -- numero de observacion del autorizador
  num_obs_pagador numeric(5,0) NOT NULL DEFAULT 0, -- numero de observacion del pagador
  num_obs_registra numeric(5,0) NOT NULL DEFAULT 0, -- numero de observacion del registrador
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  base character varying(3) DEFAULT ''::character varying,
  corrida character varying(10) NOT NULL DEFAULT ''::character varying, -- numero de la corrida a la que pertenece la cuenta
  cheque character varying(30) DEFAULT ''::character varying, -- numero del  cheque
  periodo character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo de contabilizacion
  fecha_procesado timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de proceso para contabilizacion de ajuste por cambio y ajuste por valor
  fecha_contabilizacion_ajc timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de contabilizacion de ajuste por cambio
  fecha_contabilizacion_ajv timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de contabilizacion de ajuste por valor
  periodo_ajc character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo de contabilizacion de ajuste por cambio
  periodo_ajv character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo de contabilizacion de ajuste por valor
  usuario_contabilizo_ajc character varying(15) NOT NULL DEFAULT ''::character varying, -- Usuario de contabilizacion de ajuste por cambio
  usuario_contabilizo_ajv character varying(15) NOT NULL DEFAULT ''::character varying, -- Usuario de contabilizacion de ajuste por valor
  transaccion_ajc integer NOT NULL DEFAULT 0, -- Transaccion de contabilizacion de ajuste por cambio
  transaccion_ajv integer NOT NULL DEFAULT 0, -- Transaccion de contabilizacion de ajuste por valor
  clase_documento character varying(1) NOT NULL DEFAULT ''::character varying, -- Clase de la factura
  transaccion integer NOT NULL DEFAULT 0, -- Transaccion de la contabilizacion
  moneda_banco character varying(3) NOT NULL DEFAULT ''::character varying, -- Moneda del banco del popietario
  fecha_documento date NOT NULL DEFAULT '0099-01-01'::date,
  fecha_vencimiento date NOT NULL DEFAULT '0099-01-01'::date,
  ultima_fecha_pago date NOT NULL DEFAULT '0099-01-01'::date,
  flujo character varying(1) NOT NULL DEFAULT 'S'::character varying, -- Flitro de Visualizacion para Flujo de Caja
  transaccion_anulacion integer NOT NULL DEFAULT 0, -- Transaccion con la cual se anula la factura
  ret_pago character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si aplica retencion de pago.
  clase_documento_rel character varying(3) NOT NULL DEFAULT ''::character varying, -- Clase de la factura relacionada
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(30) NOT NULL DEFAULT ''::character varying,
  indicador_traslado_fintra character varying(1) NOT NULL DEFAULT 'N'::character varying,
  factoring_formula_aplicada character varying(1) NOT NULL DEFAULT 'N'::character varying,
  factura_tipo_nomina character varying(1) DEFAULT 'N'::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.cxp_doc
  OWNER TO postgres;
COMMENT ON TABLE fin.cxp_doc
  IS 'Cabezote de la factura de cuentas por pagar';
COMMENT ON COLUMN fin.cxp_doc.handle_code IS 'codigo hcmims';
COMMENT ON COLUMN fin.cxp_doc.vlr_neto_me IS 'valor neto moneda extranjera';
COMMENT ON COLUMN fin.cxp_doc.vlr_total_abonos_me IS 'valor total abonos moneda extranjera';
COMMENT ON COLUMN fin.cxp_doc.vlr_saldo_me IS 'valor saldo moneda extranjera';
COMMENT ON COLUMN fin.cxp_doc.num_obs_autorizador IS 'numero de observacion del autorizador';
COMMENT ON COLUMN fin.cxp_doc.num_obs_pagador IS 'numero de observacion del pagador';
COMMENT ON COLUMN fin.cxp_doc.num_obs_registra IS 'numero de observacion del registrador';
COMMENT ON COLUMN fin.cxp_doc.corrida IS 'numero de la corrida a la que pertenece la cuenta';
COMMENT ON COLUMN fin.cxp_doc.cheque IS 'numero del  cheque';
COMMENT ON COLUMN fin.cxp_doc.periodo IS 'Periodo de contabilizacion';
COMMENT ON COLUMN fin.cxp_doc.fecha_procesado IS 'Fecha de proceso para contabilizacion de ajuste por cambio y ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc.fecha_contabilizacion_ajc IS 'Fecha de contabilizacion de ajuste por cambio';
COMMENT ON COLUMN fin.cxp_doc.fecha_contabilizacion_ajv IS 'Fecha de contabilizacion de ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc.periodo_ajc IS 'Periodo de contabilizacion de ajuste por cambio';
COMMENT ON COLUMN fin.cxp_doc.periodo_ajv IS 'Periodo de contabilizacion de ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc.usuario_contabilizo_ajc IS 'Usuario de contabilizacion de ajuste por cambio';
COMMENT ON COLUMN fin.cxp_doc.usuario_contabilizo_ajv IS 'Usuario de contabilizacion de ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc.transaccion_ajc IS 'Transaccion de contabilizacion de ajuste por cambio';
COMMENT ON COLUMN fin.cxp_doc.transaccion_ajv IS 'Transaccion de contabilizacion de ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc.clase_documento IS 'Clase de la factura';
COMMENT ON COLUMN fin.cxp_doc.transaccion IS 'Transaccion de la contabilizacion';
COMMENT ON COLUMN fin.cxp_doc.moneda_banco IS 'Moneda del banco del popietario';
COMMENT ON COLUMN fin.cxp_doc.flujo IS 'Flitro de Visualizacion para Flujo de Caja';
COMMENT ON COLUMN fin.cxp_doc.transaccion_anulacion IS 'Transaccion con la cual se anula la factura';
COMMENT ON COLUMN fin.cxp_doc.ret_pago IS 'Indica si aplica retencion de pago.';
COMMENT ON COLUMN fin.cxp_doc.clase_documento_rel IS 'Clase de la factura relacionada';


