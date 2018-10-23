-- Table: administrativo.solicitud_persona_cc

-- DROP TABLE administrativo.solicitud_persona_cc;

CREATE TABLE administrativo.solicitud_persona_cc
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  numero_solicitud character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_persona character varying(6) NOT NULL DEFAULT ''::character varying,
  tipo character varying(5) NOT NULL DEFAULT 'S'::character varying,
  codcli character varying(15) NOT NULL DEFAULT ''::character varying,
  primer_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  primer_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  nombre character varying(100) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(30) NOT NULL DEFAULT ''::character varying,
  genero character varying(15) NOT NULL DEFAULT ''::character varying,
  estado_civil character varying(20) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  departamento character varying(10) NOT NULL DEFAULT ''::character varying,
  barrio character varying(100) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(20) NOT NULL DEFAULT ''::character varying,
  tipo_id character varying(3) NOT NULL DEFAULT 'CED'::character varying,
  fecha_expedicion_id timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  ciudad_expedicion_id character varying(20) NOT NULL DEFAULT ''::character varying,
  dpto_expedicion_id character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_nacimiento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  ciudad_nacimiento character varying(20) NOT NULL DEFAULT ''::character varying,
  dpto_nacimiento character varying(20) NOT NULL DEFAULT ''::character varying,
  nivel_estudio character varying(20) NOT NULL DEFAULT ''::character varying,
  profesion character varying(60) DEFAULT ''::character varying,
  telefono character varying(20) NOT NULL DEFAULT ''::character varying,
  celular character varying(20) NOT NULL DEFAULT ''::character varying,
  procesado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.solicitud_persona_cc
  OWNER TO postgres;

