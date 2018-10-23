-- Table: cliente_afil

-- DROP TABLE cliente_afil;

CREATE TABLE cliente_afil
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  nit_afil character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_cli character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cliente_afil
  OWNER TO postgres;
GRANT ALL ON TABLE cliente_afil TO postgres;
GRANT SELECT ON TABLE cliente_afil TO msoto;

