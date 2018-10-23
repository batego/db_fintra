-- Table: con.elemento_puc

-- DROP TABLE con.elemento_puc;

CREATE TABLE con.elemento_puc
(
  elemento character varying(5) NOT NULL DEFAULT ''::character varying,
  puc character varying(25) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.elemento_puc
  OWNER TO postgres;
GRANT ALL ON TABLE con.elemento_puc TO postgres;
GRANT SELECT ON TABLE con.elemento_puc TO msoto;

