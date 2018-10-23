-- Table: sql_reportes

-- DROP TABLE sql_reportes;

CREATE TABLE sql_reportes
(
  id serial NOT NULL,
  sql_txt character varying NOT NULL,
  name character(50) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sql_reportes
  OWNER TO postgres;
GRANT ALL ON TABLE sql_reportes TO postgres;
GRANT SELECT ON TABLE sql_reportes TO msoto;

