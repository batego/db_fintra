-- Table: proceso_sgc

-- DROP TABLE proceso_sgc;

CREATE TABLE proceso_sgc
(
  id serial NOT NULL,
  id_empresa integer NOT NULL,
  meta_proceso character varying NOT NULL DEFAULT ''::character varying,
  descripcion_proceso character varying NOT NULL DEFAULT ''::character varying,
  activo integer DEFAULT 0,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT "FK_proceso_sgc" FOREIGN KEY (id_empresa)
      REFERENCES empresa (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=TRUE
);
ALTER TABLE proceso_sgc
  OWNER TO postgres;
GRANT ALL ON TABLE proceso_sgc TO postgres;
GRANT SELECT ON TABLE proceso_sgc TO msoto;

