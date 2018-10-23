-- Table: fenalco.afimotr1

-- DROP TABLE fenalco.afimotr1;

CREATE TABLE fenalco.afimotr1
(
  aficodscc numeric(2,0), -- Codigo de la  seccional
  aficon numeric(6,0), -- Consecutivo Afiliado
  afinumsuc numeric(3,0), -- Numero Sucursal
  afinumctr numeric(6,0), -- Numero de Contrato
  sercod numeric(2,0), -- Codigo del tipo de servicio
  motcod text, -- Codigo Motivo Retiro
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.afimotr1
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.afimotr1.aficodscc IS 'Codigo de la  seccional';
COMMENT ON COLUMN fenalco.afimotr1.aficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenalco.afimotr1.afinumsuc IS 'Numero Sucursal';
COMMENT ON COLUMN fenalco.afimotr1.afinumctr IS 'Numero de Contrato';
COMMENT ON COLUMN fenalco.afimotr1.sercod IS 'Codigo del tipo de servicio';
COMMENT ON COLUMN fenalco.afimotr1.motcod IS 'Codigo Motivo Retiro';


