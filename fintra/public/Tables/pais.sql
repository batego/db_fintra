-- Table: pais

-- DROP TABLE pais;

CREATE TABLE pais
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  country_code character varying(2) NOT NULL DEFAULT ''::character varying,
  country_name character varying(40) NOT NULL DEFAULT ''::character varying,
  country character varying(2) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE pais
  OWNER TO postgres;
GRANT ALL ON TABLE pais TO postgres;
GRANT SELECT ON TABLE pais TO msoto;

