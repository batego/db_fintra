-- Table: fenbolivar.afiser

-- DROP TABLE fenbolivar.afiser;

CREATE TABLE fenbolivar.afiser
(
  aficodscc numeric(2,0), -- Codigo de la  seccional
  aficon numeric(6,0), -- Consecutivo Afiliado
  afinumsuc numeric(3,0), -- Numero Sucursal
  afinumctr numeric(6,0), -- Numero de Contrato
  sercod numeric(2,0), -- Codigo del tipo de  servicio
  prdcod numeric(2,0), -- Codigo del producto
  subprdult numeric(2,0), -- Ultimo valor del  subproducto
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.afiser
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.afiser.aficodscc IS 'Codigo de la  seccional';
COMMENT ON COLUMN fenbolivar.afiser.aficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenbolivar.afiser.afinumsuc IS 'Numero Sucursal';
COMMENT ON COLUMN fenbolivar.afiser.afinumctr IS 'Numero de Contrato';
COMMENT ON COLUMN fenbolivar.afiser.sercod IS 'Codigo del tipo de  servicio';
COMMENT ON COLUMN fenbolivar.afiser.prdcod IS 'Codigo del producto';
COMMENT ON COLUMN fenbolivar.afiser.subprdult IS 'Ultimo valor del  subproducto';


