-- Table: movimientos_backup

-- DROP TABLE movimientos_backup;

CREATE TABLE movimientos_backup
(
  reg_status character varying(1),
  dstrct character varying(15),
  proveedor character varying(15),
  tipo_documento character varying(15),
  documento character varying(30),
  descripcion text,
  agencia character varying(15),
  handle_code character varying(15),
  id_mims character varying(15),
  tipo_documento_rel character varying(15),
  documento_relacionado text,
  fecha_aprobacion timestamp without time zone,
  aprobador character varying(15),
  usuario_aprobacion character varying(15),
  banco character varying(30),
  sucursal character varying(30),
  moneda character varying(15),
  vlr_neto moneda,
  vlr_total_abonos moneda,
  vlr_saldo moneda,
  vlr_neto_me moneda,
  vlr_total_abonos_me moneda,
  vlr_saldo_me moneda,
  tasa numeric(18,10),
  usuario_contabilizo character varying(15),
  fecha_contabilizacion timestamp without time zone,
  usuario_anulo character varying(15),
  fecha_anulacion timestamp without time zone,
  fecha_contabilizacion_anulacion timestamp without time zone,
  observacion text,
  num_obs_autorizador numeric(5,0),
  num_obs_pagador numeric(5,0),
  num_obs_registra numeric(5,0),
  last_update timestamp without time zone,
  user_update character varying,
  creation_date timestamp without time zone,
  creation_user character varying(15),
  base character varying(3),
  corrida character varying(10),
  cheque character varying(30),
  periodo character varying(6),
  fecha_procesado timestamp without time zone,
  fecha_contabilizacion_ajc timestamp without time zone,
  fecha_contabilizacion_ajv timestamp without time zone,
  periodo_ajc character varying(6),
  periodo_ajv character varying(6),
  usuario_contabilizo_ajc character varying(15),
  usuario_contabilizo_ajv character varying(15),
  transaccion_ajc integer,
  transaccion_ajv integer,
  clase_documento character varying(1),
  transaccion integer,
  moneda_banco character varying(3),
  fecha_documento date,
  fecha_vencimiento date,
  ultima_fecha_pago date,
  flujo character varying(1),
  transaccion_anulacion integer,
  ret_pago character varying(1),
  clase_documento_rel character varying(3),
  tipo_referencia_1 character varying(5),
  referencia_1 character varying(30),
  tipo_referencia_2 character varying(5),
  referencia_2 character varying(30),
  tipo_referencia_3 character varying(5),
  referencia_3 character varying(30),
  indicador_traslado_fintra character varying(1),
  factoring_formula_aplicada character varying(1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE movimientos_backup
  OWNER TO postgres;
GRANT ALL ON TABLE movimientos_backup TO postgres;
GRANT SELECT ON TABLE movimientos_backup TO msoto;

