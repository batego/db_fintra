-- Table: fenalco.bancos

-- DROP TABLE fenalco.bancos;

CREATE TABLE fenalco.bancos
(
  bancod numeric(2,0), -- Codigo de Banco
  bandes text, -- Nombre de Banco
  banest text, -- Estado del banco
  bancandigc numeric(2,0), -- Cantidad digitos cuenta
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.bancos
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.bancos.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenalco.bancos.bandes IS 'Nombre de Banco';
COMMENT ON COLUMN fenalco.bancos.banest IS 'Estado del banco';
COMMENT ON COLUMN fenalco.bancos.bancandigc IS 'Cantidad digitos cuenta';


