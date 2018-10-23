-- Table: con.homologa_terceros

-- DROP TABLE con.homologa_terceros;

CREATE TABLE con.homologa_terceros
(
  nit_fintra character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_apoteosys character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre character varying(100) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.homologa_terceros
  OWNER TO postgres;

