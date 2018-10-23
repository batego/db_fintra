-- Table: tipo_acto

-- DROP TABLE tipo_acto;

CREATE TABLE tipo_acto
(
  id serial NOT NULL,
  descripcion character varying(30) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tipo_acto
  OWNER TO postgres;
GRANT ALL ON TABLE tipo_acto TO postgres;
GRANT SELECT ON TABLE tipo_acto TO msoto;

