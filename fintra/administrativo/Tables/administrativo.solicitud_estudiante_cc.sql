-- Table: administrativo.solicitud_estudiante_cc

-- DROP TABLE administrativo.solicitud_estudiante_cc;

CREATE TABLE administrativo.solicitud_estudiante_cc
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud character varying(10) NOT NULL DEFAULT ''::character varying,
  parentesco_girador character varying(20) NOT NULL DEFAULT ''::character varying,
  universidad character varying(150) NOT NULL DEFAULT ''::character varying,
  programa character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_ingreso_programa timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  codigo character varying(15) NOT NULL DEFAULT ''::character varying,
  semestre character varying(50) NOT NULL DEFAULT ''::character varying,
  valor_semestre numeric(15,2) NOT NULL DEFAULT 0.0,
  tipo_carrera character varying(15) NOT NULL DEFAULT ''::character varying,
  trabaja character varying(10) NOT NULL DEFAULT 'N'::character varying,
  nombre_empresa character varying(60) NOT NULL DEFAULT ''::character varying,
  procesado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.solicitud_estudiante_cc
  OWNER TO postgres;

