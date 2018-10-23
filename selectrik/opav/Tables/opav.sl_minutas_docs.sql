-- Table: opav.sl_minutas_docs

-- DROP TABLE opav.sl_minutas_docs;

CREATE TABLE opav.sl_minutas_docs
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_contrato character varying(20) NOT NULL,
  id_tipo_doc integer NOT NULL,
  document_info text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT sl_minutas_docs_id_contrato_fkey FOREIGN KEY (id_contrato)
      REFERENCES opav.sl_minutas (numero_contrato) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_minutas_docs
  OWNER TO postgres;
