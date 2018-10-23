-- Table: ingresoci

-- DROP TABLE ingresoci;

CREATE TABLE ingresoci
(
  num_ingreso character varying(11),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ingresoci
  OWNER TO postgres;
GRANT ALL ON TABLE ingresoci TO postgres;
GRANT SELECT ON TABLE ingresoci TO msoto;

