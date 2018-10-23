-- Table: proyectousuarios

-- DROP TABLE proyectousuarios;

CREATE TABLE proyectousuarios
(
  proyecto character varying(10) NOT NULL DEFAULT ''::character varying,
  usuario character varying(50) NOT NULL DEFAULT ''::character varying,
  status character varying(1) NOT NULL DEFAULT ''::character varying,
  usuario_actualizacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT now(),
  usuario_creacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE proyectousuarios
  OWNER TO postgres;
GRANT ALL ON TABLE proyectousuarios TO postgres;
GRANT SELECT ON TABLE proyectousuarios TO msoto;

