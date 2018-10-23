-- Table: bancos_direccion

-- DROP TABLE bancos_direccion;

CREATE TABLE bancos_direccion
(
  cod_ciud character varying NOT NULL,
  direccion character varying NOT NULL,
  no_cta character varying NOT NULL,
  cod_ent character varying NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE bancos_direccion
  OWNER TO postgres;
GRANT ALL ON TABLE bancos_direccion TO postgres;
GRANT SELECT ON TABLE bancos_direccion TO msoto;

