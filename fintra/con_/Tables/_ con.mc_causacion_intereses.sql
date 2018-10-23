-- Table: con.mc_causacion_intereses

-- DROP TABLE con.mc_causacion_intereses;

CREATE TABLE con.mc_causacion_intereses
(
  cod character varying(15) NOT NULL DEFAULT ''::character varying,
  codneg character varying(10) NOT NULL DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.mc_causacion_intereses
  OWNER TO postgres;

