-- Table: con.cf_nm_2

-- DROP TABLE con.cf_nm_2;

CREATE TABLE con.cf_nm_2
(
  cf character varying(10),
  nm character varying(10),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.cf_nm_2
  OWNER TO postgres;
GRANT ALL ON TABLE con.cf_nm_2 TO postgres;
GRANT SELECT ON TABLE con.cf_nm_2 TO msoto;

