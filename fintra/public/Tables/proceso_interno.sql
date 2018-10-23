-- Table: proceso_interno

-- DROP TABLE proceso_interno;

CREATE TABLE proceso_interno
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_proceso_meta integer NOT NULL,
  tipo character varying(80) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(300) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT "FK_proceso_interno" FOREIGN KEY (id_proceso_meta)
      REFERENCES proceso_meta (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE proceso_interno
  OWNER TO postgres;
GRANT ALL ON TABLE proceso_interno TO postgres;
GRANT SELECT ON TABLE proceso_interno TO msoto;

