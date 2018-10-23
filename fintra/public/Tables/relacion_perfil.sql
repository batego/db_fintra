-- Table: relacion_perfil

-- DROP TABLE relacion_perfil;

CREATE TABLE relacion_perfil
(
  dstrct_code character varying(4) NOT NULL DEFAULT ''::character varying,
  relacion character varying(40) NOT NULL DEFAULT ''::character varying,
  perfil character varying(40) NOT NULL DEFAULT ''::character varying,
  usuario_creacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT now(),
  usuario_actualizacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE relacion_perfil
  OWNER TO postgres;
GRANT ALL ON TABLE relacion_perfil TO postgres;
GRANT SELECT ON TABLE relacion_perfil TO msoto;

