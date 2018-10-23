-- Table: opav.interventor_dpto

-- DROP TABLE opav.interventor_dpto;

CREATE TABLE opav.interventor_dpto
(
  idinterdepto serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  country_code character varying(3) NOT NULL DEFAULT ''::character varying,
  departamento character varying(3) NOT NULL DEFAULT ''::character varying,
  interventor character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.interventor_dpto
  OWNER TO postgres;
