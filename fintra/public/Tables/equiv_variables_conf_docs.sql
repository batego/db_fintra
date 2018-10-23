-- Table: equiv_variables_conf_docs

-- DROP TABLE equiv_variables_conf_docs;

CREATE TABLE equiv_variables_conf_docs
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  modulo character varying(50) NOT NULL DEFAULT ''::character varying,
  codparam character varying(5) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying,
  id_procedencia integer NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_equiv_variables_procedencia FOREIGN KEY (id_procedencia)
      REFERENCES procedencia_variables_conf_docs (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equiv_variables_conf_docs
  OWNER TO postgres;
GRANT ALL ON TABLE equiv_variables_conf_docs TO postgres;
GRANT SELECT ON TABLE equiv_variables_conf_docs TO msoto;

