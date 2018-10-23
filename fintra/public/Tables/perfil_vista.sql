-- Table: perfil_vista

-- DROP TABLE perfil_vista;

CREATE TABLE perfil_vista
(
  perfil character varying(20) NOT NULL DEFAULT ' '::character varying, -- Perfil del usuario.
  pagina character varying(50) NOT NULL DEFAULT ' '::character varying, -- Codigo de la pagina.
  campo character varying(20) NOT NULL DEFAULT ' '::character varying, -- Nombre del campo.
  visible character varying(20) NOT NULL DEFAULT ' '::character varying, -- Indica si el campo es visible al perfil.
  editable character varying(20) NOT NULL DEFAULT ' '::character varying, -- Indica si el campo es editable al perfil.
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
ALTER TABLE perfil_vista
  OWNER TO postgres;
GRANT ALL ON TABLE perfil_vista TO postgres;
GRANT SELECT ON TABLE perfil_vista TO msoto;
COMMENT ON TABLE perfil_vista
  IS 'Tabla donde se registra la asociacion entre un perfil y una vista y los permisos que este tiene sobre los campos.';
COMMENT ON COLUMN perfil_vista.perfil IS 'Perfil del usuario.';
COMMENT ON COLUMN perfil_vista.pagina IS 'Codigo de la pagina.';
COMMENT ON COLUMN perfil_vista.campo IS 'Nombre del campo.';
COMMENT ON COLUMN perfil_vista.visible IS 'Indica si el campo es visible al perfil.';
COMMENT ON COLUMN perfil_vista.editable IS 'Indica si el campo es editable al perfil.';


