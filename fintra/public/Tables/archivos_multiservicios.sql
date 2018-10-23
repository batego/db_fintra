-- Table: archivos_multiservicios

-- DROP TABLE archivos_multiservicios;

CREATE TABLE archivos_multiservicios
(
  id serial NOT NULL,
  reg_status character varying(1),
  dstrct character varying(4),
  document character varying(50),
  filename character varying(100),
  agencia character varying(4),
  last_update timestamp without time zone,
  user_update character varying(50),
  creation_date timestamp without time zone,
  creation_user character varying(50),
  tipo character varying(10),
  filepath character varying,
  id_tipo_archivo integer NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE archivos_multiservicios
  OWNER TO postgres;
GRANT ALL ON TABLE archivos_multiservicios TO postgres;
GRANT SELECT ON TABLE archivos_multiservicios TO msoto;

