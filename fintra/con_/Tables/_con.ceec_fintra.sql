-- Table: con.ceec_fintra

-- DROP TABLE con.ceec_fintra;

CREATE TABLE con.ceec_fintra
(
  ceec character varying(30),
  cf character varying,
  nm character varying,
  pm character varying,
  vlr_ceec numeric,
  creation_date timestamp without time zone DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.ceec_fintra
  OWNER TO web;
GRANT ALL ON TABLE con.ceec_fintra TO web;
GRANT SELECT ON TABLE con.ceec_fintra TO msoto;

-- Index: con.ceec_fintra_x1

-- DROP INDEX con.ceec_fintra_x1;

CREATE INDEX ceec_fintra_x1
  ON con.ceec_fintra
  USING btree
  (ceec);

-- Index: con.ceec_fintra_x2

-- DROP INDEX con.ceec_fintra_x2;

CREATE INDEX ceec_fintra_x2
  ON con.ceec_fintra
  USING btree
  (cf);

-- Index: con.ceec_fintra_x3

-- DROP INDEX con.ceec_fintra_x3;

CREATE INDEX ceec_fintra_x3
  ON con.ceec_fintra
  USING btree
  (nm);

-- Index: con.ceec_fintra_x4

-- DROP INDEX con.ceec_fintra_x4;

CREATE INDEX ceec_fintra_x4
  ON con.ceec_fintra
  USING btree
  (pm);


