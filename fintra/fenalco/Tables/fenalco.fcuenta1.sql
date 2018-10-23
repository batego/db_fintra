-- Table: fenalco.fcuenta1

-- DROP TABLE fenalco.fcuenta1;

CREATE TABLE fenalco.fcuenta1
(
  bancod numeric(2,0), -- Codigo de Banco
  succod numeric(4,0), -- Codigo de Sucursal
  cfinum numeric(13,0), -- Numero Cuenta Fichada
  mcucodrep numeric(2,0), -- Mot. Rep. Cuenta
  scccod numeric(2,0), -- Seccional
  tipdoccod numeric(2,0), -- Tipo Documento
  didnum numeric(11,0), -- Nro. Documento Identidad
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.fcuenta1
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.fcuenta1.bancod IS 'Codigo de Banco ';
COMMENT ON COLUMN fenalco.fcuenta1.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.fcuenta1.cfinum IS 'Numero Cuenta Fichada';
COMMENT ON COLUMN fenalco.fcuenta1.mcucodrep IS 'Mot. Rep. Cuenta';
COMMENT ON COLUMN fenalco.fcuenta1.scccod IS 'Seccional';
COMMENT ON COLUMN fenalco.fcuenta1.tipdoccod IS 'Tipo Documento';
COMMENT ON COLUMN fenalco.fcuenta1.didnum IS 'Nro. Documento Identidad';


