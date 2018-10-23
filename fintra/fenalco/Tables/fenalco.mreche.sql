-- Table: fenalco.mreche

-- DROP TABLE fenalco.mreche;

CREATE TABLE fenalco.mreche
(
  mchcodrep numeric(2,0), -- Mot. Rep. Cheque
  mchdesrep text, -- Descripcion Reporte Cheque
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.mreche
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.mreche.mchcodrep IS 'Mot. Rep. Cheque';
COMMENT ON COLUMN fenalco.mreche.mchdesrep IS 'Descripcion Reporte Cheque';


