-- Table: log_acciones

-- DROP TABLE log_acciones;

CREATE TABLE log_acciones
(
  id numeric(30,0),
  username character varying(60),
  accion character varying(100),
  fecha timestamp without time zone DEFAULT '2004-07-06 14:57:37.39725'::timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE log_acciones
  OWNER TO postgres;
GRANT ALL ON TABLE log_acciones TO postgres;
GRANT SELECT ON TABLE log_acciones TO msoto;

