-- Table: fenbolivar.pconpos1

-- DROP TABLE fenbolivar.pconpos1;

CREATE TABLE fenbolivar.pconpos1
(
  poscon numeric(8,0), -- Numero Negocio
  poscanlin numeric(8,0), -- Nro Cheque
  posnumche numeric(8,0), -- Nro. Cheque
  posvalche numeric(9,0), -- Valor Cheque
  posfeccon timestamp without time zone, -- Fecha Consignacion
  posusu text, -- Usuario
  posfecu timestamp without time zone, -- Fecha
  posacc text, -- Accion
  posapb text, -- Indicador de  Aprobacion cheque
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.pconpos1
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.pconpos1.poscon IS 'Numero Negocio';
COMMENT ON COLUMN fenbolivar.pconpos1.poscanlin IS 'Nro Cheque';
COMMENT ON COLUMN fenbolivar.pconpos1.posnumche IS 'Nro. Cheque';
COMMENT ON COLUMN fenbolivar.pconpos1.posvalche IS 'Valor Cheque';
COMMENT ON COLUMN fenbolivar.pconpos1.posfeccon IS 'Fecha Consignacion';
COMMENT ON COLUMN fenbolivar.pconpos1.posusu IS 'Usuario';
COMMENT ON COLUMN fenbolivar.pconpos1.posfecu IS 'Fecha';
COMMENT ON COLUMN fenbolivar.pconpos1.posacc IS 'Accion';
COMMENT ON COLUMN fenbolivar.pconpos1.posapb IS 'Indicador de  Aprobacion cheque';


-- Index: fenbolivar.consecutivo_negociofb

-- DROP INDEX fenbolivar.consecutivo_negociofb;

CREATE INDEX consecutivo_negociofb
  ON fenbolivar.pconpos1
  USING btree
  (poscon);


