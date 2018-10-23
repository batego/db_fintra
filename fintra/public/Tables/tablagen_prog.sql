-- Table: tablagen_prog

-- DROP TABLE tablagen_prog;

CREATE TABLE tablagen_prog
(
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(4) DEFAULT ''::character varying,
  table_type character varying(10) NOT NULL DEFAULT ''::character varying,
  table_code character varying(10) NOT NULL DEFAULT ''::character varying,
  program character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) DEFAULT ''::character varying,
  base character varying(3) DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE tablagen_prog
  OWNER TO postgres;
GRANT ALL ON TABLE tablagen_prog TO postgres;
GRANT SELECT ON TABLE tablagen_prog TO msoto;

