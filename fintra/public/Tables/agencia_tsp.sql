-- Table: agencia_tsp

-- DROP TABLE agencia_tsp;

CREATE TABLE agencia_tsp
(
  dstrct character varying(4),
  id_agencia character varying(10) NOT NULL,
  id_mims character varying(12),
  nombre character varying(30),
  estado character varying(12),
  fecha_cambio_estado date,
  codigo_abc character varying(4) NOT NULL DEFAULT ''::character varying -- Codigo Abc
)
WITH (
  OIDS=TRUE
);
ALTER TABLE agencia_tsp
  OWNER TO postgres;
GRANT ALL ON TABLE agencia_tsp TO postgres;
GRANT SELECT ON TABLE agencia_tsp TO msoto;
COMMENT ON COLUMN agencia_tsp.codigo_abc IS 'Codigo Abc';


