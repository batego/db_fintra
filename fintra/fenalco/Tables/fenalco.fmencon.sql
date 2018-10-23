-- Table: fenalco.fmencon

-- DROP TABLE fenalco.fmencon;

CREATE TABLE fenalco.fmencon
(
  gircon numeric(8,0), -- Tipo Documento
  mfecod numeric(3,0), -- Codigo Mensaje
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.fmencon
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.fmencon.gircon IS 'Tipo Documento';
COMMENT ON COLUMN fenalco.fmencon.mfecod IS 'Codigo Mensaje ';


