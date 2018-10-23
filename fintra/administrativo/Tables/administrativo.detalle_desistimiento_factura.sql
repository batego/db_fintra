-- Table: administrativo.detalle_desistimiento_factura

-- DROP TABLE administrativo.detalle_desistimiento_factura;

CREATE TABLE administrativo.detalle_desistimiento_factura
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  periodo_foto character varying(6) NOT NULL DEFAULT ''::character varying,
  negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  documento character varying(20) NOT NULL DEFAULT ''::character varying,
  num_comprobante character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_desistimiento timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  valor_desistido numeric(11,2) NOT NULL DEFAULT 0.00,
  cuenta_contable character varying(25) NOT NULL DEFAULT ''::character varying,
  linea_negocio character varying(30) NOT NULL DEFAULT ''::character varying,
  cartera_en character varying(30) NOT NULL DEFAULT ''::character varying,
  estado_proceso character varying(2) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.detalle_desistimiento_factura
  OWNER TO postgres;

