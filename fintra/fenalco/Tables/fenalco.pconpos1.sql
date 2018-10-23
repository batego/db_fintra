-- Table: fenalco.pconpos1

-- DROP TABLE fenalco.pconpos1;

CREATE TABLE fenalco.pconpos1
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
ALTER TABLE fenalco.pconpos1
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.pconpos1.poscon IS 'Numero Negocio';
COMMENT ON COLUMN fenalco.pconpos1.poscanlin IS 'Nro Cheque';
COMMENT ON COLUMN fenalco.pconpos1.posnumche IS 'Nro. Cheque';
COMMENT ON COLUMN fenalco.pconpos1.posvalche IS 'Valor Cheque';
COMMENT ON COLUMN fenalco.pconpos1.posfeccon IS 'Fecha Consignacion';
COMMENT ON COLUMN fenalco.pconpos1.posusu IS 'Usuario';
COMMENT ON COLUMN fenalco.pconpos1.posfecu IS 'Fecha';
COMMENT ON COLUMN fenalco.pconpos1.posacc IS 'Accion';
COMMENT ON COLUMN fenalco.pconpos1.posapb IS 'Indicador de  Aprobacion cheque';


-- Index: fenalco.consecutivo_negocio

-- DROP INDEX fenalco.consecutivo_negocio;

CREATE INDEX consecutivo_negocio
  ON fenalco.pconpos1
  USING btree
  (poscon);


