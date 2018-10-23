-- Table: tbldoc

-- DROP TABLE tbldoc;

CREATE TABLE tbldoc
(
  reg_status character(1) NOT NULL DEFAULT ''::bpchar,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  document_type character varying(15) NOT NULL DEFAULT ''::character varying,
  document_name text NOT NULL DEFAULT ''::character varying,
  banco character(1) NOT NULL DEFAULT 'S'::bpchar,
  ref_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  sigla character varying(6) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tbldoc
  OWNER TO postgres;
GRANT ALL ON TABLE tbldoc TO postgres;
GRANT SELECT ON TABLE tbldoc TO msoto;

