-- Table: administrativo.demanda_docs_det

-- DROP TABLE administrativo.demanda_docs_det;

CREATE TABLE administrativo.demanda_docs_det
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_demanda_doc integer NOT NULL,
  tipo character varying(4) NOT NULL DEFAULT ''::character varying,
  titulo character varying(50) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT demanda_docs_det_id_demanda_doc_fkey FOREIGN KEY (id_demanda_doc)
      REFERENCES administrativo.demanda_docs (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT demanda_docs_det_id_demanda_doc_fkey1 FOREIGN KEY (id_demanda_doc)
      REFERENCES administrativo.demanda_docs (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.demanda_docs_det
  OWNER TO postgres;

