-- Table: opav.sl_anticipos_casos

-- DROP TABLE opav.sl_anticipos_casos;

CREATE TABLE opav.sl_anticipos_casos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  caso character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(200) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_anticipos_casos
  OWNER TO postgres;
COMMENT ON TABLE opav.sl_anticipos_casos
  IS 'En esta tabla se encuentra los casos de creacion de anticipos en un proyecto';
