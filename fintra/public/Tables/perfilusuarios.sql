-- Table: perfilusuarios

-- DROP TABLE perfilusuarios;

CREATE TABLE perfilusuarios
(
  perfil character varying(20) NOT NULL DEFAULT ''::character varying,
  usuarios character varying(50) NOT NULL DEFAULT ''::character varying,
  status character varying(1) NOT NULL DEFAULT ''::character varying,
  usuario_actualizacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT now(),
  usuario_creacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT now(),
  datos text NOT NULL DEFAULT ''::text, -- Datos del perfil
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE perfilusuarios
  OWNER TO postgres;
GRANT ALL ON TABLE perfilusuarios TO postgres;
GRANT SELECT ON TABLE perfilusuarios TO msoto;
COMMENT ON COLUMN perfilusuarios.datos IS 'Datos del perfil';


