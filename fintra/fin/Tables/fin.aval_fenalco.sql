-- Table: fin.aval_fenalco

-- DROP TABLE fin.aval_fenalco;

CREATE TABLE fin.aval_fenalco
(
  nit character varying(30) NOT NULL DEFAULT ''::character varying,
  nodoc real NOT NULL DEFAULT 0,
  tasach30 numeric(18,10) NOT NULL DEFAULT 0,
  tasach45 numeric(18,10) NOT NULL DEFAULT 0,
  tasalt30 numeric(18,10) NOT NULL DEFAULT 0,
  tasalt45 numeric(18,10) NOT NULL DEFAULT 0,
  tbcd numeric(10,0) NOT NULL DEFAULT 0,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.aval_fenalco
  OWNER TO postgres;

