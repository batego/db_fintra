-- Table: anexos_negocios

-- DROP TABLE anexos_negocios;

CREATE TABLE anexos_negocios
(
  no_solicitud numeric NOT NULL,
  ciclo numeric NOT NULL,
  codneg character varying NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE anexos_negocios
  OWNER TO postgres;
GRANT ALL ON TABLE anexos_negocios TO postgres;
GRANT SELECT ON TABLE anexos_negocios TO msoto;

