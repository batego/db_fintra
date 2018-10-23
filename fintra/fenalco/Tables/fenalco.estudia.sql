-- Table: fenalco.estudia

-- DROP TABLE fenalco.estudia;

CREATE TABLE fenalco.estudia
(
  estdoccod numeric(2,0), -- Tipo Documento Estudiante
  estdidnum numeric(11,0), -- Nro. Documento Estudiante
  estdir text, -- Direccion Estudiante
  esttel1 numeric(11,0), -- Telefono1 Estudiante
  esttel2 numeric(11,0), -- Telefono2 Estudiante
  esttelcel numeric(11,0), -- Celular Estudiante
  estsexo text, -- Sexo
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.estudia
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.estudia.estdoccod IS 'Tipo Documento Estudiante';
COMMENT ON COLUMN fenalco.estudia.estdidnum IS 'Nro. Documento Estudiante';
COMMENT ON COLUMN fenalco.estudia.estdir IS 'Direccion Estudiante';
COMMENT ON COLUMN fenalco.estudia.esttel1 IS 'Telefono1 Estudiante';
COMMENT ON COLUMN fenalco.estudia.esttel2 IS 'Telefono2 Estudiante';
COMMENT ON COLUMN fenalco.estudia.esttelcel IS 'Celular Estudiante';
COMMENT ON COLUMN fenalco.estudia.estsexo IS 'Sexo';


