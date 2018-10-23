-- Table: feriados

-- DROP TABLE feriados;

CREATE TABLE feriados
(
  id serial NOT NULL,
  fecha date NOT NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE feriados
  OWNER TO postgres;
GRANT ALL ON TABLE feriados TO postgres;
GRANT SELECT ON TABLE feriados TO msoto;

