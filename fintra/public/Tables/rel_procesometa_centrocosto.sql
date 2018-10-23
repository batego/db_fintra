-- Table: rel_procesometa_centrocosto

-- DROP TABLE rel_procesometa_centrocosto;

CREATE TABLE rel_procesometa_centrocosto
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_proceso_meta integer NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  centro_costo character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  nombre character varying,
  cuenta character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rel_procesometa_centrocosto
  OWNER TO postgres;

