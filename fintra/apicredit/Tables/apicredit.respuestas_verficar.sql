-- Table: apicredit.respuestas_verficar

-- DROP TABLE apicredit.respuestas_verficar;

CREATE TABLE apicredit.respuestas_verficar
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  id_cuestionario character varying(20) NOT NULL DEFAULT ''::character varying,
  resultado character varying(20) NOT NULL DEFAULT ''::character varying,
  aprobacion character varying(20) NOT NULL DEFAULT ''::character varying,
  preguntas_completas character varying(20) NOT NULL DEFAULT ''::character varying,
  score character varying(20) NOT NULL DEFAULT ''::character varying,
  codigo_seguridad character varying(20) NOT NULL DEFAULT ''::character varying,
  aprobado100porcientook character varying(20) NOT NULL DEFAULT ''::character varying,
  entidad character varying(100) NOT NULL DEFAULT ''::character varying,
  numero_consultas character varying(10) NOT NULL DEFAULT ''::character varying,
  numero_consultas_aprobados character varying(10) NOT NULL DEFAULT ''::character varying,
  numero_consultas_no_aprobados character varying(10) NOT NULL DEFAULT ''::character varying,
  ultima_consulta character varying(20) NOT NULL DEFAULT ''::character varying,
  tipo_huella character varying(20) NOT NULL DEFAULT ''::character varying,
  trama_consulta text NOT NULL DEFAULT ''::text,
  trama_respuesta text NOT NULL DEFAULT ''::text,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.respuestas_verficar
  OWNER TO postgres;

