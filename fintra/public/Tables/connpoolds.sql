-- Table: connpoolds

-- DROP TABLE connpoolds;

CREATE TABLE connpoolds
(
  dummydata character(1) NOT NULL DEFAULT ''::bpchar,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE connpoolds
  OWNER TO postgres;
GRANT ALL ON TABLE connpoolds TO postgres;
GRANT SELECT ON TABLE connpoolds TO msoto;
COMMENT ON TABLE connpoolds
  IS 'Tabla para verificar si las conexiones contenidas dentro de un pool estan "vivas".';

