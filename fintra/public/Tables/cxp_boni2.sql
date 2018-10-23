-- Table: cxp_boni2

-- DROP TABLE cxp_boni2;

CREATE TABLE cxp_boni2
(
  id_accion character varying(30) NOT NULL DEFAULT ''::character varying,
  doc character varying(30) DEFAULT ''::character varying,
  ms character varying(30) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cxp_boni2
  OWNER TO postgres;
GRANT ALL ON TABLE cxp_boni2 TO postgres;
GRANT SELECT ON TABLE cxp_boni2 TO msoto;

