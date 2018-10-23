-- Table: fenbolivar.bancos

-- DROP TABLE fenbolivar.bancos;

CREATE TABLE fenbolivar.bancos
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
ALTER TABLE fenbolivar.bancos
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.bancos.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenbolivar.bancos.bandes IS 'Nombre de Banco';
COMMENT ON COLUMN fenbolivar.bancos.banest IS 'Estado del banco';
COMMENT ON COLUMN fenbolivar.bancos.bancandigc IS 'Cantidad digitos cuenta';


