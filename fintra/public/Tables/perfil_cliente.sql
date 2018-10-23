-- Table: perfil_cliente

-- DROP TABLE perfil_cliente;

CREATE TABLE perfil_cliente
(
  dstrct_code character varying(4) NOT NULL DEFAULT ''::character varying,
  perfil character varying(40) NOT NULL DEFAULT ''::character varying,
  cliente character varying(40) NOT NULL DEFAULT ''::character varying,
  usuario_creacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT now(),
  usuario_actualizacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE perfil_cliente
  OWNER TO postgres;
GRANT ALL ON TABLE perfil_cliente TO postgres;
GRANT SELECT ON TABLE perfil_cliente TO msoto;

