-- Table: pre_aprobados_universidades

-- DROP TABLE pre_aprobados_universidades;

CREATE TABLE pre_aprobados_universidades
(
  nit character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_ultimo_credito numeric(20,2) NOT NULL,
  valor_aprobado numeric(20,2) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  negocio character varying(15) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE pre_aprobados_universidades
  OWNER TO postgres;
GRANT ALL ON TABLE pre_aprobados_universidades TO postgres;
GRANT SELECT ON TABLE pre_aprobados_universidades TO msoto;

