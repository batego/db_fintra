-- Table: config_docs_garantias_comunitarias

-- DROP TABLE config_docs_garantias_comunitarias;

CREATE TABLE config_docs_garantias_comunitarias
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_tipo_doc integer NOT NULL,
  document_info text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE config_docs_garantias_comunitarias
  OWNER TO postgres;
GRANT ALL ON TABLE config_docs_garantias_comunitarias TO postgres;
GRANT SELECT ON TABLE config_docs_garantias_comunitarias TO msoto;

