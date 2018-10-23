-- Table: str_fecha

-- DROP TABLE str_fecha;

CREATE TABLE str_fecha
(
  to_char text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE str_fecha
  OWNER TO postgres;
GRANT ALL ON TABLE str_fecha TO postgres;
GRANT SELECT ON TABLE str_fecha TO msoto;

