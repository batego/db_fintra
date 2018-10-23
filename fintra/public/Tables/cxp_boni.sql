-- Table: cxp_boni

-- DROP TABLE cxp_boni;

CREATE TABLE cxp_boni
(
  ms character varying(30) NOT NULL DEFAULT ''::character varying,
  doc character varying(30) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cxp_boni
  OWNER TO postgres;
GRANT ALL ON TABLE cxp_boni TO postgres;
GRANT SELECT ON TABLE cxp_boni TO msoto;

