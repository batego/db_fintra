-- Table: perfiles

-- DROP TABLE perfiles;

CREATE TABLE perfiles
(
  dstrct_code character varying(4) NOT NULL DEFAULT 'TSP'::character varying,
  perfil character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(40) NOT NULL DEFAULT ''::character varying,
  usuario_creacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT now(),
  usuario_actualizacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE perfiles
  OWNER TO postgres;
GRANT ALL ON TABLE perfiles TO postgres;
GRANT SELECT ON TABLE perfiles TO msoto;

