-- Table: con.comprobante2

-- DROP TABLE con.comprobante2;

CREATE TABLE con.comprobante2
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipodoc character varying(5) NOT NULL DEFAULT ''::character varying,
  numdoc character varying(30) NOT NULL DEFAULT ''::character varying,
  grupo_transaccion integer NOT NULL,
  sucursal character varying(5) NOT NULL DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  fechadoc date NOT NULL DEFAULT '0099-01-01'::date,
  detalle text NOT NULL DEFAULT ''::character varying,
  tercero character varying(15) NOT NULL DEFAULT ''::character varying,
  total_debito moneda,
  total_credito moneda,
  total_items integer DEFAULT 0,
  moneda character varying(3) NOT NULL DEFAULT ''::character varying,
  fecha_aplicacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  aprobador character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  usuario_aplicacion character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_operacion character varying(5) NOT NULL DEFAULT ''::character varying,
  moneda_foranea character varying(3) NOT NULL DEFAULT ''::character varying,
  vlr_for moneda DEFAULT 0,
  ref_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  ref_2 character varying(30) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.comprobante2
  OWNER TO postgres;

