-- Table: fenbolivar.afimotre

-- DROP TABLE fenbolivar.afimotre;

CREATE TABLE fenbolivar.afimotre
(
  aficodscc numeric(2,0), -- Codigo de la  seccional
  aficon numeric(6,0), -- Consecutivo Afiliado
  afinumsuc numeric(3,0), -- Numero Sucursal
  afinumctr numeric(6,0), -- Numero de Contrato
  sercod numeric(2,0), -- Codigo del tipo de  servicio
  serfecret timestamp without time zone, -- Fecha de Retiro
  serusucod text, -- Codigo del usuario
  seracc text, -- Accion ejecutada
  serfec timestamp without time zone, -- Fecha de actualizacion
  serindsan text, -- Indicador de Sancion
  serfecvig text, -- Vigencia del contrato
  sernomaut1 text, -- Nombre Autorizado
  sernomaut2 text, -- Nombre Autorizado
  polnum text, -- Numero de Poliza
  polcat text, -- Categor¡a de la  Poliza
  polcob numeric(8,0), -- Cobertura de Poliza
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.afimotre
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.afimotre.aficodscc IS 'Codigo de la  seccional';
COMMENT ON COLUMN fenbolivar.afimotre.aficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenbolivar.afimotre.afinumsuc IS 'Numero Sucursal';
COMMENT ON COLUMN fenbolivar.afimotre.afinumctr IS 'Numero de Contrato';
COMMENT ON COLUMN fenbolivar.afimotre.sercod IS 'Codigo del tipo de  servicio';
COMMENT ON COLUMN fenbolivar.afimotre.serfecret IS 'Fecha de Retiro';
COMMENT ON COLUMN fenbolivar.afimotre.serusucod IS 'Codigo del usuario';
COMMENT ON COLUMN fenbolivar.afimotre.seracc IS 'Accion ejecutada';
COMMENT ON COLUMN fenbolivar.afimotre.serfec IS 'Fecha de actualizacion';
COMMENT ON COLUMN fenbolivar.afimotre.serindsan IS 'Indicador de Sancion';
COMMENT ON COLUMN fenbolivar.afimotre.serfecvig IS 'Vigencia del contrato';
COMMENT ON COLUMN fenbolivar.afimotre.sernomaut1 IS 'Nombre Autorizado';
COMMENT ON COLUMN fenbolivar.afimotre.sernomaut2 IS 'Nombre Autorizado';
COMMENT ON COLUMN fenbolivar.afimotre.polnum IS 'Numero de Poliza';
COMMENT ON COLUMN fenbolivar.afimotre.polcat IS 'Categor¡a de la  Poliza';
COMMENT ON COLUMN fenbolivar.afimotre.polcob IS 'Cobertura de Poliza';


