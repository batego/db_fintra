-- Table: fenalco.fcuentas

-- DROP TABLE fenalco.fcuentas;

CREATE TABLE fenalco.fcuentas
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
ALTER TABLE fenalco.fcuentas
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.fcuentas.bancod IS 'Codigo de Banco ';
COMMENT ON COLUMN fenalco.fcuentas.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.fcuentas.cfinum IS 'Numero Cuenta Fichada';
COMMENT ON COLUMN fenalco.fcuentas.mcucodrep IS 'Mot. Rep. Cuenta';
COMMENT ON COLUMN fenalco.fcuentas.scccod IS 'Seccional';
COMMENT ON COLUMN fenalco.fcuentas.cfifecrep IS 'Fecha Reporte de la Cuenta';
COMMENT ON COLUMN fenalco.fcuentas.frecod IS 'Fuente Reporte';
COMMENT ON COLUMN fenalco.fcuentas.cfiest IS 'Estado';
COMMENT ON COLUMN fenalco.fcuentas.cfiacc IS 'Accion';
COMMENT ON COLUMN fenalco.fcuentas.cfifec IS 'Fecha';
COMMENT ON COLUMN fenalco.fcuentas.cfiusu IS 'Usuario';
COMMENT ON COLUMN fenalco.fcuentas.cfiobs IS 'Observaciones';


