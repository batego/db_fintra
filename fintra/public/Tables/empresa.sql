-- Table: empresa

-- DROP TABLE empresa;

CREATE TABLE empresa
(
  id serial NOT NULL,
  short_desc character varying NOT NULL DEFAULT ''::character varying,
  descripcion character varying NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE empresa
  OWNER TO postgres;
GRANT ALL ON TABLE empresa TO postgres;
GRANT SELECT ON TABLE empresa TO msoto;

