-- Table: apicredit.contador_consultas_evidente

-- DROP TABLE apicredit.contador_consultas_evidente;

CREATE TABLE apicredit.contador_consultas_evidente
(
  id serial NOT NULL,
  indentificacion character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.contador_consultas_evidente
  OWNER TO postgres;

