-- Table: fenalco.mreced

-- DROP TABLE fenalco.mreced;

CREATE TABLE fenalco.mreced
(
  mcecodrep numeric(2,0), -- Mot. Rep. Cedula
  mcedesrep text, -- Descripcion Motivo Reporte
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.mreced
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.mreced.mcecodrep IS 'Mot. Rep. Cedula';
COMMENT ON COLUMN fenalco.mreced.mcedesrep IS 'Descripcion Motivo Reporte';


