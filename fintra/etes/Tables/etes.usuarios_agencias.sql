-- Table: etes.usuarios_agencias

-- DROP TABLE etes.usuarios_agencias;

CREATE TABLE etes.usuarios_agencias
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_agencia integer NOT NULL,
  id_usuario character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_usuario character varying(300) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_id_agencia_usuarios FOREIGN KEY (id_agencia)
      REFERENCES etes.agencias (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.usuarios_agencias
  OWNER TO postgres;

