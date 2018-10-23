-- Table: fenbolivar.fcuentas

-- DROP TABLE fenbolivar.fcuentas;

CREATE TABLE fenbolivar.fcuentas
(
  bancod numeric(2,0), -- Codigo de Banco
  succod numeric(4,0), -- Codigo de Sucursal
  cfinum numeric(13,0), -- Numero Cuenta Fichada
  mcucodrep numeric(2,0), -- Mot. Rep. Cuenta
  scccod numeric(2,0), -- Seccional
  cfifecrep timestamp without time zone, -- Fecha Reporte de la Cuenta
  frecod numeric(2,0), -- Fuente Reporte
  cfiest text, -- Estado
  cfiacc text, -- Accion
  cfifec timestamp without time zone, -- Fecha
  cfiusu text, -- Usuario
  cfiobs text, -- Observaciones
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.fcuentas
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.fcuentas.bancod IS 'Codigo de Banco ';
COMMENT ON COLUMN fenbolivar.fcuentas.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenbolivar.fcuentas.cfinum IS 'Numero Cuenta Fichada';
COMMENT ON COLUMN fenbolivar.fcuentas.mcucodrep IS 'Mot. Rep. Cuenta';
COMMENT ON COLUMN fenbolivar.fcuentas.scccod IS 'Seccional';
COMMENT ON COLUMN fenbolivar.fcuentas.cfifecrep IS 'Fecha Reporte de la Cuenta';
COMMENT ON COLUMN fenbolivar.fcuentas.frecod IS 'Fuente Reporte';
COMMENT ON COLUMN fenbolivar.fcuentas.cfiest IS 'Estado';
COMMENT ON COLUMN fenbolivar.fcuentas.cfiacc IS 'Accion';
COMMENT ON COLUMN fenbolivar.fcuentas.cfifec IS 'Fecha';
COMMENT ON COLUMN fenbolivar.fcuentas.cfiusu IS 'Usuario';
COMMENT ON COLUMN fenbolivar.fcuentas.cfiobs IS 'Observaciones';


