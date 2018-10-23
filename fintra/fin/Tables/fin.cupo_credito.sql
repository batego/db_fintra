-- Table: fin.cupo_credito

-- DROP TABLE fin.cupo_credito;

CREATE TABLE fin.cupo_credito
(
  id serial NOT NULL,
  nombre character varying(50) NOT NULL,
  cuenta character varying(25) NOT NULL,
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
ALTER TABLE fin.cupo_credito
  OWNER TO postgres;

