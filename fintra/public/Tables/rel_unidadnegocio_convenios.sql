-- Table: rel_unidadnegocio_convenios

-- DROP TABLE rel_unidadnegocio_convenios;

CREATE TABLE rel_unidadnegocio_convenios
(
  id serial NOT NULL,
  id_unid_negocio integer NOT NULL,
  id_convenio integer NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  check_api character varying(1) NOT NULL DEFAULT 'N'::character varying,
  label_menu_api character varying(50) NOT NULL DEFAULT ''::character varying,
  producto character varying(5) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_this_convenios FOREIGN KEY (id_convenio)
      REFERENCES convenios (id_convenio) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_this_unidad_negocio FOREIGN KEY (id_unid_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rel_unidadnegocio_convenios
  OWNER TO postgres;
GRANT ALL ON TABLE rel_unidadnegocio_convenios TO postgres;
GRANT SELECT ON TABLE rel_unidadnegocio_convenios TO msoto;

