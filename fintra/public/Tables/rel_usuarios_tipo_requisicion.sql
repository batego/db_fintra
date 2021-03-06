-- Table: rel_usuarios_tipo_requisicion

-- DROP TABLE rel_usuarios_tipo_requisicion;

CREATE TABLE rel_usuarios_tipo_requisicion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  id_usuario integer NOT NULL,
  login character varying(15) NOT NULL DEFAULT ''::character varying,
  id_tipo_req integer NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT rel_usuarios_tipo_requisicion_id_tipo_req_fkey FOREIGN KEY (id_tipo_req)
      REFERENCES tipo_requisicion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT rel_usuarios_tipo_requisicion_id_usuario_fkey FOREIGN KEY (id_usuario)
      REFERENCES usuarios (codigo_usuario) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rel_usuarios_tipo_requisicion
  OWNER TO postgres;
GRANT ALL ON TABLE rel_usuarios_tipo_requisicion TO postgres;
GRANT SELECT ON TABLE rel_usuarios_tipo_requisicion TO msoto;

