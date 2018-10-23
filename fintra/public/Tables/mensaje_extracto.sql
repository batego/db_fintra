-- Table: mensaje_extracto

-- DROP TABLE mensaje_extracto;

CREATE TABLE mensaje_extracto
(
  id serial NOT NULL,
  id_unidad_negocio integer,
  descripcion character varying,
  tipo integer,
  periodo integer,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE mensaje_extracto
  OWNER TO postgres;
GRANT ALL ON TABLE mensaje_extracto TO postgres;
GRANT SELECT ON TABLE mensaje_extracto TO msoto;

