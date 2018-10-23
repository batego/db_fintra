-- Table: log_conexiones_carbon

-- DROP TABLE log_conexiones_carbon;

CREATE TABLE log_conexiones_carbon
(
  reg_status character varying(1) DEFAULT ''::character varying,
  observacion text DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE log_conexiones_carbon
  OWNER TO postgres;
GRANT ALL ON TABLE log_conexiones_carbon TO postgres;
GRANT SELECT ON TABLE log_conexiones_carbon TO msoto;

