-- Table: solicitud_estudiante

-- DROP TABLE solicitud_estudiante;

CREATE TABLE solicitud_estudiante
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  parentesco_girador character varying(20) NOT NULL DEFAULT ''::character varying,
  universidad character varying(150) NOT NULL DEFAULT ''::character varying,
  programa character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_ingreso_programa timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  codigo character varying(15) NOT NULL DEFAULT ''::character varying,
  semestre integer NOT NULL DEFAULT 0,
  valor_semestre numeric(15,2) NOT NULL DEFAULT 0.0,
  tipo_carrera character varying(15) NOT NULL DEFAULT ''::character varying,
  trabaja character varying(1) NOT NULL DEFAULT 'N'::character varying,
  nombre_empresa character varying(100) NOT NULL DEFAULT ''::character varying,
  direccion_empresa character varying(100) NOT NULL DEFAULT ''::character varying,
  telefono_empresa character varying(15) NOT NULL DEFAULT ''::character varying,
  salario numeric(15,2) NOT NULL DEFAULT 0.0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  colegio_bachillerato character varying(1) NOT NULL DEFAULT ''::character varying,
  nivel_educativo_padre character varying(30) NOT NULL DEFAULT ''::character varying,
  sisben character varying(30) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_solicitud_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_estudiante
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_estudiante TO postgres;
GRANT SELECT ON TABLE solicitud_estudiante TO msoto;

