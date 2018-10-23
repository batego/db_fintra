-- Table: administrativo.demanda_docs

-- DROP TABLE administrativo.demanda_docs;

CREATE TABLE administrativo.demanda_docs
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_demanda integer NOT NULL,
  tipo_doc integer NOT NULL,
  header_info text NOT NULL DEFAULT ''::character varying,
  initial_info text NOT NULL DEFAULT ''::character varying,
  footer_info text NOT NULL DEFAULT ''::character varying,
  signing_info text NOT NULL DEFAULT ''::character varying,
  footer_page text NOT NULL DEFAULT ''::character varying,
  aux_1 text NOT NULL DEFAULT ''::character varying,
  aux_2 text NOT NULL DEFAULT ''::character varying,
  aux_3 text NOT NULL DEFAULT ''::character varying,
  aux_4 text NOT NULL DEFAULT ''::character varying,
  aux_5 text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT demanda_docs_id_demanda_fkey FOREIGN KEY (id_demanda)
      REFERENCES administrativo.demanda (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT demanda_docs_id_demanda_fkey1 FOREIGN KEY (id_demanda)
      REFERENCES administrativo.demanda (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.demanda_docs
  OWNER TO postgres;

