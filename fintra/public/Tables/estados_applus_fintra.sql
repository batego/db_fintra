-- Table: estados_applus_fintra

-- DROP TABLE estados_applus_fintra;

CREATE TABLE estados_applus_fintra
(
  estado character varying(30) DEFAULT ''::character varying,
  colocador_de_estado character varying(15) DEFAULT ''::character varying,
  momento character varying(4) DEFAULT ''::character varying,
  codigo serial NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE estados_applus_fintra
  OWNER TO postgres;
GRANT ALL ON TABLE estados_applus_fintra TO postgres;
GRANT SELECT ON TABLE estados_applus_fintra TO msoto;

