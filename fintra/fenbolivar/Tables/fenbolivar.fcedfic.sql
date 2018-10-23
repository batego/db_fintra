-- Table: fenbolivar.fcedfic

-- DROP TABLE fenbolivar.fcedfic;

CREATE TABLE fenbolivar.fcedfic
(
  tipdoccod numeric(2,0), -- Tipo Documento
  didnum numeric(11,0), -- Nro. Documento Identidad
  mcecodrep numeric(2,0), -- Mot. Rep. Cedula
  scccod numeric(2,0), -- Seccional
  ceffecrep timestamp without time zone, -- Fecha Reporte
  frecod numeric(2,0), -- Fuente Reporte
  cefest text, -- CefEst
  mceacc text, -- Accion
  mceusu text, -- Usuario
  mcefec timestamp without time zone, -- Fecha
  mceobs text, -- Observaciones
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.fcedfic
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.fcedfic.tipdoccod IS 'Tipo Documento';
COMMENT ON COLUMN fenbolivar.fcedfic.didnum IS 'Nro. Documento Identidad';
COMMENT ON COLUMN fenbolivar.fcedfic.mcecodrep IS 'Mot. Rep. Cedula';
COMMENT ON COLUMN fenbolivar.fcedfic.scccod IS 'Seccional';
COMMENT ON COLUMN fenbolivar.fcedfic.ceffecrep IS 'Fecha Reporte';
COMMENT ON COLUMN fenbolivar.fcedfic.frecod IS 'Fuente Reporte';
COMMENT ON COLUMN fenbolivar.fcedfic.cefest IS 'CefEst';
COMMENT ON COLUMN fenbolivar.fcedfic.mceacc IS 'Accion';
COMMENT ON COLUMN fenbolivar.fcedfic.mceusu IS 'Usuario';
COMMENT ON COLUMN fenbolivar.fcedfic.mcefec IS 'Fecha';
COMMENT ON COLUMN fenbolivar.fcedfic.mceobs IS 'Observaciones';


