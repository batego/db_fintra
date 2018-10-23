-- Table: apicredit.tab_informacion_estudiante

-- DROP TABLE apicredit.tab_informacion_estudiante;

CREATE TABLE apicredit.tab_informacion_estudiante
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL,
  tipo_persona character varying(6) NOT NULL DEFAULT ''::character varying,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  tipo_id character varying(3) NOT NULL DEFAULT 'CED'::character varying,
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_expedicion_id timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dpto_expedicion_id character varying(6) NOT NULL DEFAULT ''::character varying,
  ciudad_expedicion_id character varying(6) NOT NULL DEFAULT ''::character varying,
  primer_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  primer_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  fecha_nacimiento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dpto_nacimiento character varying(6) NOT NULL DEFAULT ''::character varying,
  ciudad_nacimiento character varying(6) NOT NULL DEFAULT ''::character varying,
  estado_civil character varying(1) NOT NULL DEFAULT ''::character varying,
  nivel_estudio character varying(15) NOT NULL DEFAULT ''::character varying,
  profesion character varying(60) DEFAULT ''::character varying,
  genero character varying(1) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  departamento character varying(10) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(30) NOT NULL DEFAULT ''::character varying,
  barrio character varying(100) NOT NULL DEFAULT ''::character varying,
  estrato integer NOT NULL DEFAULT 0,
  tipo_vivienda character varying(30) NOT NULL DEFAULT ''::character varying,
  tiempo_residencia character varying(20) NOT NULL DEFAULT ''::character varying,
  telefono character varying(15) NOT NULL DEFAULT ''::character varying,
  estado_civil_padres character varying(30) NOT NULL DEFAULT ''::character varying,
  celular character varying(15) NOT NULL DEFAULT ''::character varying,
  email character varying(100) NOT NULL DEFAULT ''::character varying,
  posee_bienes character varying(1) NOT NULL DEFAULT ''::character varying,
  universidad character varying(150) NOT NULL DEFAULT ''::character varying,
  tipo_carrera character varying(15) NOT NULL DEFAULT ''::character varying,
  programa character varying(100) NOT NULL DEFAULT ''::character varying,
  codigo character varying(15) NOT NULL DEFAULT ''::character varying,
  semestre integer NOT NULL DEFAULT 0,
  parentesco_girador character varying(20) NOT NULL DEFAULT ''::character varying,
  colegio_bachillerato character varying(1) NOT NULL DEFAULT ''::character varying,
  nivel_educativo_padre character varying(30) NOT NULL DEFAULT ''::character varying,
  sisben character varying(30) NOT NULL DEFAULT ''::character varying,
  trabaja character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.tab_informacion_estudiante
  OWNER TO postgres;

