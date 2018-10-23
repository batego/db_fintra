-- Table: con.ingreso_prueba

-- DROP TABLE con.ingreso_prueba;

CREATE TABLE con.ingreso_prueba
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying,
  num_ingreso character varying(11) NOT NULL DEFAULT ''::character varying,
  codcli character varying(10) NOT NULL DEFAULT ''::character varying,
  nitcli character varying(15) DEFAULT ''::character varying,
  concepto character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_ingreso character varying(2) NOT NULL DEFAULT ''::character varying,
  fecha_consignacion date NOT NULL DEFAULT '0099-01-01'::date,
  fecha_ingreso date NOT NULL DEFAULT '0099-01-01'::date,
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying,
  bank_account_no character varying(30) NOT NULL DEFAULT ''::character varying,
  codmoneda character varying(3) NOT NULL DEFAULT ''::character varying,
  agencia_ingreso character varying(6) NOT NULL DEFAULT ''::character varying,
  descripcion_ingreso text NOT NULL DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  vlr_ingreso moneda,
  vlr_ingreso_me moneda,
  vlr_tasa numeric(15,6) NOT NULL DEFAULT 0.0,
  fecha_tasa date NOT NULL DEFAULT '0099-01-01'::date,
  cant_item numeric(4,0) DEFAULT 0,
  transaccion integer NOT NULL DEFAULT 0,
  transaccion_anulacion integer NOT NULL DEFAULT 0,
  fecha_impresion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_anulacion_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  nro_consignacion character varying(25) NOT NULL DEFAULT ''::character varying,
  periodo_anulacion character varying(6) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying,
  auxiliar character varying(25) NOT NULL DEFAULT ''::character varying,
  abc character varying(30) NOT NULL DEFAULT ''::character varying,
  tasa_dol_bol numeric(15,6) NOT NULL DEFAULT 0,
  saldo_ingreso moneda NOT NULL DEFAULT 0,
  cmc character varying(5) DEFAULT '00'::character varying,
  corficolombiana character varying(1) DEFAULT ''::character varying,
  fec_envio_fiducia timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(30) NOT NULL DEFAULT ''::character varying,
  nc_ecce character varying(30) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.ingreso_prueba
  OWNER TO postgres;
GRANT ALL ON TABLE con.ingreso_prueba TO postgres;
GRANT SELECT ON TABLE con.ingreso_prueba TO msoto;

