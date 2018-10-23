-- Table: fenbolivar.fchefic

-- DROP TABLE fenbolivar.fchefic;

CREATE TABLE fenbolivar.fchefic
(
  bancod numeric(2,0), -- Codigo de Banco
  chfnumini numeric(8,0), -- Numero inicial de Cheque
  scccod numeric(2,0), -- Seccional
  chfnumfin numeric(8,0), -- Numero Cheque Final
  succod numeric(4,0), -- Codigo de Sucursal
  chfnumcun numeric(13,0), -- Nro. Cuenta cheque fichado
  chffecrep timestamp without time zone, -- Fecha de Reporte del cheque
  mchcodrep numeric(2,0), -- Mot. Rep. Cheque
  frecod numeric(2,0), -- Fuente Reporte
  chfest text, -- Estado
  chfacc text, -- Accion
  chfusu text, -- Usuario
  chffec timestamp without time zone, -- Fecha
  chfobs text, -- Observaciones
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.fchefic
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.fchefic.bancod IS 'Codigo de Banco ';
COMMENT ON COLUMN fenbolivar.fchefic.chfnumini IS 'Numero inicial de Cheque';
COMMENT ON COLUMN fenbolivar.fchefic.scccod IS 'Seccional';
COMMENT ON COLUMN fenbolivar.fchefic.chfnumfin IS 'Numero Cheque Final';
COMMENT ON COLUMN fenbolivar.fchefic.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenbolivar.fchefic.chfnumcun IS 'Nro. Cuenta cheque fichado';
COMMENT ON COLUMN fenbolivar.fchefic.chffecrep IS 'Fecha de Reporte del cheque';
COMMENT ON COLUMN fenbolivar.fchefic.mchcodrep IS 'Mot. Rep. Cheque';
COMMENT ON COLUMN fenbolivar.fchefic.frecod IS 'Fuente Reporte';
COMMENT ON COLUMN fenbolivar.fchefic.chfest IS 'Estado';
COMMENT ON COLUMN fenbolivar.fchefic.chfacc IS 'Accion';
COMMENT ON COLUMN fenbolivar.fchefic.chfusu IS 'Usuario';
COMMENT ON COLUMN fenbolivar.fchefic.chffec IS 'Fecha';
COMMENT ON COLUMN fenbolivar.fchefic.chfobs IS 'Observaciones';


