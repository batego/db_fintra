-- Table: apicredit.configuracion_codigos_dc

-- DROP TABLE apicredit.configuracion_codigos_dc;

CREATE TABLE apicredit.configuracion_codigos_dc
(
  id serial NOT NULL,
  referencia_codigo character varying(50) NOT NULL DEFAULT ''::character varying,
  codigo character varying(10) NOT NULL DEFAULT ''::character varying,
  codigo_transaccion character varying(10) NOT NULL DEFAULT ''::character varying,
  codigo_parametro character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  sector character varying(10) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.configuracion_codigos_dc
  OWNER TO postgres;

