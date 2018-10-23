-- Table: perfil_usuario

-- DROP TABLE perfil_usuario;

CREATE TABLE perfil_usuario
(
  dstrct_code character varying(4) NOT NULL DEFAULT ''::character varying,
  perfil character varying(40) NOT NULL DEFAULT ''::character varying,
  usuario character varying(40) NOT NULL DEFAULT ''::character varying,
  usuario_creacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT now(),
  usuario_actualizacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE perfil_usuario
  OWNER TO postgres;
GRANT ALL ON TABLE perfil_usuario TO postgres;
GRANT SELECT ON TABLE perfil_usuario TO msoto;

