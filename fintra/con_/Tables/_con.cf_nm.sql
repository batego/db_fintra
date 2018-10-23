-- Table: con.cf_nm

-- DROP TABLE con.cf_nm;

CREATE TABLE con.cf_nm
(
  cf character varying(10),
  nm character varying(10),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.cf_nm
  OWNER TO web;
GRANT ALL ON TABLE con.cf_nm TO web;
GRANT SELECT ON TABLE con.cf_nm TO msoto;

-- Index: con.cf_nm_x1

-- DROP INDEX con.cf_nm_x1;

CREATE INDEX cf_nm_x1
  ON con.cf_nm
  USING btree
  (nm);


