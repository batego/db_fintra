-- Table: nas_fenalco

-- DROP TABLE nas_fenalco;

CREATE TABLE nas_fenalco
(
  cuenta character varying NOT NULL,
  banco character varying NOT NULL,
  sucursal character varying NOT NULL,
  concepto character varying NOT NULL,
  valor numeric NOT NULL,
  descripcion character varying NOT NULL,
  facturas text NOT NULL,
  cta_ajuste character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  procesado character varying DEFAULT 'NO'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE nas_fenalco
  OWNER TO postgres;
GRANT ALL ON TABLE nas_fenalco TO postgres;
GRANT SELECT ON TABLE nas_fenalco TO msoto;

