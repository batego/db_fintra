-- Table: causacion_metrotel_total

-- DROP TABLE causacion_metrotel_total;

CREATE TABLE causacion_metrotel_total
(
  zona numeric NOT NULL DEFAULT 0.00,
  tipodoc numeric NOT NULL DEFAULT 0.00,
  numerodo numeric NOT NULL DEFAULT 0.00,
  identificacion numeric NOT NULL DEFAULT 0.00,
  apellido1 character varying,
  apellido2 character varying,
  nombre1 character varying,
  nombre2 character varying,
  fecha_apertura timestamp without time zone NOT NULL,
  fecha_vencimiento timestamp without time zone NOT NULL,
  plazo numeric NOT NULL DEFAULT 0.00,
  tasa numeric NOT NULL DEFAULT 0.00,
  monto numeric NOT NULL DEFAULT 0.00,
  numero_credito numeric NOT NULL DEFAULT 0.00,
  saldo_capital numeric NOT NULL DEFAULT 0.00,
  sicc numeric NOT NULL DEFAULT 0.00,
  smcco numeric NOT NULL DEFAULT 0.00,
  ndcm numeric NOT NULL DEFAULT 0.00,
  iccm numeric NOT NULL DEFAULT 0.00,
  ndm numeric NOT NULL DEFAULT 0.00,
  ssxc numeric NOT NULL DEFAULT 0.00,
  clase_garantia character varying NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE causacion_metrotel_total
  OWNER TO postgres;
GRANT ALL ON TABLE causacion_metrotel_total TO postgres;
GRANT SELECT ON TABLE causacion_metrotel_total TO msoto;

