-- Table: log_despachos

-- DROP TABLE log_despachos;

CREATE TABLE log_despachos
(
  username character varying(60),
  accion character varying(100),
  resultado character varying(600),
  placa character varying(30),
  cedula character varying(30),
  fecha timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  respuesta character varying(1),
  no_autorizacion text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE log_despachos
  OWNER TO postgres;
GRANT ALL ON TABLE log_despachos TO postgres;
GRANT SELECT ON TABLE log_despachos TO msoto;

