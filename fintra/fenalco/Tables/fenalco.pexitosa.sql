-- Table: fenalco.pexitosa

-- DROP TABLE fenalco.pexitosa;

CREATE TABLE fenalco.pexitosa
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
ALTER TABLE fenalco.pexitosa
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.pexitosa.tipdoccod IS 'Tipo Documento';
COMMENT ON COLUMN fenalco.pexitosa.didnum IS 'Nro. Documento Identidad';
COMMENT ON COLUMN fenalco.pexitosa.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenalco.pexitosa.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.pexitosa.pexnumcun IS 'Numero de Cuenta  Exitosas';
COMMENT ON COLUMN fenalco.pexitosa.pexcancone IS 'Cantidad Consultas Exitosas';
COMMENT ON COLUMN fenalco.pexitosa.pexvlrcone IS 'Valor Consultas Exitosas postf';
COMMENT ON COLUMN fenalco.pexitosa.pexfecact IS 'Fecha Ultima actualizacion';
COMMENT ON COLUMN fenalco.pexitosa.pexindsinp IS 'Indicador  Siniestro en  Proceso PExIndSinP ';
COMMENT ON COLUMN fenalco.pexitosa.pexusu IS 'Usuario';
COMMENT ON COLUMN fenalco.pexitosa.pexacc IS 'Accion';
COMMENT ON COLUMN fenalco.pexitosa.pexfec IS 'Fecha';
COMMENT ON COLUMN fenalco.pexitosa.pexitel1 IS 'Telefono uno exitosa';
COMMENT ON COLUMN fenalco.pexitosa.pexitel2 IS 'Telefono dos exitosa';
COMMENT ON COLUMN fenalco.pexitosa.pexcanhis IS 'PExCanHis';


