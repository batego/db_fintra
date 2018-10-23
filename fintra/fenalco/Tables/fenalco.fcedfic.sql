-- Table: fenalco.fcedfic

-- DROP TABLE fenalco.fcedfic;

CREATE TABLE fenalco.fcedfic
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
ALTER TABLE fenalco.fcedfic
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.fcedfic.tipdoccod IS 'Tipo Documento';
COMMENT ON COLUMN fenalco.fcedfic.didnum IS 'Nro. Documento Identidad';
COMMENT ON COLUMN fenalco.fcedfic.mcecodrep IS 'Mot. Rep. Cedula';
COMMENT ON COLUMN fenalco.fcedfic.scccod IS 'Seccional';
COMMENT ON COLUMN fenalco.fcedfic.ceffecrep IS 'Fecha Reporte';
COMMENT ON COLUMN fenalco.fcedfic.frecod IS 'Fuente Reporte';
COMMENT ON COLUMN fenalco.fcedfic.cefest IS 'CefEst';
COMMENT ON COLUMN fenalco.fcedfic.mceacc IS 'Accion';
COMMENT ON COLUMN fenalco.fcedfic.mceusu IS 'Usuario';
COMMENT ON COLUMN fenalco.fcedfic.mcefec IS 'Fecha';
COMMENT ON COLUMN fenalco.fcedfic.mceobs IS 'Observaciones';


