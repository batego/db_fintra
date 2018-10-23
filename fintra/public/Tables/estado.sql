-- Table: estado

-- DROP TABLE estado;

CREATE TABLE estado
(
  department_code character varying(3) NOT NULL DEFAULT ''::character varying,
  department_name character varying(40) NOT NULL DEFAULT ''::character varying,
  country_code character varying(3) NOT NULL DEFAULT ''::character varying,
  zona character varying(5) NOT NULL DEFAULT ''::character varying,
  rec_status character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE estado
  OWNER TO postgres;
GRANT ALL ON TABLE estado TO postgres;
GRANT SELECT ON TABLE estado TO msoto;

