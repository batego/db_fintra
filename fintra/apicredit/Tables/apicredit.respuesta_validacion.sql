-- Table: apicredit.respuesta_validacion

-- DROP TABLE apicredit.respuesta_validacion;

CREATE TABLE apicredit.respuesta_validacion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion character varying(5) NOT NULL DEFAULT ''::character varying,
  fecha_expedicion character varying(20) NOT NULL DEFAULT ''::character varying,
  valapellido character varying(20) NOT NULL DEFAULT ''::character varying,
  valnombre character varying(20) NOT NULL DEFAULT ''::character varying,
  valfechaexp character varying(10) NOT NULL DEFAULT ''::character varying,
  excluircliente character varying(10) NOT NULL DEFAULT ''::character varying,
  alertas character varying(10) NOT NULL DEFAULT ''::character varying,
  respuestaalerta character varying(10) NOT NULL DEFAULT ''::character varying,
  codigoalerta character varying(10) NOT NULL DEFAULT ''::character varying,
  resultado character varying(20) NOT NULL DEFAULT ''::character varying,
  regvalidacion character varying(20) NOT NULL DEFAULT ''::character varying,
  resultadoproceso character varying(10) NOT NULL DEFAULT ''::character varying,
  nombre character varying(30) NOT NULL DEFAULT ''::character varying,
  trama_consulta text NOT NULL DEFAULT ''::text,
  trama_resp text NOT NULL DEFAULT ''::text,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.respuesta_validacion
  OWNER TO postgres;

