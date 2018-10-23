-- Table: fenalco.ftelefon

-- DROP TABLE fenalco.ftelefon;

CREATE TABLE fenalco.ftelefon
(
  tfinum numeric(11,0), -- Numero Telefono Fichado
  mtecodrep numeric(2,0), -- Mot. Rep. Telefono
  scccod numeric(2,0), -- Seccional
  frecod numeric(2,0), -- Fuente Reporte
  tfifecrep timestamp without time zone, -- Fecha Reporte del  Telefono
  tficodtipd numeric(2,0), -- Tipo Documento Id
  tfinumdid numeric(11,0), -- Nro. Doc. Id.
  tfiest text, -- Estado
  tfiusu text, -- Usuario
  tfifec timestamp without time zone, -- Fecha
  tfiacc text, -- Accion
  tfiobs text, -- Observaciones
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.ftelefon
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.ftelefon.tfinum IS 'Numero Telefono Fichado';
COMMENT ON COLUMN fenalco.ftelefon.mtecodrep IS 'Mot. Rep. Telefono';
COMMENT ON COLUMN fenalco.ftelefon.scccod IS 'Seccional';
COMMENT ON COLUMN fenalco.ftelefon.frecod IS 'Fuente Reporte';
COMMENT ON COLUMN fenalco.ftelefon.tfifecrep IS 'Fecha Reporte del  Telefono';
COMMENT ON COLUMN fenalco.ftelefon.tficodtipd IS 'Tipo Documento Id';
COMMENT ON COLUMN fenalco.ftelefon.tfinumdid IS 'Nro. Doc. Id.';
COMMENT ON COLUMN fenalco.ftelefon.tfiest IS 'Estado';
COMMENT ON COLUMN fenalco.ftelefon.tfiusu IS 'Usuario';
COMMENT ON COLUMN fenalco.ftelefon.tfifec IS 'Fecha';
COMMENT ON COLUMN fenalco.ftelefon.tfiacc IS 'Accion ';
COMMENT ON COLUMN fenalco.ftelefon.tfiobs IS 'Observaciones';


