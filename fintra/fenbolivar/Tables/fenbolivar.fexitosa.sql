-- Table: fenbolivar.fexitosa

-- DROP TABLE fenbolivar.fexitosa;

CREATE TABLE fenbolivar.fexitosa
(
  tipdoccod numeric(2,0), -- Tipo Documento
  didnum numeric(11,0), -- Nro. Documento Identidad
  bancod numeric(2,0), -- Codigo de Banco
  succod numeric(4,0), -- Codigo de Sucursal
  exinumcun numeric(13,0), -- Numero de Cuenta  Exitosas
  exicancone numeric(10,0), -- Cantidad Consultas Exitosas
  exivlrcone numeric(12,0), -- Valor Consultas Exitosas
  exifecact timestamp without time zone, -- Fecha Ultima actualizacion
  exiindsinp text, -- Indicador  Siniestro en  Proceso
  exiacc text, -- Accion
  exifec timestamp without time zone, -- Fecha
  exiusu text, -- Usuario
  exitel1 numeric(11,0), -- ExiTel1
  exitel2 numeric(11,0), -- Telefono Exitosa dos
  exicanhis numeric(10,0), -- ExiCanHis
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.fexitosa
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.fexitosa.tipdoccod IS 'Tipo Documento';
COMMENT ON COLUMN fenbolivar.fexitosa.didnum IS 'Nro. Documento Identidad';
COMMENT ON COLUMN fenbolivar.fexitosa.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenbolivar.fexitosa.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenbolivar.fexitosa.exinumcun IS 'Numero de Cuenta  Exitosas';
COMMENT ON COLUMN fenbolivar.fexitosa.exicancone IS 'Cantidad Consultas Exitosas';
COMMENT ON COLUMN fenbolivar.fexitosa.exivlrcone IS 'Valor Consultas Exitosas';
COMMENT ON COLUMN fenbolivar.fexitosa.exifecact IS 'Fecha Ultima actualizacion';
COMMENT ON COLUMN fenbolivar.fexitosa.exiindsinp IS 'Indicador  Siniestro en  Proceso';
COMMENT ON COLUMN fenbolivar.fexitosa.exiacc IS 'Accion';
COMMENT ON COLUMN fenbolivar.fexitosa.exifec IS 'Fecha';
COMMENT ON COLUMN fenbolivar.fexitosa.exiusu IS 'Usuario';
COMMENT ON COLUMN fenbolivar.fexitosa.exitel1 IS 'ExiTel1';
COMMENT ON COLUMN fenbolivar.fexitosa.exitel2 IS 'Telefono Exitosa dos';
COMMENT ON COLUMN fenbolivar.fexitosa.exicanhis IS 'ExiCanHis';


