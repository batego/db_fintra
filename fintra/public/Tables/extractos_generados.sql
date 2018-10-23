-- Table: extractos_generados

-- DROP TABLE extractos_generados;

CREATE TABLE extractos_generados
(
  id serial NOT NULL,
  unidad_negocio numeric,
  cod_neg character varying,
  nit character varying,
  periodo character varying,
  generado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone,
  creation_user character varying,
  num_ciclo integer,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE extractos_generados
  OWNER TO postgres;
GRANT ALL ON TABLE extractos_generados TO postgres;
GRANT SELECT ON TABLE extractos_generados TO msoto;

-- Index: idx_extractos_generados

-- DROP INDEX idx_extractos_generados;

CREATE INDEX idx_extractos_generados
  ON extractos_generados
  USING btree
  (unidad_negocio, periodo, num_ciclo);


