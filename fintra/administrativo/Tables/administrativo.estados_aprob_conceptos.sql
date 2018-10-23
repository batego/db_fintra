-- Table: administrativo.estados_aprob_conceptos

-- DROP TABLE administrativo.estados_aprob_conceptos;

CREATE TABLE administrativo.estados_aprob_conceptos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  codigo character varying(20) NOT NULL,
  nombre character varying(20) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.estados_aprob_conceptos
  OWNER TO postgres;

