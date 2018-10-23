-- Table: rel_unidadnegocio_documentos_requeridos

-- DROP TABLE rel_unidadnegocio_documentos_requeridos;

CREATE TABLE rel_unidadnegocio_documentos_requeridos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_unidad_negocio integer NOT NULL,
  id_documento integer NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT rel_unidadnegocio_documentos_requeridos_id_documento_fkey FOREIGN KEY (id_documento)
      REFERENCES documentos_requeridos_fintracredit (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT rel_unidadnegocio_documentos_requeridos_id_unidad_fkey FOREIGN KEY (id_unidad_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rel_unidadnegocio_documentos_requeridos
  OWNER TO postgres;
GRANT ALL ON TABLE rel_unidadnegocio_documentos_requeridos TO postgres;
GRANT SELECT ON TABLE rel_unidadnegocio_documentos_requeridos TO msoto;

