-- Table: detalle_negocio_cheques

-- DROP TABLE detalle_negocio_cheques;

CREATE TABLE detalle_negocio_cheques
(
  codigo_negocio character varying(15) NOT NULL DEFAULT ''::character varying,
  item character varying(6) NOT NULL,
  fecha_consignacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  valor numeric(14,4) NOT NULL DEFAULT 0,
  porte numeric(9,4) DEFAULT 0,
  dias numeric(6,2) NOT NULL DEFAULT 0,
  factor numeric(9,4) NOT NULL DEFAULT 0,
  remesa numeric(12,4) NOT NULL DEFAULT 0,
  descuento numeric(12,3) NOT NULL DEFAULT 0,
  valor_sin_custodia numeric(12,3) NOT NULL DEFAULT 0,
  custodia numeric(12,3) NOT NULL DEFAULT 0,
  valor_girable numeric(15,4) NOT NULL DEFAULT 0,
  tasa_efectiva numeric(12,6) NOT NULL DEFAULT 0,
  tasa_nominal numeric(12,6) NOT NULL DEFAULT 0,
  fecha_cheque timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  numero_cheque character varying(20) NOT NULL DEFAULT '0'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE detalle_negocio_cheques
  OWNER TO postgres;
GRANT ALL ON TABLE detalle_negocio_cheques TO postgres;
GRANT SELECT ON TABLE detalle_negocio_cheques TO msoto;

