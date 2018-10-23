-- Table: agencia

-- DROP TABLE agencia;

CREATE TABLE agencia
(
  dstrct character varying(4),
  id_agencia character varying(10) NOT NULL,
  id_mims character varying(12),
  nombre character varying(30),
  estado character varying(12),
  fecha_cambio_estado date
)
WITH (
  OIDS=TRUE
);
ALTER TABLE agencia
  OWNER TO postgres;
GRANT ALL ON TABLE agencia TO postgres;
GRANT SELECT ON TABLE agencia TO msoto;

