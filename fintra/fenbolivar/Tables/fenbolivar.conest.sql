-- Table: fenbolivar.conest

-- DROP TABLE fenbolivar.conest;

CREATE TABLE fenbolivar.conest
(
  estdoccod numeric(2,0), -- Tipo Documento Estudiante
  estdidnum numeric(11,0), -- Nro. Documento Estudiante
  poscon numeric(8,0), -- Numero Negocio
  cenoprea numeric(8,0), -- Nro. PreAprobado
  cecodest numeric(15,0), -- Codigo Estudiante
  cecoduni numeric(3,0), -- Codigo Universidad
  cenomuni text, -- Nombre Universidad
  cenomcar text, -- Nombre Carrera
  cenrosem numeric(2,0), -- Nro. Semestre
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.conest
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.conest.estdoccod IS 'Tipo Documento Estudiante';
COMMENT ON COLUMN fenbolivar.conest.estdidnum IS 'Nro. Documento Estudiante';
COMMENT ON COLUMN fenbolivar.conest.poscon IS 'Numero Negocio';
COMMENT ON COLUMN fenbolivar.conest.cenoprea IS 'Nro. PreAprobado';
COMMENT ON COLUMN fenbolivar.conest.cecodest IS 'Codigo Estudiante';
COMMENT ON COLUMN fenbolivar.conest.cecoduni IS 'Codigo Universidad';
COMMENT ON COLUMN fenbolivar.conest.cenomuni IS 'Nombre Universidad';
COMMENT ON COLUMN fenbolivar.conest.cenomcar IS 'Nombre Carrera';
COMMENT ON COLUMN fenbolivar.conest.cenrosem IS 'Nro. Semestre';


