-- Table: perfil_vista_usuario

-- DROP TABLE perfil_vista_usuario;

CREATE TABLE perfil_vista_usuario
(
  cod_pvu integer NOT NULL DEFAULT nextval(('public.perfil_vista_usuario_id_seq'::text)::regclass), -- Codigo del perfil_vista_usuario.
  usuario character varying(20) NOT NULL DEFAULT ' '::character varying, -- Login del usuario.
  perfil character varying(20) NOT NULL DEFAULT ' '::character varying, -- Perfil de usuario.
  rec_status character varying(1) NOT NULL DEFAULT ' '::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ' '::character varying,
  cia character varying(15) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ' '::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE perfil_vista_usuario
  OWNER TO postgres;
GRANT ALL ON TABLE perfil_vista_usuario TO postgres;
GRANT SELECT ON TABLE perfil_vista_usuario TO msoto;
COMMENT ON TABLE perfil_vista_usuario
  IS 'Tabla donde se registran la relacion entre un usuario y un perfil_vista.';
COMMENT ON COLUMN perfil_vista_usuario.cod_pvu IS 'Codigo del perfil_vista_usuario.';
COMMENT ON COLUMN perfil_vista_usuario.usuario IS 'Login del usuario.';
COMMENT ON COLUMN perfil_vista_usuario.perfil IS 'Perfil de usuario.';


