-- Table: fin.cxp_doc_tsp

-- DROP TABLE fin.cxp_doc_tsp;

CREATE TABLE fin.cxp_doc_tsp
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
  clase_documento_rel character varying(1) NOT NULL DEFAULT ''::character varying, -- Clase de la factura relacionada
  periodo_anulacion character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo de anulacion
  fecha_envio_ws timestamp without time zone, -- fecha en la que se envio por ultima vez el registro del servidor al cliente  a traves del web service
  creation_date_real timestamp without time zone DEFAULT now(), -- fecha de creacion real
  pk_novedad integer NOT NULL DEFAULT (-1) -- llave primaria de ultima novedad
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.cxp_doc_tsp
  OWNER TO postgres;
COMMENT ON TABLE fin.cxp_doc_tsp
  IS 'Cabezote de la factura de cuentas por pagar';
COMMENT ON COLUMN fin.cxp_doc_tsp.handle_code IS 'codigo hcmims';
COMMENT ON COLUMN fin.cxp_doc_tsp.vlr_neto_me IS 'valor neto moneda extranjera';
COMMENT ON COLUMN fin.cxp_doc_tsp.vlr_total_abonos_me IS 'valor total abonos moneda extranjera';
COMMENT ON COLUMN fin.cxp_doc_tsp.vlr_saldo_me IS 'valor saldo moneda extranjera';
COMMENT ON COLUMN fin.cxp_doc_tsp.num_obs_autorizador IS 'numero de observacion del autorizador';
COMMENT ON COLUMN fin.cxp_doc_tsp.num_obs_pagador IS 'numero de observacion del pagador';
COMMENT ON COLUMN fin.cxp_doc_tsp.num_obs_registra IS 'numero de observacion del registrador';
COMMENT ON COLUMN fin.cxp_doc_tsp.corrida IS 'numero de la corrida a la que pertenece la cuenta';
COMMENT ON COLUMN fin.cxp_doc_tsp.cheque IS 'numero del  cheque';
COMMENT ON COLUMN fin.cxp_doc_tsp.periodo IS 'Periodo de contabilizacion';
COMMENT ON COLUMN fin.cxp_doc_tsp.fecha_procesado IS 'Fecha de proceso para contabilizacion de ajuste por cambio y ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc_tsp.fecha_contabilizacion_ajc IS 'Fecha de contabilizacion de ajuste por cambio';
COMMENT ON COLUMN fin.cxp_doc_tsp.fecha_contabilizacion_ajv IS 'Fecha de contabilizacion de ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc_tsp.periodo_ajc IS 'Periodo de contabilizacion de ajuste por cambio';
COMMENT ON COLUMN fin.cxp_doc_tsp.periodo_ajv IS 'Periodo de contabilizacion de ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc_tsp.usuario_contabilizo_ajc IS 'Usuario de contabilizacion de ajuste por cambio';
COMMENT ON COLUMN fin.cxp_doc_tsp.usuario_contabilizo_ajv IS 'Usuario de contabilizacion de ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc_tsp.transaccion_ajc IS 'Transaccion de contabilizacion de ajuste por cambio';
COMMENT ON COLUMN fin.cxp_doc_tsp.transaccion_ajv IS 'Transaccion de contabilizacion de ajuste por valor';
COMMENT ON COLUMN fin.cxp_doc_tsp.clase_documento IS 'Clase de la factura';
COMMENT ON COLUMN fin.cxp_doc_tsp.transaccion IS 'Transaccion de la contabilizacion';
COMMENT ON COLUMN fin.cxp_doc_tsp.moneda_banco IS 'Moneda del banco del popietario';
COMMENT ON COLUMN fin.cxp_doc_tsp.flujo IS 'Flitro de Visualizacion para Flujo de Caja';
COMMENT ON COLUMN fin.cxp_doc_tsp.transaccion_anulacion IS 'Transaccion con la cual se anula la factura';
COMMENT ON COLUMN fin.cxp_doc_tsp.ret_pago IS 'Indica si aplica retencion de pago.';
COMMENT ON COLUMN fin.cxp_doc_tsp.clase_documento_rel IS 'Clase de la factura relacionada';
COMMENT ON COLUMN fin.cxp_doc_tsp.periodo_anulacion IS 'Periodo de anulacion';
COMMENT ON COLUMN fin.cxp_doc_tsp.fecha_envio_ws IS 'fecha en la que se envio por ultima vez el registro del servidor al cliente  a traves del web service';
COMMENT ON COLUMN fin.cxp_doc_tsp.creation_date_real IS 'fecha de creacion real';
COMMENT ON COLUMN fin.cxp_doc_tsp.pk_novedad IS 'llave primaria de ultima novedad';


