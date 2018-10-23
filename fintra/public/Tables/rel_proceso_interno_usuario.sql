-- Table: rel_proceso_interno_usuario

-- DROP TABLE rel_proceso_interno_usuario;

CREATE TABLE rel_proceso_interno_usuario
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_proceso_interno integer NOT NULL,
  id_usuario integer NOT NULL,
  login character varying(15) NOT NULL DEFAULT ''::character varying,
  moderador character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT 'HCUELLO'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  proceso_principal character(1) NOT NULL DEFAULT 'S'::bpchar,
  lider_proceso character varying(1) NOT NULL DEFAULT 'N'::character varying,
  CONSTRAINT "FK_rpiu_pi" FOREIGN KEY (id_proceso_interno)
      REFERENCES proceso_interno (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_rpiu_user" FOREIGN KEY (id_usuario)
      REFERENCES usuarios (codigo_usuario) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rel_proceso_interno_usuario
  OWNER TO postgres;
GRANT ALL ON TABLE rel_proceso_interno_usuario TO postgres;
GRANT SELECT ON TABLE rel_proceso_interno_usuario TO msoto;

