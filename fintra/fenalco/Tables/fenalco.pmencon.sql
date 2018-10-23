-- Table: fenalco.pmencon

-- DROP TABLE fenalco.pmencon;

CREATE TABLE fenalco.pmencon
(
  poscon numeric(8,0), -- Numero Negocio
  mfecod numeric(3,0), -- Codigo Mensaje
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.pmencon
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.pmencon.poscon IS 'Numero Negocio';
COMMENT ON COLUMN fenalco.pmencon.mfecod IS 'Codigo Mensaje ';


