-- Table: fenbolivar.pmencon

-- DROP TABLE fenbolivar.pmencon;

CREATE TABLE fenbolivar.pmencon
(
  poscon numeric(8,0), -- Numero Negocio
  mfecod numeric(3,0), -- Codigo Mensaje
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.pmencon
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.pmencon.poscon IS 'Numero Negocio';
COMMENT ON COLUMN fenbolivar.pmencon.mfecod IS 'Codigo Mensaje ';


