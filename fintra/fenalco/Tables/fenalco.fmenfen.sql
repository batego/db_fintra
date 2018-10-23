-- Table: fenalco.fmenfen

-- DROP TABLE fenalco.fmenfen;

CREATE TABLE fenalco.fmenfen
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
ALTER TABLE fenalco.fmenfen
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.fmenfen.mfecod IS 'Codigo Mensaje';
COMMENT ON COLUMN fenalco.fmenfen.mfedes IS 'Descripcion Mensaje Fenalchequ';
COMMENT ON COLUMN fenalco.fmenfen.mfecodtipo IS 'Tipo mensaje  consulta operador';
COMMENT ON COLUMN fenalco.fmenfen.mfecanpeso IS 'Peso Mensaje  Consulta Operador';
COMMENT ON COLUMN fenalco.fmenfen.mfecodtipa IS 'Tipo Mensaje Cons  Automatica';
COMMENT ON COLUMN fenalco.fmenfen.mfecanpesa IS 'Peso Mensaje Cons.  Automatica';
COMMENT ON COLUMN fenalco.fmenfen.mfeusu IS 'Usuario';
COMMENT ON COLUMN fenalco.fmenfen.mfeacc IS 'Accion';
COMMENT ON COLUMN fenalco.fmenfen.mfefec IS 'Fecha';


