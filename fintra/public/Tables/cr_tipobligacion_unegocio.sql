-- Table: cr_tipobligacion_unegocio

-- DROP TABLE cr_tipobligacion_unegocio;

CREATE TABLE cr_tipobligacion_unegocio
(
  id serial NOT NULL,
  id_tipo_obligacion integer NOT NULL,
  id_unidad_negocio integer NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_tipobligacion_unegocio
  OWNER TO postgres;
GRANT ALL ON TABLE cr_tipobligacion_unegocio TO postgres;
GRANT SELECT ON TABLE cr_tipobligacion_unegocio TO msoto;

