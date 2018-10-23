-- Table: apicredit.cuestionario

-- DROP TABLE apicredit.cuestionario;

CREATE TABLE apicredit.cuestionario
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  id_cuestionario character varying(30) NOT NULL DEFAULT ''::character varying,
  resultado character varying(30) NOT NULL DEFAULT ''::character varying,
  registro character varying(30) NOT NULL DEFAULT ''::character varying,
  excluircliente character varying(30) NOT NULL DEFAULT ''::character varying,
  alertas character varying(30) NOT NULL DEFAULT ''::character varying,
  respuestaalerta character varying(30) NOT NULL DEFAULT ''::character varying,
  codigoalerta character varying(30) NOT NULL DEFAULT ''::character varying,
  trama_consulta text NOT NULL DEFAULT ''::text,
  trama_preguntas text NOT NULL DEFAULT ''::text,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(30) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(30) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.cuestionario
  OWNER TO postgres;

