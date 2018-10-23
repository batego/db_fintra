-- Table: con.ec_nm

-- DROP TABLE con.ec_nm;

CREATE TABLE con.ec_nm
(
  documento character varying(30),
  nm text,
  vlr_ec moneda,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.ec_nm
  OWNER TO web;
GRANT ALL ON TABLE con.ec_nm TO web;
GRANT SELECT ON TABLE con.ec_nm TO msoto;

