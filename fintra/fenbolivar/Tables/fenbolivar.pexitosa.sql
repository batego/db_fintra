-- Table: fenbolivar.pexitosa

-- DROP TABLE fenbolivar.pexitosa;

CREATE TABLE fenbolivar.pexitosa
(
  tipdoccod numeric(2,0), -- Tipo Documento
  didnum numeric(11,0), -- Nro. Documento Identidad
  bancod numeric(2,0), -- Codigo de Banco
  succod numeric(4,0), -- Codigo de Sucursal
  pexnumcun numeric(13,0), -- Numero de Cuenta  Exitosas
  pexcancone numeric(10,0), -- Cantidad Consultas Exitosas
  pexvlrcone numeric(12,0), -- Valor Consultas Exitosas postf
  pexfecact timestamp without time zone, -- Fecha Ultima actualizacion
  pexindsinp text, -- Indicador  Siniestro en  Proceso PExIndSinP
  pexusu text, -- Usuario
  pexacc text, -- Accion
  pexfec timestamp without time zone, -- Fecha
  pexitel1 numeric(11,0), -- Telefono uno exitosa
  pexitel2 numeric(11,0), -- Telefono dos exitosa
  pexcanhis numeric(10,0), -- PExCanHis
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.pexitosa
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.pexitosa.tipdoccod IS 'Tipo Documento';
COMMENT ON COLUMN fenbolivar.pexitosa.didnum IS 'Nro. Documento Identidad';
COMMENT ON COLUMN fenbolivar.pexitosa.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenbolivar.pexitosa.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenbolivar.pexitosa.pexnumcun IS 'Numero de Cuenta  Exitosas';
COMMENT ON COLUMN fenbolivar.pexitosa.pexcancone IS 'Cantidad Consultas Exitosas';
COMMENT ON COLUMN fenbolivar.pexitosa.pexvlrcone IS 'Valor Consultas Exitosas postf';
COMMENT ON COLUMN fenbolivar.pexitosa.pexfecact IS 'Fecha Ultima actualizacion';
COMMENT ON COLUMN fenbolivar.pexitosa.pexindsinp IS 'Indicador  Siniestro en  Proceso PExIndSinP ';
COMMENT ON COLUMN fenbolivar.pexitosa.pexusu IS 'Usuario';
COMMENT ON COLUMN fenbolivar.pexitosa.pexacc IS 'Accion';
COMMENT ON COLUMN fenbolivar.pexitosa.pexfec IS 'Fecha';
COMMENT ON COLUMN fenbolivar.pexitosa.pexitel1 IS 'Telefono uno exitosa';
COMMENT ON COLUMN fenbolivar.pexitosa.pexitel2 IS 'Telefono dos exitosa';
COMMENT ON COLUMN fenbolivar.pexitosa.pexcanhis IS 'PExCanHis';


