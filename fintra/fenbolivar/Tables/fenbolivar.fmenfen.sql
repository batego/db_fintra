-- Table: fenbolivar.fmenfen

-- DROP TABLE fenbolivar.fmenfen;

CREATE TABLE fenbolivar.fmenfen
(
  mfecod numeric(3,0), -- Codigo Mensaje
  mfedes text, -- Descripcion Mensaje Fenalchequ
  mfecodtipo text, -- Tipo mensaje  consulta operador
  mfecanpeso numeric(3,0), -- Peso Mensaje  Consulta Operador
  mfecodtipa text, -- Tipo Mensaje Cons  Automatica
  mfecanpesa numeric(2,0), -- Peso Mensaje Cons.  Automatica
  mfeusu text, -- Usuario
  mfeacc text, -- Accion
  mfefec timestamp without time zone, -- Fecha
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.fmenfen
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.fmenfen.mfecod IS 'Codigo Mensaje';
COMMENT ON COLUMN fenbolivar.fmenfen.mfedes IS 'Descripcion Mensaje Fenalchequ';
COMMENT ON COLUMN fenbolivar.fmenfen.mfecodtipo IS 'Tipo mensaje  consulta operador';
COMMENT ON COLUMN fenbolivar.fmenfen.mfecanpeso IS 'Peso Mensaje  Consulta Operador';
COMMENT ON COLUMN fenbolivar.fmenfen.mfecodtipa IS 'Tipo Mensaje Cons  Automatica';
COMMENT ON COLUMN fenbolivar.fmenfen.mfecanpesa IS 'Peso Mensaje Cons.  Automatica';
COMMENT ON COLUMN fenbolivar.fmenfen.mfeusu IS 'Usuario';
COMMENT ON COLUMN fenbolivar.fmenfen.mfeacc IS 'Accion';
COMMENT ON COLUMN fenbolivar.fmenfen.mfefec IS 'Fecha';


