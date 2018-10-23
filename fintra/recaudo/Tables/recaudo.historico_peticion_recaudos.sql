-- Table: recaudo.historico_peticion_recaudos

-- DROP TABLE recaudo.historico_peticion_recaudos;

CREATE TABLE recaudo.historico_peticion_recaudos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  entidad character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_operacion character varying(100) NOT NULL DEFAULT ''::character varying,
  xml_input text DEFAULT ''::text,
  xml_output text DEFAULT ''::text,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(100) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(100) NOT NULL DEFAULT ''::character varying,
  tipo_canal character varying(30) DEFAULT ''::character varying,
  request_id character varying(100) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.historico_peticion_recaudos
  OWNER TO postgres;

