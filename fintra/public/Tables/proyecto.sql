-- Table: proyecto

-- DROP TABLE proyecto;

CREATE TABLE proyecto
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  project character varying(10) NOT NULL DEFAULT ''::character varying,
  description character varying(15) NOT NULL DEFAULT ''::character varying,
  capture_code character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  texto_oc text,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE proyecto
  OWNER TO postgres;
GRANT ALL ON TABLE proyecto TO postgres;
GRANT SELECT ON TABLE proyecto TO msoto;

