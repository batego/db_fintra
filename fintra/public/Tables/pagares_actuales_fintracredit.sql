-- Table: pagares_actuales_fintracredit

-- DROP TABLE pagares_actuales_fintracredit;

CREATE TABLE pagares_actuales_fintracredit
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  num_solicitud integer NOT NULL DEFAULT 0,
  negocio character varying(15) NOT NULL DEFAULT ''::character varying,
  num_pagare character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE pagares_actuales_fintracredit
  OWNER TO postgres;

