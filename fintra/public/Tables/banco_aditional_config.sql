-- Table: banco_aditional_config

-- DROP TABLE banco_aditional_config;

CREATE TABLE banco_aditional_config
(
  id serial NOT NULL,
  branch_code character varying(15) NOT NULL,
  nit_bank character varying(15) NOT NULL DEFAULT ''::character varying,
  bank_account_no character varying(30) NOT NULL,
  hc character varying(15) NOT NULL,
  account_number character varying(30) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE banco_aditional_config
  OWNER TO postgres;
GRANT ALL ON TABLE banco_aditional_config TO postgres;
GRANT SELECT ON TABLE banco_aditional_config TO msoto;

