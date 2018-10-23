-- Table: fenbolivar.mreche

-- DROP TABLE fenbolivar.mreche;

CREATE TABLE fenbolivar.mreche
(
  mchcodrep numeric(2,0), -- Mot. Rep. Cheque
  mchdesrep text, -- Descripcion Reporte Cheque
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.mreche
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.mreche.mchcodrep IS 'Mot. Rep. Cheque';
COMMENT ON COLUMN fenbolivar.mreche.mchdesrep IS 'Descripcion Reporte Cheque';


