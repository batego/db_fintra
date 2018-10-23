-- Table: fin.linea_credito

-- DROP TABLE fin.linea_credito;

CREATE TABLE fin.linea_credito
(
  id serial NOT NULL,
  linea character varying(30) NOT NULL,
  hc character varying(6) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.linea_credito
  OWNER TO postgres;

