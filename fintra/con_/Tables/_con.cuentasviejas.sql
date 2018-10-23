-- Table: con.cuentasviejas

-- DROP TABLE con.cuentasviejas;

CREATE TABLE con.cuentasviejas
(
  cuentax character varying(25) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.cuentasviejas
  OWNER TO postgres;
GRANT ALL ON TABLE con.cuentasviejas TO postgres;
GRANT SELECT ON TABLE con.cuentasviejas TO msoto;

