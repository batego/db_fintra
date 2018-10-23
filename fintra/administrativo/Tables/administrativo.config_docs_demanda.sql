-- Table: administrativo.config_docs_demanda

-- DROP TABLE administrativo.config_docs_demanda;

CREATE TABLE administrativo.config_docs_demanda
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
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
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.config_docs_demanda
  OWNER TO postgres;

