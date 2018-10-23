-- Table: apicredit.vector_comportamiento

-- DROP TABLE apicredit.vector_comportamiento;

CREATE TABLE apicredit.vector_comportamiento
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  mes integer NOT NULL,
  mora character varying(8) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.vector_comportamiento
  OWNER TO postgres;

