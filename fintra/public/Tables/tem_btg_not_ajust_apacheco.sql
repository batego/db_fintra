-- Table: tem_btg_not_ajust_apacheco

-- DROP TABLE tem_btg_not_ajust_apacheco;

CREATE TABLE tem_btg_not_ajust_apacheco
(
  reg_status character varying(1),
  dstrct character varying(15),
  tipo_documento character varying(5),
  num_ingreso character varying(11),
  codcli character varying(10),
  nitcli character varying(15),
  concepto character varying(30),
  tipo_ingreso character varying(2),
  fecha_consignacion date,
  fecha_ingreso date,
  branch_code character varying(15),
  bank_account_no character varying(30),
  codmoneda character varying(3),
  agencia_ingreso character varying(6),
  descripcion_ingreso text,
  periodo character varying(6),
  vlr_ingreso moneda,
  vlr_ingreso_me moneda,
  vlr_tasa numeric(15,6),
  fecha_tasa date,
  cant_item numeric(4,0),
  transaccion integer,
  transaccion_anulacion integer,
  fecha_impresion timestamp without time zone,
  fecha_contabilizacion timestamp without time zone,
  fecha_anulacion_contabilizacion timestamp without time zone,
  fecha_anulacion timestamp without time zone,
  creation_user character varying(15),
  creation_date timestamp without time zone,
  user_update character varying(15),
  last_update timestamp without time zone,
  base character varying(3),
  nro_consignacion character varying(25),
  periodo_anulacion character varying(6),
  cuenta character varying(25),
  auxiliar character varying(25),
  abc character varying(30),
  tasa_dol_bol numeric(15,6),
  saldo_ingreso moneda,
  cmc character varying(5),
  corficolombiana character varying(1),
  fec_envio_fiducia timestamp without time zone,
  tipo_referencia_1 character varying(5),
  referencia_1 character varying(30),
  tipo_referencia_2 character varying(5),
  referencia_2 character varying(30),
  tipo_referencia_3 character varying(5),
  referencia_3 character varying(30),
  nc_ecce character varying(30),
  nro_extracto integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tem_btg_not_ajust_apacheco
  OWNER TO postgres;

