-- Table: tem_btg_not_ajust_apacheco_det_ing

-- DROP TABLE tem_btg_not_ajust_apacheco_det_ing;

CREATE TABLE tem_btg_not_ajust_apacheco_det_ing
(
  reg_status character varying(1),
  dstrct character varying(4),
  tipo_documento character varying(5),
  num_ingreso character varying(11),
  item bigint,
  nitcli character varying(15),
  valor_ingreso moneda,
  valor_ingreso_me moneda,
  factura character varying(10),
  fecha_factura date,
  codigo_retefuente character varying(6),
  valor_retefuente moneda,
  valor_retefuente_me moneda,
  tipo_doc character varying(5),
  documento text,
  codigo_reteica character varying(6),
  valor_reteica moneda,
  valor_reteica_me moneda,
  valor_diferencia_tasa moneda,
  creation_user character varying(15),
  creation_date timestamp without time zone,
  user_update character varying(15),
  last_update timestamp without time zone,
  base character varying(3),
  cuenta character varying(25),
  auxiliar character varying(25),
  fecha_contabilizacion timestamp without time zone,
  fecha_anulacion_contabilizacion timestamp without time zone,
  periodo character varying(6),
  fecha_anulacion timestamp without time zone,
  periodo_anulacion character varying(6),
  transaccion integer,
  transaccion_anulacion integer,
  descripcion text,
  valor_tasa numeric(15,10),
  saldo_factura moneda,
  procesado character varying,
  id integer,
  ref1 text,
  tipo_referencia_1 character varying(5),
  referencia_1 character varying(30),
  tipo_referencia_2 character varying(5),
  referencia_2 character varying(30),
  tipo_referencia_3 character varying(5),
  referencia_3 character varying(30),
  procesado_ica character varying(1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tem_btg_not_ajust_apacheco_det_ing
  OWNER TO postgres;

