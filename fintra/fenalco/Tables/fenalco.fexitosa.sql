-- Table: fenalco.fexitosa

-- DROP TABLE fenalco.fexitosa;

CREATE TABLE fenalco.fexitosa
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
ALTER TABLE fenalco.fexitosa
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.fexitosa.tipdoccod IS 'Tipo Documento';
COMMENT ON COLUMN fenalco.fexitosa.didnum IS 'Nro. Documento Identidad';
COMMENT ON COLUMN fenalco.fexitosa.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenalco.fexitosa.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.fexitosa.exinumcun IS 'Numero de Cuenta  Exitosas';
COMMENT ON COLUMN fenalco.fexitosa.exicancone IS 'Cantidad Consultas Exitosas';
COMMENT ON COLUMN fenalco.fexitosa.exivlrcone IS 'Valor Consultas Exitosas';
COMMENT ON COLUMN fenalco.fexitosa.exifecact IS 'Fecha Ultima actualizacion';
COMMENT ON COLUMN fenalco.fexitosa.exiindsinp IS 'Indicador  Siniestro en  Proceso';
COMMENT ON COLUMN fenalco.fexitosa.exiacc IS 'Accion';
COMMENT ON COLUMN fenalco.fexitosa.exifec IS 'Fecha';
COMMENT ON COLUMN fenalco.fexitosa.exiusu IS 'Usuario';
COMMENT ON COLUMN fenalco.fexitosa.exitel1 IS 'ExiTel1';
COMMENT ON COLUMN fenalco.fexitosa.exitel2 IS 'Telefono Exitosa dos';
COMMENT ON COLUMN fenalco.fexitosa.exicanhis IS 'ExiCanHis';


