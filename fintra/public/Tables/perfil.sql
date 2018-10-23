-- Table: perfil

-- DROP TABLE perfil;

CREATE TABLE perfil
(
  id_perfil numeric(12,0),
  nombre character varying(60),
  estado character varying(1),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE perfil
  OWNER TO postgres;
GRANT ALL ON TABLE perfil TO postgres;
GRANT SELECT ON TABLE perfil TO msoto;

