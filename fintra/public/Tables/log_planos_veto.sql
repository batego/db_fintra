-- Table: log_planos_veto

-- DROP TABLE log_planos_veto;

CREATE TABLE log_planos_veto
(
  archivo text,
  dir text,
  usuario character varying(12),
  estado character varying(1) DEFAULT '0'::character varying,
  fecha timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE log_planos_veto
  OWNER TO postgres;
GRANT ALL ON TABLE log_planos_veto TO postgres;
GRANT SELECT ON TABLE log_planos_veto TO msoto;

