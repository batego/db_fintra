-- Table: log_sot

-- DROP TABLE log_sot;

CREATE TABLE log_sot
(
  tituloerror character varying(30) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::text,
  fechaevento timestamp without time zone DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE log_sot
  OWNER TO postgres;
GRANT ALL ON TABLE log_sot TO postgres;
GRANT SELECT ON TABLE log_sot TO msoto;

