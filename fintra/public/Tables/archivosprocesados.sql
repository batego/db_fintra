-- Table: archivosprocesados

-- DROP TABLE archivosprocesados;

CREATE TABLE archivosprocesados
(
  id serial NOT NULL,
  nombre_archivo character varying(20) NOT NULL,
  nro_lineas character varying(20),
  observaciones character varying(50),
  estado character varying(15),
  creation_user character varying(15) NOT NULL,
  creation_date timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE archivosprocesados
  OWNER TO postgres;
GRANT ALL ON TABLE archivosprocesados TO postgres;
GRANT SELECT ON TABLE archivosprocesados TO msoto;

