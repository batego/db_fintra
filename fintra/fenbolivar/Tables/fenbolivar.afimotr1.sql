-- Table: fenbolivar.afimotr1

-- DROP TABLE fenbolivar.afimotr1;

CREATE TABLE fenbolivar.afimotr1
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
ALTER TABLE fenbolivar.afimotr1
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.afimotr1.aficodscc IS 'Codigo de la  seccional';
COMMENT ON COLUMN fenbolivar.afimotr1.aficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenbolivar.afimotr1.afinumsuc IS 'Numero Sucursal';
COMMENT ON COLUMN fenbolivar.afimotr1.afinumctr IS 'Numero de Contrato';
COMMENT ON COLUMN fenbolivar.afimotr1.sercod IS 'Codigo del tipo de servicio';
COMMENT ON COLUMN fenbolivar.afimotr1.motcod IS 'Codigo Motivo Retiro';


