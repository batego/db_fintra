-- Table: administrativo.rel_jefatura_usuario

-- DROP TABLE administrativo.rel_jefatura_usuario;

CREATE TABLE administrativo.rel_jefatura_usuario
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_proceso_interno integer NOT NULL,
  id_usuario character varying(10) NOT NULL,
  jefatura character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  id_empresa integer NOT NULL,
  CONSTRAINT rel_jefatura_usuario_id_proceso_interno_fkey FOREIGN KEY (id_proceso_interno)
      REFERENCES proceso_interno (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT rel_jefatura_usuario_id_usuario_fkey FOREIGN KEY (id_usuario)
      REFERENCES usuarios (idusuario) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.rel_jefatura_usuario
  OWNER TO postgres;

