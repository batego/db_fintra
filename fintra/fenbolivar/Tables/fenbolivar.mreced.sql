-- Table: fenbolivar.mreced

-- DROP TABLE fenbolivar.mreced;

CREATE TABLE fenbolivar.mreced
(
  mcecodrep numeric(2,0), -- Mot. Rep. Cedula
  mcedesrep text, -- Descripcion Motivo Reporte
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.mreced
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.mreced.mcecodrep IS 'Mot. Rep. Cedula';
COMMENT ON COLUMN fenbolivar.mreced.mcedesrep IS 'Descripcion Motivo Reporte';


