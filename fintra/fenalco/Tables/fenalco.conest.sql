-- Table: fenalco.conest

-- DROP TABLE fenalco.conest;

CREATE TABLE fenalco.conest
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
ALTER TABLE fenalco.conest
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.conest.estdoccod IS 'Tipo Documento Estudiante';
COMMENT ON COLUMN fenalco.conest.estdidnum IS 'Nro. Documento Estudiante';
COMMENT ON COLUMN fenalco.conest.poscon IS 'Numero Negocio';
COMMENT ON COLUMN fenalco.conest.cenoprea IS 'Nro. PreAprobado';
COMMENT ON COLUMN fenalco.conest.cecodest IS 'Codigo Estudiante';
COMMENT ON COLUMN fenalco.conest.cecoduni IS 'Codigo Universidad';
COMMENT ON COLUMN fenalco.conest.cenomuni IS 'Nombre Universidad';
COMMENT ON COLUMN fenalco.conest.cenomcar IS 'Nombre Carrera';
COMMENT ON COLUMN fenalco.conest.cenrosem IS 'Nro. Semestre';


