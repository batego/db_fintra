-- Table: con.ingreso_detalle_por_res3

-- DROP TABLE con.ingreso_detalle_por_res3;

CREATE TABLE con.ingreso_detalle_por_res3
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying,
  num_ingreso character varying(11) NOT NULL DEFAULT ''::character varying,
  item bigint NOT NULL DEFAULT 0,
  nitcli character varying(15) DEFAULT ''::character varying,
  valor_ingreso moneda NOT NULL DEFAULT 0,
  valor_ingreso_me moneda NOT NULL DEFAULT 0,
  factura character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_factura date NOT NULL DEFAULT '0099-01-01'::date,
  codigo_retefuente character varying(6) NOT NULL DEFAULT ''::character varying,
  valor_retefuente moneda NOT NULL DEFAULT 0,
  valor_retefuente_me moneda NOT NULL DEFAULT 0,
  tipo_doc character varying(5) NOT NULL DEFAULT ''::character varying,
  documento text NOT NULL DEFAULT ''::character varying,
  codigo_reteica character varying(6) NOT NULL DEFAULT ''::character varying,
  valor_reteica moneda NOT NULL DEFAULT 0,
  valor_reteica_me moneda NOT NULL DEFAULT 0,
  valor_diferencia_tasa moneda NOT NULL DEFAULT 0,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying,
  auxiliar character varying(25) NOT NULL DEFAULT ''::character varying,
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_anulacion_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  fecha_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  periodo_anulacion character varying(6) NOT NULL DEFAULT ''::character varying,
  transaccion integer NOT NULL DEFAULT 0,
  transaccion_anulacion integer NOT NULL DEFAULT 0,
  descripcion text NOT NULL DEFAULT ''::text,
  valor_tasa numeric(15,10) NOT NULL DEFAULT 0,
  saldo_factura moneda NOT NULL DEFAULT 0,
  procesado character varying NOT NULL DEFAULT 'NO'::character varying,
  id serial NOT NULL,
  ref1 text,
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(30) NOT NULL DEFAULT ''::character varying,
  creation_date_real timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.ingreso_detalle_por_res3
  OWNER TO postgres;
GRANT ALL ON TABLE con.ingreso_detalle_por_res3 TO postgres;
GRANT SELECT ON TABLE con.ingreso_detalle_por_res3 TO msoto;

