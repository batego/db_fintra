-- Table: con.modulos_dc

-- DROP TABLE con.modulos_dc;

CREATE TABLE con.modulos_dc
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  codigo character varying(50) NOT NULL DEFAULT ''::character varying,
  modulo character varying(150) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.modulos_dc
  OWNER TO postgres;

