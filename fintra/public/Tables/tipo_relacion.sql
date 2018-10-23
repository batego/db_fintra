-- Table: tipo_relacion

-- DROP TABLE tipo_relacion;

CREATE TABLE tipo_relacion
(
  tipo character varying(40) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(40) NOT NULL DEFAULT ''::character varying,
  usuario_creacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT now(),
  usuario_actualizacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT now(),
  dstrct_code character varying(4) NOT NULL DEFAULT 'TSP'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tipo_relacion
  OWNER TO postgres;
GRANT ALL ON TABLE tipo_relacion TO postgres;
GRANT SELECT ON TABLE tipo_relacion TO msoto;

