-- Table: barrio

-- DROP TABLE barrio;

CREATE TABLE barrio
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  codciu character varying(6) NOT NULL DEFAULT ''::character varying,
  nombre character varying(100) NOT NULL DEFAULT ''::character varying,
  estrato character varying(5) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE barrio
  OWNER TO postgres;

