-- Table: tablagen

-- DROP TABLE tablagen;

CREATE TABLE tablagen
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  table_type character varying(10) NOT NULL DEFAULT ''::character varying,
  table_code character varying(50) NOT NULL DEFAULT ''::character varying,
  referencia character varying(500) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  dato text NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  entidad character varying(100) NOT NULL DEFAULT ''::character varying,
  agencia character varying(100) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE tablagen
  OWNER TO postgres;
GRANT ALL ON TABLE tablagen TO postgres;
GRANT SELECT, INSERT ON TABLE tablagen TO blackberry;
GRANT SELECT ON TABLE tablagen TO msoto;

