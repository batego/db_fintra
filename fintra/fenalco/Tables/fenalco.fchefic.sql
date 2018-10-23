-- Table: fenalco.fchefic

-- DROP TABLE fenalco.fchefic;

CREATE TABLE fenalco.fchefic
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
ALTER TABLE fenalco.fchefic
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.fchefic.bancod IS 'Codigo de Banco ';
COMMENT ON COLUMN fenalco.fchefic.chfnumini IS 'Numero inicial de Cheque';
COMMENT ON COLUMN fenalco.fchefic.scccod IS 'Seccional';
COMMENT ON COLUMN fenalco.fchefic.chfnumfin IS 'Numero Cheque Final';
COMMENT ON COLUMN fenalco.fchefic.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.fchefic.chfnumcun IS 'Nro. Cuenta cheque fichado';
COMMENT ON COLUMN fenalco.fchefic.chffecrep IS 'Fecha de Reporte del cheque';
COMMENT ON COLUMN fenalco.fchefic.mchcodrep IS 'Mot. Rep. Cheque';
COMMENT ON COLUMN fenalco.fchefic.frecod IS 'Fuente Reporte';
COMMENT ON COLUMN fenalco.fchefic.chfest IS 'Estado';
COMMENT ON COLUMN fenalco.fchefic.chfacc IS 'Accion';
COMMENT ON COLUMN fenalco.fchefic.chfusu IS 'Usuario';
COMMENT ON COLUMN fenalco.fchefic.chffec IS 'Fecha';
COMMENT ON COLUMN fenalco.fchefic.chfobs IS 'Observaciones';


