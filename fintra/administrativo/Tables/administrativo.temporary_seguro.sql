-- Table: administrativo.temporary_seguro

-- DROP TABLE administrativo.temporary_seguro;

CREATE TABLE administrativo.temporary_seguro
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  cobertura_rango_ini numeric(11,2) NOT NULL DEFAULT 0,
  cobertura_rango_fin numeric(11,2) NOT NULL DEFAULT 0,
  prima numeric(9,0) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.temporary_seguro
  OWNER TO postgres;

