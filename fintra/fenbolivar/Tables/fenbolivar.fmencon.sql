-- Table: fenbolivar.fmencon

-- DROP TABLE fenbolivar.fmencon;

CREATE TABLE fenbolivar.fmencon
(
  gircon numeric(8,0), -- Tipo Documento
  mfecod numeric(3,0), -- Codigo Mensaje
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.fmencon
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.fmencon.gircon IS 'Tipo Documento';
COMMENT ON COLUMN fenbolivar.fmencon.mfecod IS 'Codigo Mensaje ';


