-- Table: proceso_meta

-- DROP TABLE proceso_meta;

CREATE TABLE proceso_meta
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  meta_proceso character varying NOT NULL DEFAULT ''::character varying,
  descripcion character varying(300) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_procesometa_cia FOREIGN KEY (dstrct)
      REFERENCES cia (dstrct) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=TRUE
);
ALTER TABLE proceso_meta
  OWNER TO postgres;
GRANT ALL ON TABLE proceso_meta TO postgres;
GRANT SELECT ON TABLE proceso_meta TO msoto;

