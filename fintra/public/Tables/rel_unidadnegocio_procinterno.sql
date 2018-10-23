-- Table: rel_unidadnegocio_procinterno

-- DROP TABLE rel_unidadnegocio_procinterno;

CREATE TABLE rel_unidadnegocio_procinterno
(
  id serial NOT NULL,
  id_proceso_interno integer NOT NULL,
  id_unid_negocio integer NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_this_unidad_negocio FOREIGN KEY (id_unid_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rel_unidadnegocio_procinterno
  OWNER TO postgres;
GRANT ALL ON TABLE rel_unidadnegocio_procinterno TO postgres;
GRANT SELECT ON TABLE rel_unidadnegocio_procinterno TO msoto;

